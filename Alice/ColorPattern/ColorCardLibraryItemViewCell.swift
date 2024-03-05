//
//  ColorCardLibraryItemViewCell.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/7.
//

import UIKit

class ColorCardLibraryItemViewCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let image = image {
            image.draw(in: CGRect(origin: .zero, size: frame.size))
        }
        
    }
}
