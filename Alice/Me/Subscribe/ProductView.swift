//
//  ProductView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/16.
//

import UIKit

class ProductView: UIView {

    var productTitle: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var productDescription: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var productPrice: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var productSubscriptionPeriod: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var actived: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIColor(named: "color-window-background")?.setFill()
        UIRectFill(rect)
        
        var selectorRectWith = 20.0
        var titleFontSize = 14.0
        var descriptionFontSize = 13.0
        if UIDevice.current.userInterfaceIdiom == .phone {
            selectorRectWith = 18.0
            titleFontSize = 14.0
            descriptionFontSize = 13.0
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            selectorRectWith = 20.0
            titleFontSize = 18.0
            descriptionFontSize = 17.0
        }
        
        let selectorSize = CGSize(width: selectorRectWith*0.5, height: selectorRectWith*0.5)
        let selectorPathRect = CGRect(origin: CGPoint(x: (selectorRectWith - selectorSize.width)*0.5, y: (frame.size.height-selectorSize.height)*0.5), size: selectorSize)
        
        var selectorColor = UIColor.clear
        if actived {
            selectorColor = UIColor.systemBlue
        }
        let stringColor = UIColor.white
        
        let selector = UIBezierPath(ovalIn: selectorPathRect)
        selectorColor.setFill()
        selectorColor.setStroke()
        selector.stroke()
        
        if actived {
            selector.fill()
        }
        
        let titleFontAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: titleFontSize, weight: .heavy),
            NSAttributedString.Key.foregroundColor:stringColor,
        ]
                
        let descriptionFontAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: descriptionFontSize),
            NSAttributedString.Key.foregroundColor:stringColor,
        ]
        
        let lineSapce = 8.0
        
        if let productPrice = productPrice, let productTitle = productTitle, let productDescription = productDescription {
            let titleDrawingString = NSAttributedString(string: productPrice + " / " + productTitle, attributes: titleFontAttributes)
            let titleDrawingSize = titleDrawingString.size()
            let descriptionDrawingString = NSAttributedString(string: productDescription, attributes: descriptionFontAttributes)
            let descriptionDrawingSize = descriptionDrawingString.size()
            
            let lineWidthMax = max(titleDrawingSize.width, descriptionDrawingSize.width)
            
            let drawingStringSize = CGSize(width: lineWidthMax, height: lineSapce + titleDrawingSize.height + lineSapce + descriptionDrawingSize.height + lineSapce)
            let drawingStringRect = CGRect(origin: CGPoint(x: (frame.size.width - drawingStringSize.width)*0.5, y: (frame.size.height - drawingStringSize.height)*0.5), size: drawingStringSize)

            let titleDrawingRect = CGRect(origin: CGPoint(x: drawingStringRect.origin.x + (drawingStringRect.size.width - titleDrawingSize.width)*0.5, y: drawingStringRect.origin.y + lineSapce), size: CGSize(width: titleDrawingSize.width, height: titleDrawingSize.height))
            titleDrawingString.draw(in: titleDrawingRect)

            let descriptionDrawingRect = CGRect(origin: CGPoint(x: drawingStringRect.origin.x + (drawingStringRect.size.width - descriptionDrawingSize.width)*0.5, y: titleDrawingRect.origin.y+titleDrawingRect.size.height + lineSapce), size: CGSize(width: descriptionDrawingSize.width, height: descriptionDrawingSize.height))
            descriptionDrawingString.draw(in: descriptionDrawingRect)
            
        }
                
    }

}
