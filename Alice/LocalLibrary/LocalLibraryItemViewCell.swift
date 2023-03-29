//
//  LocalLibraryItemViewCell.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/12/16.
//

import UIKit

class LocalLibraryItemViewCell: UICollectionViewCell {
    
    required init?(coder: NSCoder) {
        self.isMarkable = false
        self.isMarked = false
        super.init(coder: coder)
    }
    
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isMarked: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isMarkable: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let image = image {
            image.draw(in: CGRect(origin: .zero, size: frame.size))
        }
        
        let markerWidth = frame.size.width / 8.0
        let markerHeight = frame.size.width / 8.0
        let markerX = frame.size.width - markerWidth - frame.size.width/20.0
        let markerY = frame.size.height - markerHeight - frame.size.height/20.0
        
        let rect = CGRect(x: markerX, y: markerY, width: markerWidth, height: markerHeight)
        
        if self.isMarkable {
            UIColor.white.setFill()
            let icon = UIImage(named: "icon-markable")
            icon?.draw(in: rect)
        }
        if isMarked {
            UIColor.systemBlue.setFill()
            let icon0 = UIImage(named: "icon-marked-background")
            icon0?.draw(in: rect)
            
            UIColor.white.setFill()
            let icon1 = UIImage(named: "icon-checked")
            icon1?.draw(in: rect)
            
        }
    }
}
