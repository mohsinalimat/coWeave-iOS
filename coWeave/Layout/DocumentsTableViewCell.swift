//
//  DocumentsTableViewCell.swift
//  coWeave
//
//  Created by Benoît Frisch on 18/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit

class DocumentsTableViewCell: UITableViewCell {
    @IBOutlet var author: UILabel!
    @IBOutlet var pageDate: UILabel!
    @IBOutlet var pageTitle: UILabel!
    @IBOutlet var documentImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
