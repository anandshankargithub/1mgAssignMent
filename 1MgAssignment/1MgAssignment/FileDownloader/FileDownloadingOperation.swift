//
//  FileDownloadingOperation.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//

import Foundation
protocol DownloadableProtocol {
    func downloadingCompletedSuccessfully(dataRecord:FileRecord)
}

class FileDownloadingOperation: Operation {
    var dataRecord:FileRecord!
    var cache:NSCache<FileRecord,NSData>!
    override func main() {
        if isCancelled || dataRecord.state == .cancelled{
            dataRecord.state = .cancelled
            return
        }
        
        dataRecord.state = .executing
        let data = NSData(contentsOf: dataRecord.url)
        if data != nil {
            cache.setObject(data!, forKey: dataRecord)
            dataRecord.state = .finished
        } else {
            dataRecord.state = .failed
        }
    }
}
