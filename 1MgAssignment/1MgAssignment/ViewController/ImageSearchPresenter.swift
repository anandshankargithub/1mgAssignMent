//
//  ImageSearchPresenter.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//

import Foundation
import UIKit

protocol ImageSearchProtocol {
    func imageListDownloadingCompletes(error: Bool, photosArray: [FileRecord])
    
    func nextPageImageListDownloadingCompletes(error: Bool, photosArray: [FileRecord])
    
    func imageDownloadingCompleted(for indexPath: IndexPath)
}


class ImageSearchPresenter:DownloadableProtocol {
    
    private var searchView: ImageSearchProtocol!
    var imageListDownloader = FileListDownloader.sharedInstance
    var imageDownloadingQueue:FileDownloaderOperationQueue?
    
    init(with view:ImageSearchProtocol) {
        searchView = view
        imageDownloadingQueue = FileDownloaderOperationQueue(withDelegate: self)
    }
    
    func downloadFreshURLListRequest(searchString:String) {
        imageDownloadingQueue?.cancelAllOperations()
        imageDownloadingQueue?.delegate = self
        guard searchString.trimmingCharacters(in: CharacterSet.whitespaces) != Constants.emptyString else {
            imageListDownloader.cancelDataFetchingFromServer()
            return
        }
        
        imageListDownloader.downloadFreshMetaDataForText(searchText: searchString, modelClass: PhotoResponseStruct(), successHandler: { (newPhoneRecordList) in
            self.searchView.imageListDownloadingCompletes(error:false, photosArray: newPhoneRecordList)
        }) {
            self.searchView.imageListDownloadingCompletes(error:true, photosArray: [])
        }
    }
    
    func downloadNextPageImagesURLList(searchString:String) {
        imageListDownloader.downloadNextPageMetaData(searchText: searchString, modelClass: PhotoResponseStruct(), successHandler: { (newPhoneRecordList) in
            self.searchView.nextPageImageListDownloadingCompletes(error: false, photosArray: newPhoneRecordList)
        }, failureHandler: {
            self.searchView.nextPageImageListDownloadingCompletes(error: false, photosArray: [])
        })
    }
    
    func startDownloadingImage(photosRecord: FileRecord, imageCache:NSCache<FileRecord,NSData>) {
        imageDownloadingQueue?.addDataRecordInDownloadingQueue(dataRecord: photosRecord, cache: imageCache)
    }
    
    func downloadingCompletedSuccessfully(dataRecord:FileRecord) {
        self.searchView.imageDownloadingCompleted(for: dataRecord.associatedIndexPath!)
    }
    
    func cancelOperationAtIndexPath(indexPath:IndexPath){
        imageDownloadingQueue?.cancelOperationAtIndexPath(indexPath: indexPath)
    }
}
