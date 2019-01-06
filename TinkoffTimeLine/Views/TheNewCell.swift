//
//  TheNewCell.swift
//  TinkoffTimeLine
//
//  Created by Denis Garifyanov on 06/01/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

class TheNewCell: UITableViewCell {


    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func comliteSelf(withArticle article: Article){
        self.label.text = article.title
        self.label.sizeToFit()
        self.layoutIfNeeded()
    }
}
