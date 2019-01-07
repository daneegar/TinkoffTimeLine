//
//  Article.swift
//  TinkoffTimeLine
//
//  Created by Denis Garifyanov on 06/01/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import CoreData

extension Article {
    convenience init(fromResponse articleResponse: ArticleResponse, insertIntoManagesObjectContext contex: NSManagedObjectContext!) {
        self.init(context: contex)
        self.isBlank = false
        self.urlSlug = articleResponse.urlSlug
        self.title = articleResponse.title
        self.text = articleResponse.text
    }
    static func complete (left: Article, right: ArticleResponse)->Article{
        
        left.isBlank = false
        left.urlSlug = right.urlSlug
        left.title = right.title
        left.text = right.text
        return left
    }
}
