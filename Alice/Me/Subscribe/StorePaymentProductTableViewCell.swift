//
//  StorePaymentProductTableViewCell.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/16.
//

import UIKit

class StorePaymentProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productView: ProductView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
