//
//  PhotoListModel.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//

import Foundation
struct PhotoResponseStruct : Codable, DataResponseParser {
    var stat:String?
    var photos:PhotoListStruct?
    
    func parseResponse() -> [FileRecord] {
        let filteredURLList = photos?.photo.map { (photo) -> FileRecord in
            let name = photo.title
            let url = URL(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")!
            return FileRecord(title: name, fileURL: url)
        }
        
        return filteredURLList!
    }
}

struct PhotoListStruct : Codable {
    var page:Int
    var pages:Int
    var total:String
    var photo:[PhotoStruct]
}

struct PhotoStruct : Codable {
    var id:String
    var secret:String
    var server:String
    var farm:Int
    var title:String
}


