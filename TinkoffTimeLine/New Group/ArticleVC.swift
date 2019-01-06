//
//  ViewController.swift
//  TinkoffTimeLine
//
//  Created by Denis Garifyanov on 06/01/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

class ArticleVC: UIViewController {

    @IBOutlet weak var articleText: UITextView!
    
    var article: Article? = nil
    
    override func viewDidLoad() {
        self.getArticle()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func getArticle(){
        guard let urlSlug = self.article?.urlSlug else {return}
        let apiHandler = ApiHandler()
        apiHandler.getArticle(urlSlug: urlSlug) { (article, response, error) in
            guard let article = article else {return}
            self.articleText.text = article.text!
        }
    }


}

