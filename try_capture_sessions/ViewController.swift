//
//  ViewController.swift
//  try_capture_sessions
//
//  Created by Rudolf Farkas on 16.07.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var qrCaptureSession: QRCaptureSession?
    var photoCaptureSession: PhotoCaptureSession?

    @IBOutlet weak var qrCaptureButton: UIButton!
    @IBOutlet weak var photoCaptureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

 
    @IBAction func qrCaptureTapped(_ sender: Any) {
        print("qrCaptureTapped")
        photoCaptureSession = nil
        if qrCaptureSession == nil {
            qrCaptureSession = QRCaptureSession(qrCaptureDelegate: self, videoPreviewView: self.view)
        }
        qrCaptureSession?.startRunning()
        view.bringSubview(toFront: qrCaptureButton)
        view.bringSubview(toFront: photoCaptureButton)
    }
    
    @IBAction func photoCaptureTapped(_ sender: Any) {
        print("photoCaptureTapped")
        qrCaptureSession = nil
        if photoCaptureSession == nil {
            photoCaptureSession = PhotoCaptureSession(captureDelegate: self, videoPreviewView: self.view)
        }
        photoCaptureSession?.startRunning()
        photoCaptureSession?.takePhoto = true
        view.bringSubview(toFront: qrCaptureButton)
        view.bringSubview(toFront: photoCaptureButton)
    }
}

extension ViewController: QRCaptureDelegate {

    func qrCodeCaptured(code: String) {
        print("qrCodeCaptured", code)

        qrCaptureSession?.stopRunning()

    }
}

extension ViewController: PhotoCaptureDelegate {

    func imageCaptured(image: UIImage) {
        print("ViewController: imageCaptured", image.size)

        photoCaptureSession?.stopRunning()

    }
}

