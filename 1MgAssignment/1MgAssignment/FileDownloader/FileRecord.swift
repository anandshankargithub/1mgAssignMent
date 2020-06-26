//
//  FileRecord.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//

import Foundation

protocol DataResponseParser {
    func parseResponse() -> [FileRecord]
}

enum OperationState:String {
    case new, executing, finished, cancelled, failed
}

class FileRecord {
    var state:OperationState
    var url:URL
    var associatedIndexPath:IndexPath?
    var titleString:String
    
    init(title:String, fileURL:URL) {
        titleString = title
        state = .new
        url = fileURL
    }
}

