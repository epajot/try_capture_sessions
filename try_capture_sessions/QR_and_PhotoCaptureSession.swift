//
//  QRCaptureSession.swift
//  Stick-Scan
//
//  Created by Rudolf Farkas on 14.07.18.
//  Copyright © 2018 Eric PAJOT. All rights reserved.
//

import UIKit
import AVFoundation

protocol QR_and_PhotoCaptureDelegate: class {
    func qrCodeCaptured(code: String)
}

class QR_and_PhotoCaptureSession: NSObject {

    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.itf14,
                              AVMetadataObject.ObjectType.dataMatrix,
                              AVMetadataObject.ObjectType.interleaved2of5,
                              AVMetadataObject.ObjectType.qr]

    private weak var qrCaptureDelegate: QRCaptureDelegate?
    private weak var photoCaptureDelegate: PhotoCaptureDelegate?
    weak var previewView: UIView?

    private var qrCaptureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private var qrCodeFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    var takePhoto = false

    var isRunning: Bool { return self.qrCaptureSession!.isRunning }

    func startRunning() {
        self.qrCodeFrameView.frame = CGRect.zero
        self.qrCaptureSession?.startRunning()
    }

    func stopRunning() { self.qrCaptureSession?.stopRunning() }

    init(qrCaptureDelegate: QRCaptureDelegate, photoCaptureDelegate: PhotoCaptureDelegate, videoPreviewView: UIView) {
        self.qrCaptureDelegate = qrCaptureDelegate
        self.photoCaptureDelegate = photoCaptureDelegate
        self.previewView = videoPreviewView
        super.init()
        self.qrCaptureSession = createSession()
        print("--- QRCaptureSession init")
    }

    deinit {
        print("--- QRCaptureSession deinit")
        previewLayer?.removeFromSuperlayer()
        qrCodeFrameView.removeFromSuperview()
    }

    private func createSession() -> AVCaptureSession? {

        let session = AVCaptureSession()

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

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            session.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes

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

        // Add QR Code Frame to highlight the QR code
        previewView?.addSubview(qrCodeFrameView)
        previewView?.bringSubview(toFront: qrCodeFrameView)

        // Start video capture.
        session.startRunning()

        return session
    }
}

extension QR_and_PhotoCaptureSession: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        // Check that the metadataObjects array contains at least one object.
        if metadataObjects.count == 0 {
            self.qrCodeFrameView.frame = CGRect.zero
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if self.supportedCodeTypes.contains(metadataObj.type) {
            // Is the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = self.previewLayer?.transformedMetadataObject(for: metadataObj)
            self.qrCodeFrameView.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                // pass the decoded QRCode/barcode string value to the delegate
                qrCaptureDelegate?.qrCodeCaptured(code: metadataObj.stringValue! as String)
            }
        }
    }
}


extension QR_and_PhotoCaptureSession: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        //print("captureOutput")

        if takePhoto {

            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                takePhoto = false

                print("captureOutput image.size", image.size)

                // call the delegate to deliver the image
                self.photoCaptureDelegate?.imageCaptured(image: image)
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




