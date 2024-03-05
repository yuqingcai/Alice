//
//  ColorCard.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/11.
//

import UIKit

class ColorCard: ColorSchemeGenerator {
    
    var id: String
    var scheme: ColorScheme
    
    let activedSchemeIndex: Int = 0
    var activedColorIndex: Int = 0
    var keyColorIndex: Int = 0
    
    init(id: String, scheme: ColorScheme) {
        self.id = id
        self.scheme = scheme
    }
        
    override func getType() -> ColorSchemeGeneratorType {
        return .colorCard
    }
        
    override func getThumbnail() -> UIImage? {
        let width = 1024.0
        let height = 512.0
        
        let size = CGSize(width: width, height: height)
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        // draw background color
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 50.0)
        UIColor(named: "color-card-background")?.setFill()
        path.fill()
        
        let slice = scheme.items[0...4]
        
        // draw title
        let titleRectWidth = size.width
        let titleRectHeight = rect.size.height * (1.0/4.0)
        let titleRect = CGRect(x: 0.0, y: 0.0, width: titleRectWidth, height: titleRectHeight)
        let titleFontSize = titleRectHeight * 0.3
        var titleFont = UIFont(name: "Arial", size: titleFontSize)?.withTraits(.traitBold)
        if titleFont == nil {
            titleFont = UIFont.boldSystemFont(ofSize: titleFontSize)
        }
        let titleAttributes = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.foregroundColor: UIColor(named: "color-card-title"),
        ]
        
        let title = id
        let titleAttributeString = NSAttributedString(string: title, attributes: titleAttributes as [NSAttributedString.Key : Any])
        
        let drawStringSize = titleAttributeString.size()
        let titlePadding = (titleRectHeight - drawStringSize.height)*0.5
        let drawingRect = CGRect(x: titlePadding, y: titlePadding, width: drawStringSize.width, height: drawStringSize.height)
        title.draw(in: drawingRect, withAttributes: titleAttributes as [NSAttributedString.Key : Any])
        
        
        // draw values
        let valuesRectWidth = size.width
        let valuesRectHeight = rect.size.height * (3.0/4.0) * (1.0/4.0)
        let valuesRect = CGRect(x: 0.0, y: titleRect.origin.y + titleRect.size.height, width: valuesRectWidth, height: valuesRectHeight)
        let valuesFontSize = valuesRectHeight * 0.33
        var valuesFont = UIFont(name: "Arial", size: valuesFontSize)?.withTraits(.traitBold)
        if valuesFont == nil {
            valuesFont = UIFont.boldSystemFont(ofSize: valuesFontSize)
        }
        let valueAttributes = [
            NSAttributedString.Key.font: valuesFont,
            NSAttributedString.Key.foregroundColor: UIColor(named: "color-card-value"),
        ]
        
        let itemWidth = rect.size.width/CGFloat(slice.count)
        for i in 0 ..< slice.count {
            let value = slice[i].hexString()
            let attributeString = NSAttributedString(string: value, attributes: valueAttributes as [NSAttributedString.Key : Any])
            let drawStringSize = attributeString.size()
            
            let paddingVertical = (valuesRectHeight - drawStringSize.height)*0.5
            let paddingHorizontal = (itemWidth - drawStringSize.width)*0.5
            
            let valueRect = CGRect(x: CGFloat(i)*itemWidth + paddingHorizontal, y: valuesRect.origin.y + paddingVertical, width: drawStringSize.width, height: drawStringSize.height)
            
            attributeString.draw(in: valueRect)
        }
        

        // draw colors
        let itemCount = slice.count
        let itemHeight = rect.size.height * (3.0/4.0) * (3.0/4.0)
        for i in 0 ..< itemCount {
            let color = slice[i]
            let x = CGFloat(i)*itemWidth
            let y = valuesRect.origin.y + valuesRect.size.height
            let colorRect = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)

            let cornerSize = CGSize(width: 50.0, height: 50.0)
            var colorRectPath = UIBezierPath(rect: colorRect)
            if (i == 0) {
                colorRectPath = UIBezierPath(roundedRect: colorRect, byRoundingCorners: [.bottomLeft], cornerRadii: cornerSize)
            }
            else if (i == itemCount) {
                colorRectPath = UIBezierPath(roundedRect: colorRect, byRoundingCorners: [.bottomRight], cornerRadii: cornerSize)
            }

            UIColor(colorItem: color).setFill()
            colorRectPath.fill()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    override func getSchemes() -> Array<ColorScheme>? {
        return [scheme]
    }
    
    override func getPortraitScheme() -> ColorScheme? {
        return scheme
    }
    
    override func getActivedSchemeIndex() -> Int? {
        return activedSchemeIndex
    }
        
    override func getActivedColorIndex() -> Int? {
        return activedColorIndex
    }
    
    override func getKeyColorIndex() -> Int? {
        return keyColorIndex
    }
    
}
