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
    var indexPath: IndexPath?
    var mainView: TimeLineTableVC?
    var article: Article? = nil
    
    override func viewDidLoad() {
        articleText.alpha = 0
        articleText.isEditable = false
        self.getArticle()
        super.viewDidLoad()
    }
    func getArticle(){
        if let text = article?.text {
            showText(text)
        } else {
            guard let urlSlug = self.article?.urlSlug else {return}
            let apiHandler = ApiHandler()
            apiHandler.getArticle(urlSlug: urlSlug) { (article, response, error) in
                if let article = article {
                    self.article?.text = article.text
                    self.showText(article.text)
                }
                if let error = error as? errors {
                    PopUpError.showAnAllert(type: error, sender: self)
                    return
                } else if let error = error {
                    print (error)
                }
            }
        }
    }
    func showText(_ text: String?) {
        guard let text = text else {return}
        self.articleText.text = text.htmlToString
        UIView.animate(withDuration: 0.2) {
            self.articleText.alpha = 1
        }
        self.article?.readCounter += 1
        mainView?.setCountOfArticle(indexPath: indexPath!)
    }

}
//MARK: - html to normal string extension of String
    extension String {
        var htmlToAttributedString: NSAttributedString? {
            guard let data = data(using: .utf8) else { return NSAttributedString() }
            do {
                return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            } catch {
                return NSAttributedString()
            }
        }
        var htmlToString: String {
            return htmlToAttributedString?.string ?? ""
        }
    }



