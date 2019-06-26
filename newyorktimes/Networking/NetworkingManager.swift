//
//  NetworkingManager.swift
//  restaurants
//
//  Created by Michael Jester on 6/23/19.
//  Copyright © 2019 Michael Jester. All rights reserved.
//

import Foundation

typealias ArticleListCompletion = (_ articles: [Article]?, _ error: Error?) -> Void

struct NetworkErrors {
    
    struct Keys {
        static let DescriptionKey = "DescriptionKey"
    }
    
    struct Domains {
        static let NYTimes = "NeyYorkTimesApiDomain"
    }
    
    struct Codes {
        static let NilDataCode = 1001
        static let BadJsonDataCode = 1002
        static let NilArticlesArrayCode = 1003
        static let NilNextPageOfArticlesArrayCode = 1004
    }
    
    struct Descriptions {
        static let NilDataDescription = "The network returned a nil data set"
        static let BadJsonDataDescription = "Exception thrown while trying to decode JSON response from the network"
        static let NilArticlesArrayDescription = "The network returned a nil set of news articles"
        static let NilNextPageOfArticlesArrayDescription = "The network returned a nil set of news articles when trying to retrieve the next page"
    }
}

struct NewsStoriesResponse: Decodable {
    
    let status: String?
    let copyright: String?
    let response: Documents?
    
    enum CodingKeys: String, CodingKey {
        case status
        case copyright
        case response
    }
}

struct Documents: Decodable {
    let docs: [Article]?
    
    enum CodingKeys: String, CodingKey {
        case docs
    }
}
struct Article: Decodable {
    let abstract: String?
    let lead_paragraph: String?
    let web_url: String?
    let multimedia: [ArticleImage]
    
    enum CodingKeys: String, CodingKey {
        case abstract
        case lead_paragraph
        case web_url
        case multimedia
    }
}

struct ArticleImage: Decodable {
    let crop_name: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case crop_name
        case url
    }
}

class NetworkingManager: NSObject {
    
    static func loadArticlesWithCompletion(pageNumber:Int? = nil, _ completionHandler:@escaping ArticleListCompletion) {
        
        let baseAddress = "https://api.nytimes.com/svc/search/v2/articlesearch.json"
        let category = "election"
        let pageString: String
        if let pageNumber = pageNumber {
            pageString = "&page=" + String(pageNumber)
        } else {
            pageString = ""
        }
        let apiKey = "d31fe793adf546658bd67e2b6a7fd11a"
        
        let requestString = baseAddress + "?q=" + category + pageString + "&api-key=" + apiKey
        
        guard let url = URL(string: requestString) else {
            print("Error: cannot create URL")
            return
        }
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)
        
        // make the request with the session
        let urlRequest = URLRequest(url: url)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            //check 1: no errors
            guard error == nil else {
                print("error calling the request:\(error!)")
                completionHandler(nil, error)
                return
            }
            
            //check 2: data is non-nil
            guard let data = data else {
                print("Error: data is nil")
                let nilDataError = NSError(domain: NetworkErrors.Domains.NYTimes, code: NetworkErrors.Codes.NilDataCode, userInfo: [NetworkErrors.Keys.DescriptionKey:NetworkErrors.Descriptions.NilDataDescription])
                completionHandler(nil, nilDataError)
                return
            }
            
            //check 3: response parameter is non-nil
            if response != nil {
                do {
                    
                    let jsonResponse: NewsStoriesResponse = try JSONDecoder().decode(NewsStoriesResponse.self, from: data)
                    
                    if let articles: [Article] = jsonResponse.response?.docs {
                        completionHandler(articles, nil)
                    }

                } catch let error as NSError {
                    print("Error: \(error)")
                    let badJsonError = NSError(domain: NetworkErrors.Domains.NYTimes, code: NetworkErrors.Codes.BadJsonDataCode, userInfo: [NetworkErrors.Keys.DescriptionKey:NetworkErrors.Descriptions.BadJsonDataDescription])
                    completionHandler(nil, badJsonError)
                }
            }
        }
        
        task.resume()
    }
    
    static func downloadImageAtURL(urlString: String, downloadCompletionHandler:@escaping ((Data)->Void)){
        
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)
        
        // make the request with the session
        let urlRequest = URLRequest(url: url)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            //check 1: no errors
            guard error == nil else {
                print("error calling the request:\(error!)")
                return
            }
            
            //check 2: data is non-nil
            guard data != nil else {
                print("Error: data is nil")
                return
            }
            
            //check 3: response parameter is non-nil
            if response != nil {
                downloadCompletionHandler(data!)
            } else {
                print("Error: response in nil")
            }
        }
        
        task.resume()
    }
 
}

