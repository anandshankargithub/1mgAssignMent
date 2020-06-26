//
//  FileDownloaderOperationQueue.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//

import Foundation
class FileDownloaderOperationQueue {
    
    var operationQueue = OperationQueue()
    
    var delegate:DownloadableProtocol!
    
    var pendingOperations = [IndexPath:FileDownloadingOperation]()
    
    init(withDelegate delegate:DownloadableProtocol) {
        operationQueue.maxConcurrentOperationCount = 5
        self.delegate = delegate
    }
    
    func addDataRecordInDownloadingQueue(dataRecord:FileRecord, cache: NSCache<FileRecord, NSData>) {
        guard !pendingOperations.keys.contains(dataRecord.associatedIndexPath!) else { return }
        addFileRecordItemToQueue(fileRecord:dataRecord, cache:cache)
    }
    
    func cancelAllOperations() {
        pendingOperations.removeAll()
        operationQueue.cancelAllOperations()
    }
    
    func cancelOperationAtIndexPath(indexPath:IndexPath) {
        if let operation = pendingOperations[indexPath], operation.isFinished == false {
            self.removeKeyValueFromDictionary(indexPath: indexPath)
            operation.dataRecord.state = .cancelled
        }
    }
    
    private func removeKeyValueFromDictionary(indexPath:IndexPath) {
        if !pendingOperations.isEmpty,let index = self.pendingOperations.index(forKey: indexPath) {
            self.pendingOperations.remove(at: index)
        }
    }
    
    func updateOperationIfAlreadyExists(photoRecord:FileRecord) -> Bool {
        let allOperations = operationQueue.operations
        let filteredOpertions = allOperations.filter({ (fileDownloadingOperation) -> Bool in
            (fileDownloadingOperation as! FileDownloadingOperation).dataRecord.associatedIndexPath! == photoRecord.associatedIndexPath!
        })
        
        if filteredOpertions.count > 0 {
            (filteredOpertions[0] as? FileDownloadingOperation)?.dataRecord.state = photoRecord.state
            return true
        } else {
            return false
        }
    }
    
    private func addFileRecordItemToQueue(fileRecord:FileRecord, cache:NSCache<FileRecord,NSData>) {
        
        guard !updateOperationIfAlreadyExists(photoRecord: fileRecord) else { return }
        
        guard delegate != nil else { return }
        
        let newOperation = FileDownloadingOperation()
        newOperation.dataRecord = fileRecord
        newOperation.cache = cache
        pendingOperations[fileRecord.associatedIndexPath!] = newOperation
        newOperation.completionBlock = {
            DispatchQueue.main.async {
                self.removeKeyValueFromDictionary(indexPath: fileRecord.associatedIndexPath!)
                if fileRecord.state != .cancelled {
                    self.delegate?.downloadingCompletedSuccessfully(dataRecord: fileRecord)
                }
            }
        }
        operationQueue.addOperation(newOperation)
    }
}

