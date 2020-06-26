//
//  URLBuilder.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//

import Foundation

struct URLParameters {
    var searchString:String
    var numberOfItemsPerPage:Int8
    var pageNumber:Int
    var relativeURL:String
    var apiKey:String
}

class URLBuilder: NSObject {
    var url:URL!
    init(urlParams:URLParameters) {
        
        let filteredSearchString = urlParams.searchString.trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        url = URL(string: "\(URLConstants.relativeURL)?method=flickr.photos.search&api_key=\(urlParams.apiKey)&format=json&nojsoncallback=1&safe_search=1&page=\(urlParams.pageNumber)&per_page=\(urlParams.numberOfItemsPerPage)&text=\(filteredSearchString)")
    }
}

