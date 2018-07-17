//
//  PhotoViewController.swift
//  try_capture_sessions
//
//  Created by Rudolf Farkas on 17.07.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    var photo: UIImage?

    @IBOutlet weak var imageView: UIImageView!

    @IBAction func backButtontapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        print("... PhotoViewController viewDidLoad")

        if let photo = self.photo {
            imageView.image = photo
        }
    }
    
}
