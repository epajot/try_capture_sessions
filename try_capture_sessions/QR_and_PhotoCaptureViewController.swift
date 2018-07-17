//
//  QR_and_PhotoCaptureViewController.swift
//  try_capture_sessions
//
//  Created by Rudolf Farkas on 16.07.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit

class QR_and_PhotoCaptureViewController: UIViewController {

    var qrAndPhotoCaptureSession: QR_and_PhotoCaptureSession?

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

    @IBAction func qrCaptureButtonTapped(_ sender: UIButton) {
        print("... qrCaptureButtonTapped")
        qrCaptureButton.isSelected = true
        photoCaptureButton.isSelected = true
        qrCaptureOn() 
    }

    func qrCaptureOn() {
        if qrAndPhotoCaptureSession == nil {
            qrAndPhotoCaptureSession = QR_and_PhotoCaptureSession(qrCaptureDelegate: self, photoCaptureDelegate: self, videoPreviewView: self.view)
        }
        qrCodeLabel.text = ""
        qrAndPhotoCaptureSession?.startRunning()
        bringSubviewsToFront()
    }
    
    @IBAction func photoCaptureButtonTapped(_ sender: UIButton) {
        print("... photoCaptureButtonTapped")
        photoCaptureNow()
    }

    func photoCaptureNow() {

        qrAndPhotoCaptureSession?.startRunning()

        if (qrAndPhotoCaptureSession?.takePhoto)! {
        } else {
            qrAndPhotoCaptureSession?.takePhoto = true
        }

    }

    func bringSubviewsToFront() {
        view.bringSubview(toFront: photoImageView)
        view.bringSubview(toFront: photoCaptureButton)
        view.bringSubview(toFront: qrCodeLabel)
        view.bringSubview(toFront: qrCaptureButton)
    }
}

extension QR_and_PhotoCaptureViewController: QRCaptureDelegate {

    func qrCodeCaptured(code: String) {
        print("qrCodeCaptured", code)

        DispatchQueue.main.async{
            self.qrCodeLabel.text = code
        }
       qrAndPhotoCaptureSession?.stopRunning()
    }
}

extension QR_and_PhotoCaptureViewController: PhotoCaptureDelegate {
    
    func imageCaptured(image: UIImage) {
        print("ViewController: imageCaptured", image.size)
        
        DispatchQueue.main.async{
            self.photoImageView.image = image
        }
        
        let photoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        
        photoViewController.photo = image

        DispatchQueue.main.async {
            self.present(photoViewController, animated: true, completion: {
            })
        }
    }
}

