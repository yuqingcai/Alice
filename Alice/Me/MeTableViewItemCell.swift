//
//  MeTableViewItemCell.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/3.
//

import UIKit

class MeTableViewItemCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
