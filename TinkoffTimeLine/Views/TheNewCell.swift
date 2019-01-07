//
//  TheNewCell.swift
//  TinkoffTimeLine
//
//  Created by Denis Garifyanov on 06/01/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

class TheNewCell: UITableViewCell {

    @IBOutlet weak var bodyOfCell: UIView!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var readCounter: UILabel!
    

    func comleteSelf(withArticle article: Article){
        label.text = article.title
        if article.readCounter != 0 {
            readCounter.text = String(article.readCounter)
        } else {
            readCounter.text = ""
        }
        self.bodyOfCell.layer.cornerRadius = CGFloat(integerLiteral: 10)
    }
    

}
