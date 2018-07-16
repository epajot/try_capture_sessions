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
    var photoCaptureSession: QRCaptureSession?

    @IBOutlet weak var qrCaptureButton: UIButton!
    @IBOutlet weak var photoCaptureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

 
    @IBAction func qrCaptureTapped(_ sender: Any) {
        print("qrCaptureTapped")
        photoCaptureSession = nil
        qrCaptureSession = QRCaptureSession(qrCaptureDelegate: self, videoPreviewView: self.view)
        view.bringSubview(toFront: qrCaptureButton)
        view.bringSubview(toFront: photoCaptureButton)
    }
    
    @IBAction func photoCaptureTapped(_ sender: Any) {
        print("photoCaptureTapped")
        qrCaptureSession = nil
        photoCaptureSession = QRCaptureSession(qrCaptureDelegate: self, videoPreviewView: self.view)
        view.bringSubview(toFront: qrCaptureButton)
        view.bringSubview(toFront: photoCaptureButton)
    }
}

extension ViewController: QRCaptureDelegate {

    func qrCodeCaptured(code: String) {
        print("qrCodeCaptured", code)

//        let productId = code
//
//        if !productId.doesMatch(regex: shareQRCodePattern) {
//            messageLabel.text = "Not a ShareQRcode"
//            if selectStickPrintPatternOnly() {
//                return
//            }
//        }
//
        qrCaptureSession?.stopRunning()

//        vibrate()

//        // EP's Test Save productId in CoreData
//        let defaults = UserDefaults.standard
//        defaults.set((productId), forKey: "productId")
//
//        // present the messageViewController with the captured productId
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let messageViewController = storyboard.instantiateViewController(withIdentifier: "storyboardIDMessageViewController") as! MessageViewController
//        messageViewController.productId = productId
//        present(messageViewController, animated: true, completion: nil)
    }

}

