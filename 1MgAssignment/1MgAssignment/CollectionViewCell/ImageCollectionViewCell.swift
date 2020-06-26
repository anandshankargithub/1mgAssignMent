//
//  ImageCollectionViewCell.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var failedLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTitleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showActivityIndicator()
    }
    
    override func prepareForReuse() {
        hideActivityIndicator()
        hideDownloadFailedError()
        imageView.image = UIImage()
    }
    
    func showDownloadFailedError() {
        failedLabel.isHidden = false
    }
    
    func hideDownloadFailedError() {
        failedLabel.isHidden = true
    }
    
    func showActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}
