//
//  FileListDownloader.swift
//  1MgAssignment
//
//  Created by Anand Shankar on 25/06/20.
//  Copyright © 2020 Anand Shankar. All rights reserved.
//
import Foundation

class FileListDownloader {
    
    static let sharedInstance = FileListDownloader()
    
    private var currentPageNumber = 1
    
    private var dataTask:URLSessionDataTask!
    
    private init() { }
    
    func downloadNextPageMetaData<T:Codable>(searchText:String, modelClass:T, successHandler:@escaping ([FileRecord]) -> (), failureHandler: @escaping () -> ()) where T:DataResponseParser{
        currentPageNumber += 1
        downloadMetaData(searchText: searchText, modelClass:modelClass, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func downloadFreshMetaDataForText<T:Codable>(searchText:String, modelClass:T,successHandler:@escaping ([FileRecord]) -> (), failureHandler: @escaping () -> ()) where T:DataResponseParser {
        currentPageNumber = 1
        downloadMetaData(searchText: searchText, modelClass:modelClass, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    private func urlBuilderStructForCurrentSearch(searchString:String) -> URLParameters {
        return URLParameters(searchString: searchString, numberOfItemsPerPage: 30, pageNumber: currentPageNumber, relativeURL: URLConstants.relativeURL, apiKey: URLConstants.apiKey)
    }
    
    func cancelDataFetchingFromServer() {
        if dataTask != nil {
            dataTask.cancel()
            dataTask = nil
        }
    }
    
    private func downloadMetaData<T:Codable>(searchText:String, modelClass:T, successHandler:@escaping ([FileRecord]) -> (), failureHandler: @escaping () -> ()) where T:DataResponseParser {
        cancelDataFetchingFromServer()
        print("URL : \(URLBuilder(urlParams: urlBuilderStructForCurrentSearch(searchString:searchText)).url!)")
        dataTask = URLSession.shared.dataTask(with: URLBuilder(urlParams: urlBuilderStructForCurrentSearch(searchString:searchText)).url!) {data,response,error in
            
            guard data != nil else {
                DispatchQueue.main.async {
                    failureHandler()
                }
                return
            }
            
            do
            {
                let fileURLList = try JSONDecoder().decode(T.self, from: data!)
                DispatchQueue.main.async {
                    successHandler(self.parseDownloadedDataIntoFileRecord(data: fileURLList))
                }
            } catch {
                print("Found an error while downloading file URL list")
            }
        }
        dataTask.resume()
    }
    
    func parseDownloadedDataIntoFileRecord<T:Codable>(data:T) -> [FileRecord] where T:DataResponseParser {
        return data.parseResponse()
    }
}



