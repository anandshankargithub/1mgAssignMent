//
//  ImageSearchViewController+UISearchBar.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//

import Foundation
import UIKit
extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchedString = searchBar.text, searchedString.trimmingCharacters(in: CharacterSet.whitespaces) != Constants.emptyString {
            downloadFreshURLListRequest(searchString: searchedString)
            if(searchBar.isFirstResponder){
                searchBar.resignFirstResponder()
            }
           
        }
    }
}
