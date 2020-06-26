//
//  ImageSearchViewController.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//

import Foundation
import UIKit

let COLLECTION_VIEW_CELL_PADDING = 10

class ImageSearchViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var noPhotosLabel: UILabel!
    
    let transition = Loader()
    var selectedImage:ImageCollectionViewCell!
    
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    var isDownloadingFailed = false
    
    //initially we are keeping only 2 image per row
    var numberOfColumns:Int = 2
    
    var dataRecordArray = [FileRecord]()
    var imagesCache:NSCache<FileRecord,NSData> = NSCache()
    
    var presenter:ImageSearchPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserInterface()
        intializeDepdendencies()
    }
    
    func intializeDepdendencies() {
        presenter = ImageSearchPresenter(with: self)
    }
    
    func showActivityIndicator() {
        activityIndicatorView.isHidden = false
        noPhotosLabel.isHidden = true
    }
    
    func hideActivityIndicator() {
        activityIndicatorView.isHidden = true
    }
    
    func downloadFreshURLListRequest(searchString: String) {
        dataRecordArray.removeAll()
        reloadUserInterface()
        showActivityIndicator()
        presenter.downloadFreshURLListRequest(searchString: searchString)
    }
    
    func downloadNextPageImagesURLList(searchString:String) {
        showActivityIndicator()
        presenter.downloadNextPageImagesURLList(searchString: searchString)
    }
    
    
    func configureUserInterface() {
        collectionView.register(UINib(nibName: String(describing: ImageCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: CellIdentifiers.photoCollectionCellIdentifier)
        
        activityIndicatorView.layer.cornerRadius = 25
        searchBar.delegate = self
        searchBar.placeholder = Constants.searchString
        navigationItem.titleView = searchBar
    }
    
    func reloadUserInterface() {
        hideActivityIndicator()
        self.collectionView.reloadData()
        noPhotosLabel.isHidden = !dataRecordArray.isEmpty
        noPhotosLabel.text = ((dataRecordArray.isEmpty && isDownloadingFailed) ? Constants.unableToDownloadString : Constants.noPhotosString )
    }
}


extension ImageSearchViewController: ImageSearchProtocol {
    func imageListDownloadingCompletes(error:Bool, photosArray: [FileRecord]) {
        self.dataRecordArray = photosArray
        self.isDownloadingFailed = error
        self.reloadUserInterface()
    }
    
    func nextPageImageListDownloadingCompletes(error: Bool, photosArray: [FileRecord]) {
        if error == false {
            dataRecordArray += photosArray
            reloadUserInterface()
            collectionView.flashScrollIndicators()
        } else {
            hideActivityIndicator()
        }
    }
    
    func imageDownloadingCompleted(for indexPath: IndexPath) {
        self.collectionView.reloadItems(at: [indexPath])
    }
}


extension ImageSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataRecordArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:CellIdentifiers.photoCollectionCellIdentifier , for: indexPath) as! ImageCollectionViewCell
        
        let photoRecord = dataRecordArray[indexPath.row]
        
        //Data may be cleared due to Memory issue. We have to download it again.
        if photoRecord.state == .finished && imagesCache.object(forKey: photoRecord) == nil {
            photoRecord.state = .new
        }
        
        switch(photoRecord.state) {
            
        case .cancelled:
            photoRecord.state = .new
            fallthrough
            
        case .new:
            photoRecord.associatedIndexPath = indexPath
            presenter.startDownloadingImage(photosRecord: photoRecord, imageCache: imagesCache)
            fallthrough
            
        case .executing:
            cell.showActivityIndicator()
            
        case .failed:
            cell.showDownloadFailedError()
            
        case .finished:
            cell.imageView.image = UIImage(data: imagesCache.object(forKey: photoRecord)! as Data)
        }
        
        cell.imageTitleLabel.text = photoRecord.titleString
        
        if indexPath.row == dataRecordArray.count - 1 {
            downloadNextPageImagesURLList(searchString: searchBar.text!)
        }
        
        return cell
    }
}

extension ImageSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSide = (Int(collectionView.frame.width) - ((numberOfColumns - 1) * COLLECTION_VIEW_CELL_PADDING))/numberOfColumns
        return CGSize(width: cellSide,height:cellSide)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let imageData = imagesCache.object(forKey: dataRecordArray[indexPath.row]) as Data?, let image = UIImage(data: imageData) {
            
            selectedImage = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
            
            let imageDetailViewController = storyboard!.instantiateViewController(withIdentifier: String(describing: DetailedViewController.self)) as! DetailedViewController
            imageDetailViewController.image = image
            imageDetailViewController.transitioningDelegate = self
            present(imageDetailViewController, animated: true, completion: nil)
        }
    }
}

extension ImageSearchViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard !dataRecordArray.isEmpty else {
            return
        }
        
        if dataRecordArray[indexPath.row].state != .executing && dataRecordArray[indexPath.row].state != .finished {
            presenter.cancelOperationAtIndexPath(indexPath: indexPath)
        }
    }
}

extension ImageSearchViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.originFrame = selectedImage!.superview!.convert(selectedImage!.frame, to: nil)

        transition.presenting = true

        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}
