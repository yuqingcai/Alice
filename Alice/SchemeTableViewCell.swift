//
//  SchemeTableViewCell.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/12/29.
//

import UIKit

class SchemeTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
