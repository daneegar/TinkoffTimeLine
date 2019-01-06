//
//  ApiHandler.swift
//  TinkoffTimeLine
//
//  Created by Denis Garifyanov on 06/01/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation

struct Article: Codable {
    let urlSlug: String
    let date: String
    let hidden: Bool
    let title: String
    let text: String?
    let lang: String
    enum CodingKeys: String, CodingKey {
        case urlSlug = "slug"
        case date = "date"
        case hidden = "hidden"
        case title = "title"
        case text = "text"
        case lang = "lang"
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.urlSlug = try valueContainer.decode(String.self, forKey: CodingKeys.urlSlug)
        self.date = try valueContainer.decode(String.self, forKey: CodingKeys.date)
        self.hidden = try valueContainer.decode(Bool.self, forKey: CodingKeys.hidden)
        self.title = try valueContainer.decode(String.self, forKey: CodingKeys.title)
        self.lang = try valueContainer.decode(String.self, forKey: CodingKeys.lang)
        self.text = nil
    }
    init(){
        self.urlSlug = ""
        self.date = ""
        self.hidden = true
        self.title = ""
        self.text = ""
        self.lang = ""
    }
}
struct Response: Codable {
    let response: String
    let total: Int
    let articles: [Article]
    enum ResponseKey: String, CodingKey {
        case response = "response"
    }
    enum NestResponseKeys: String, CodingKey {
        case total = "total"
        case articles = "news"
    }
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: ResponseKey.self)
        //print(valueContainer.allKeys)
        let nestContainer = try valueContainer.nestedContainer(keyedBy: NestResponseKeys.self, forKey: .response)
        self.total = try nestContainer.decode(Int.self, forKey: NestResponseKeys.total)
        self.articles = try nestContainer.decode(Array<Article>.self, forKey: NestResponseKeys.articles)
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
                    completion?(answer, urlResponse ,nil)
                }
            }
            if let urlResponse = urlResponse {
                //print(urlResponse)
            }
            if let error = error {
                print(error)
            }
        }
        task.resume()
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
