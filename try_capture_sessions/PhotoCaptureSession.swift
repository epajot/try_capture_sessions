//
//  PhotoCaptureSession.swift
//  try_capture_sessions
//
//  Created by Rudolf Farkas on 16.07.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit
import AVFoundation

protocol PhotoCaptureDelegate: class {
    func imageCaptured(image: UIImage)
}

class PhotoCaptureSession: NSObject {

    private weak var captureDelegate: PhotoCaptureDelegate?
    weak var previewView: UIView?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    var takePhoto = false

    var isRunning: Bool { return self.captureSession!.isRunning }

    func startRunning() { self.captureSession?.startRunning() }

    func stopRunning() { self.captureSession?.stopRunning() }

    init(captureDelegate: PhotoCaptureDelegate, videoPreviewView: UIView) {
        self.captureDelegate = captureDelegate
        self.previewView = videoPreviewView
        super.init()
        self.captureSession = createSession()
        print("--- PhotoCaptureSession init")
    }

    deinit {
        print("--- PhotoCaptureSession deinit")
        previewLayer?.removeFromSuperlayer()
    }

    private func createSession() -> AVCaptureSession? {

        let session = AVCaptureSession()

        session.sessionPreset = .photo

        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return nil
        }

        // Add input and output
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session.
            session.addInput(input)

            // Initialize a AVCaptureVideoDataOutput object and set it as the output device to the capture session.
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]

            dataOutput.alwaysDiscardsLateVideoFrames = true
            session.addOutput(dataOutput)

            let queue = DispatchQueue(label: "try-capture-sessions.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)

        } catch {
            // If any error occurs, simply print it and return.
            print(error)
            return nil
        }

        // Initialize the video preview layer and add it as a sublayer to the previewView's layer.
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = (previewView?.layer.bounds)!

        previewView?.layer.addSublayer(self.previewLayer!)

        // Start video capture.
        session.startRunning()

        return session
    }
}

extension PhotoCaptureSession: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        //print("captureOutput")

        if takePhoto {

            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                takePhoto = false

                print("captureOutput image.size", image.size)

                // call the delegate to deliver the image
                self.captureDelegate?.imageCaptured(image: image)
            }
        }
    }


    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()

            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))

            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }

}


