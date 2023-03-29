//
//  ColorSchemeView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/13.
//

import UIKit

class ColorSchemeInfoSingleLineView: UIView {
    let columns: Int = 5
    
    var colorItems: Array<ColorItem>? {
        didSet {
            setNeedsDisplay()
        }
    }
        
    override var bounds: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var frame: CGRect {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let colorItems = colorItems else {
            return
        }
        
        UIColor.white.setFill()
        UIRectFill(rect)
        
        let textAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: frame.size.height*0.3),
            NSAttributedString.Key.foregroundColor: UIColor.black,
        ]
        
        let itemWidth = frame.size.width / CGFloat(colorItems.count)
        let itemHeight = frame.size.height
        for i in 0 ..< colorItems.count {
            let rect = CGRect(x: 0.0 + CGFloat(i)*itemWidth, y: 0.0, width: itemWidth, height: itemHeight)
            let drawingString = NSAttributedString(string: colorItems[i].hexString(), attributes: textAttributes)
            let drawingSize = drawingString.size()
            let drawPoint = CGPoint(x: rect.origin.x + (rect.width - drawingSize.width)*0.5, y: rect.origin.y + (rect.height - drawingSize.height) * 0.5)
            drawingString.draw(at: drawPoint)
        }
                
    }
    
}
