//
//  MeTableViewProfileCell.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/3.
//

import UIKit

class MeTableViewProfileCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
