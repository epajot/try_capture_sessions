//
//  QR_and_PhotoCaptureViewController.swift
//  try_capture_sessions
//
//  Created by Rudolf Farkas on 16.07.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit

class QR_and_PhotoCaptureViewController: UIViewController {

    var qrCaptureSession: QR_and_PhotoCaptureSession?
    var photoCaptureSession: PhotoCaptureSession?

    @IBOutlet weak var qrCaptureButton: UIButton!
    @IBOutlet weak var photoCaptureButton: UIButton!

    @IBOutlet weak var qrCodeLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("--- QR_and_PhotoCaptureViewController viewDidLoad")
    }

    override func viewWillAppear(_ animated: Bool) {
        print("--- QR_and_PhotoCaptureViewController willAppear")

        qrCaptureOn()
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("--- QR_and_PhotoCaptureViewController viewDidDisappear")
    }

    @IBAction func qrCaptureTapped(_ sender: Any) {
        print("... qrCaptureTapped")
        qrCaptureButton.isSelected = true
        photoCaptureButton.isSelected = false
        qrCaptureOn() 
    }

    func qrCaptureOn() {
        photoCaptureSession = nil
//        photoCaptureButton.setTitle("Photo Capture", for: .normal)
//        photoImageView.image = nil
        if qrCaptureSession == nil {
            qrCaptureSession = QR_and_PhotoCaptureSession(qrCaptureDelegate: self, videoPreviewView: self.view)
        }
//        qrCodeLabel.text = ""
        qrCaptureSession?.startRunning()
        bringSubviewsToFront()
    }
    
    @IBAction func photoCaptureTapped(_ sender: Any) {
        print("... photoCaptureTapped")
        qrCaptureButton.isSelected = false
        photoCaptureButton.isSelected = true
        photoCaptureOn()
    }

    func photoCaptureOn() {

        qrCaptureSession = nil
        qrCodeLabel.text = ""
        qrCaptureButton.setTitle("QR Capture", for: .normal)

        if photoCaptureSession == nil {
            photoCaptureSession = PhotoCaptureSession(captureDelegate: self, videoPreviewView: self.view)
            photoCaptureButton.setTitle("Take photo!", for: .normal)
            photoCaptureButton.setNeedsLayout()
            photoCaptureSession?.startRunning()
        } else {
            if (photoCaptureSession?.takePhoto)! {
            } else {
                photoCaptureSession?.takePhoto = true
            }
        }
        bringSubviewsToFront()
    }



    func bringSubviewsToFront() {
//        view.bringSubview(toFront: photoImageView)
//        view.bringSubview(toFront: photoCaptureButton)
//        view.bringSubview(toFront: qrCodeLabel)
//        view.bringSubview(toFront: qrCaptureButton)
//        print("qrCaptureButton.frame", qrCaptureButton.frame)
    }
}

extension QR_and_PhotoCaptureViewController: QRCaptureDelegate {

    func qrCodeCaptured(code: String) {
        print("qrCodeCaptured", code)

        DispatchQueue.main.async{
            self.qrCodeLabel.text = code
        }
       qrCaptureSession?.stopRunning()
    }
}

extension QR_and_PhotoCaptureViewController: PhotoCaptureDelegate {

    func imageCaptured(image: UIImage) {
        print("ViewController: imageCaptured", image.size)

        DispatchQueue.main.async{
            self.photoImageView.image = image
        }
    }
}

