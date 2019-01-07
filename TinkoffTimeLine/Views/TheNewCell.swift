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
    

    func comleteSelf(withArticle article: Article){
        self.label.text = article.title
        self.bodyOfCell.layer.cornerRadius = CGFloat(integerLiteral: 10)
    }
    

}
