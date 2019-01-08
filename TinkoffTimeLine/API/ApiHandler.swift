//
//  ApiHandler.swift
//  TinkoffTimeLine
//
//  Created by Denis Garifyanov on 06/01/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import SystemConfiguration

enum ApiErrors: Error {
    case parsError
}

struct ArticleResponse: Codable {
    let urlSlug: String
    let date: String
    let hidden: Bool
    let title: String
    let text: String?
    let lang: String
    let counterOfOpening: Int?
    
    enum ResponseKey: String, CodingKey {
        case response = "response"
    }
    enum CodingKeys: String, CodingKey {
        case urlSlug = "slug"
        case date = "date"
        case hidden = "hidden"
        case title = "title"
        case text = "text"
        case lang = "lang"
    }
    
    init(from decoder: Decoder) throws {
        if let valueContainer =  try? decoder.container(keyedBy: CodingKeys.self) {
            if valueContainer.allKeys != [] {
            self.urlSlug = try valueContainer.decode(String.self, forKey: CodingKeys.urlSlug)
            self.date = try valueContainer.decode(String.self, forKey: CodingKeys.date)
            self.hidden = try valueContainer.decode(Bool.self, forKey: CodingKeys.hidden)
            self.title = try valueContainer.decode(String.self, forKey: CodingKeys.title)
            self.lang = try valueContainer.decode(String.self, forKey: CodingKeys.lang)
            self.text = nil
            self.counterOfOpening = nil
            return
            }
        }
        guard let valueContainer =  try? decoder.container(keyedBy: ResponseKey.self) else { throw ApiErrors.parsError }
            let nestContainer = try valueContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
            self.urlSlug = try nestContainer.decode(String.self, forKey: CodingKeys.urlSlug)
            self.date = try nestContainer.decode(String.self, forKey: CodingKeys.date)
            self.hidden = try nestContainer.decode(Bool.self, forKey: CodingKeys.hidden)
            self.title = try nestContainer.decode(String.self, forKey: CodingKeys.title)
            self.lang = try nestContainer.decode(String.self, forKey: CodingKeys.lang)
            self.text = try nestContainer.decode(String.self, forKey: CodingKeys.text)
            self.counterOfOpening = nil
    }
}
struct Response: Codable {
    let response: String
    let total: Int
    let articles: [ArticleResponse]
    enum ResponseKey: String, CodingKey {
        case response = "response"
    }
    enum NestResponseKeys: String, CodingKey {
        case total = "total"
        case articles = "news"
    }
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: ResponseKey.self)
        let nestContainer = try valueContainer.nestedContainer(keyedBy: NestResponseKeys.self, forKey: .response)
        self.total = try nestContainer.decode(Int.self, forKey: NestResponseKeys.total)
        self.articles = try nestContainer.decode(Array<ArticleResponse>.self, forKey: NestResponseKeys.articles)
        //print(nestContainer.allKeys)
        self.response = ""
    }
}


class ApiHandler {
    let stringUrl: String
    let ApiHomeUrl: URL
    init () {
        self.stringUrl = "https://cfg.tinkoff.ru/news/public/api/platform/v1"
        self.ApiHomeUrl = URL(string: self.stringUrl)!
    }
    func getList (with pageOffSet: Int?, and inQuanity: Int?, completion: ((Response?, URLResponse?, Error?) -> Void)?){
        if checkConnection() == errors.connection {completion?(nil,nil, errors.connection)}
        var resultURL = self.ApiHomeUrl
        resultURL.appendPathComponent("getArticles")
        if let pageOffSet = pageOffSet {
            resultURL = resultURL.append("pageOffset", value: String(pageOffSet))
        } else {
            resultURL = resultURL.append("pageOffset", value: "0")
        }
        if let inQuanity = inQuanity {
            resultURL = resultURL.append("pageSize", value: String(inQuanity))
        } else {
            resultURL = resultURL.append("pageSize", value: "20")
        }
        
        let task = URLSession.shared.dataTask(with: resultURL) { (data, urlResponse, error) in
            let jsonDecoder = JSONDecoder()
            if let catchedData = data, let answer = try? jsonDecoder.decode(Response.self, from: catchedData)
            {
                DispatchQueue.main.async {
                    completion?(answer, urlResponse , error)
                }
            }
        }
        task.resume()
    }
    func getArticle (urlSlug: String, completion: ((ArticleResponse?, URLResponse?, Error?) -> Void)?){
        if checkConnection() == errors.connection {completion?(nil,nil, errors.connection)}
        var resultURL = self.ApiHomeUrl
        resultURL.appendPathComponent("getArticle")
        resultURL = resultURL.append("urlSlug", value: urlSlug)

        
        let task = URLSession.shared.dataTask(with: resultURL) { (data, urlResponse, error) in
            let jsonDecoder = JSONDecoder()
            if let catchedData = data, let answer = try? jsonDecoder.decode(ArticleResponse.self, from: catchedData)
            {
                DispatchQueue.main.async {
                    completion?(answer, urlResponse ,nil)
                }
            }
        }
        task.resume()
    }
    
    func checkConnection () -> errors? {
        let isConnetion: Reachability = Reachability()
        if !isConnetion.isConnectedToNetwork() {
            return errors.connection
        } else {
            return nil
        }
    }
    
}




extension URL {
    
    @discardableResult
    func append(_ queryItem: String, value: String?) -> URL {
        
        guard var urlComponents = URLComponents(string:  absoluteString) else { return absoluteURL }
        
        // create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // create query item if value is not nil
        guard let value = value else { return absoluteURL }
        let queryItem = URLQueryItem(name: queryItem, value: value)
        
        // append the new query item in the existing query items array
        queryItems.append(queryItem)
        
        // append updated query items array in the url component object
        urlComponents.queryItems = queryItems// queryItems?.append(item)
        
        // returns the url from new url components
        return urlComponents.url!
    }
}

class Reachability {
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
