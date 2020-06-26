//
//  DetailedViewController.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//
import UIKit
import Foundation
class DetailedViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    var image:UIImage!
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = false
        imageView.image = image
        self.title = "Deatil"
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClose(_:))))
    }
    
    @objc func actionClose(_ tap: UITapGestureRecognizer) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
