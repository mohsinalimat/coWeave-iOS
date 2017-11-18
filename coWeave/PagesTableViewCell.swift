//
//  PagesTableViewCell.swift
//  coWeave
//
//  Created by Benoît Frisch on 18/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit

class PagesTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var number: UILabel!
    @IBOutlet var pageImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
