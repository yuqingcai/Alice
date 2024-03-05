//
//  ColorComposer.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/1/16.
//

import UIKit

class ColorComposer: ColorSchemeGenerator {
    
    static let updateColorCombinationNotification: Notification.Name = Notification.Name("updateColorCombinationNotification")
    static let activedColorIndexChangedNotification: Notification.Name = Notification.Name("activedColorIndexChangedNotification")
    
    private var composeType: ColorComposeType
    
    var hues: Array<CGFloat>
    let activedSchemeIndex: Int = 0
    var activedColorIndex: Int?
    
    var currentModel: ComposeModel?
    let analogousModel: AnalogousModel? = AnalogousModel()
    let monochromaticModel: MonochromaticModel? = MonochromaticModel()
    let triadModel: TriadModel? = TriadModel()
    let complementaryModel: ComplementaryModel? = ComplementaryModel()
    let squareModel: SquareModel? = SquareModel()
    let splitComplementaryModel: SplitComplementaryModel? = SplitComplementaryModel()
    let customModel: CustomModel? = CustomModel()
    
    
    init(hues: Array<CGFloat>, defaultComposeType: ColorComposeType) {
        self.hues = hues
        self.activedColorIndex = ComposeModel.schemeSize / 2
        self.composeType = defaultComposeType
        
        super.init()
        setColorComposeType(type: defaultComposeType)
    }
    
    override func setColorComposeType(type: ColorComposeType) {
        composeType = type
        
        let previousModel: ComposeModel? = currentModel
        
        switch (composeType) {
        case .analogous:
            currentModel = analogousModel
        case .monochromatic:
            currentModel = monochromaticModel
        case .triad:
            currentModel = triadModel
        case .complementary:
            currentModel = complementaryModel
        case .square:
            currentModel = squareModel
        case .splitComplementary:
            currentModel = splitComplementaryModel
        case .custom:
            currentModel = customModel
        case .unknow:
            currentModel = nil
        }
        
        if let currentModel = currentModel {
            if previousModel != nil && previousModel != currentModel {
                let previousScheme = previousModel!.scheme
                let keyItem = previousScheme.items[ComposeModel.keyColorIndex]
                if let hue = keyItem.hue, let saturation = keyItem.saturation, let brightness = keyItem.brightness {
                    
                    let _ = currentModel.reset(hue: hue, saturation: saturation, brightness: brightness)
                    NotificationCenter.default.post(name: ColorComposer.updateColorCombinationNotification, object: self, userInfo: nil)
                }
            }
        }
    }
    
    override func set(selector: Int, hue: Int32?, saturation: Int32?, brightness: Int32?) {
        switch (composeType) {
        case .analogous:
            currentModel = analogousModel
        case .monochromatic:
            currentModel = monochromaticModel
        case .triad:
            currentModel = triadModel
        case .complementary:
            currentModel = complementaryModel
        case .square:
            currentModel = squareModel
        case .splitComplementary:
            currentModel = splitComplementaryModel
        case .custom:
            currentModel = customModel
        case .unknow:
            currentModel = nil
        }
        
        if let currentModel = currentModel {
            let _ = currentModel.generate(selector: selector, hue: hue, saturation: saturation, brightness: brightness)
            NotificationCenter.default.post(name: ColorComposer.updateColorCombinationNotification, object: self, userInfo: nil)
        }
    }
    
    
    override func getType() -> ColorSchemeGeneratorType {
        return .colorCompose
    }
    
    override func getThumbnail() -> UIImage? {
        
        guard let scheme = currentModel?.scheme else {
            return nil
        }
        
        let width = 512.0
        let height = 512.0
        let size = CGSize(width: width, height: height)
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        let context = UIGraphicsGetCurrentContext()
        
        let path = UIBezierPath(rect: rect)
        UIColor(named: "color-thumbnail-background")?.setFill()
        path.fill()
        
        let space = size.width / 10.0
        
        let schemeWidth = size.width - space*2
        let schemeHeight = size.width - space*5
        let itemCount = scheme.items.count
        let itemWidth = schemeWidth / CGFloat(itemCount)
        let itemHeight = schemeHeight
        
        let schemeRect = CGRect(x: (size.width - schemeWidth)/2.0, y: space*2, width: schemeWidth, height:itemHeight)
        
        // Draw shadow
        context?.saveGState()
        let shadowColor = UIColor(white: 0.2, alpha: 1.0)
        let shadowOffset = CGSizeMake(0, 5)
        let shadowBlurRadius: CGFloat = 10
        let schemeRectPath = UIBezierPath(rect: schemeRect)
        context?.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadowColor.cgColor)
        schemeRectPath.fill()
        context?.restoreGState()
        
        // Draw item
        for i in 0 ..< itemCount {
            let color = scheme.items[i]
            let colorRect = CGRect(x: schemeRect.origin.x + CGFloat(i) * itemWidth, y: schemeRect.origin.y, width: itemWidth, height: itemHeight)
            
            let cornerSize = CGSize(width: 20.0, height: 20.0)
            var colorRectPath = UIBezierPath(rect: colorRect)
            if (i == 0) {
                colorRectPath = UIBezierPath(roundedRect: colorRect, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: cornerSize)
            }
            else if (i == itemCount - 1) {
                colorRectPath = UIBezierPath(roundedRect: colorRect, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: cornerSize)
            }
            
            UIColor(colorItem: color).setFill()
            colorRectPath.fill()
        }
        
        
        let textWidth = size.width - space*2
        let textHeight = space
        let textRect = CGRect(x: (size.width - textWidth)/2.0, y: schemeRect.origin.y + schemeRect.size.height + space, width: textWidth, height:textHeight)
        
        let textAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: space/1.5),
            NSAttributedString.Key.foregroundColor: UIColor(named: "color-title"),
        ]
        
        var text = (ColorComposeTypeString(type: composeType) as NSString)
        if (name != nil && name! != "") {
            text = (name! as NSString)
            if (text.length > 16) {
                text = text.substring(with: NSRange(location: 0, length: 16)) as NSString
            }
        }
        
        (text.capitalized as NSString).draw(in: textRect, withAttributes: textAttributes as [NSAttributedString.Key : Any])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
    private func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    override func getSchemes() -> Array<ColorScheme>? {
        if let scheme = currentModel?.scheme {
            return [scheme]
        }
        return nil
    }
    
    override func getActivedSchemeIndex() -> Int? {
        return activedSchemeIndex
    }
        
    override func getActivedColorIndex() -> Int? {
        return activedColorIndex
    }
    
    override func setActivedColorIndex(_ index: Int) {
        guard let scheme = currentModel?.scheme else {
            return
        }
        
        if (index < 0 || index >= scheme.items.count) {
            return
        }
        
        activedColorIndex = index
        NotificationCenter.default.post(name: ColorComposer.activedColorIndexChangedNotification, object: self, userInfo: nil)
        
    }
    
    override func getExtensionSchemes() -> Array<ColorScheme>? {
        return nil
    }
    
    override func snapshoot() -> Snapshoot? {
        var createDateTime = createDateTime
        if createDateTime == nil {
            createDateTime = Date()
        }
        
        let snapshoot = Snapshoot(generator: self, createDateTime: createDateTime!, modifiedDateTime: Date())
        
        return snapshoot
    }
    
    override func restore(by snapshoot: Snapshoot) {
        uuid = snapshoot.uuid
        name = snapshoot.name
        createDateTime = snapshoot.createDateTime
        
        setColorComposeType(type: snapshoot.colorComposeType!)
        if let scheme = snapshoot.schemes?[0] {
            currentModel?.scheme = scheme
        }
        
    }
    
    override func getColorComposeType() -> ColorComposeType? {
        return composeType
    }
        
    override func getPortrait() -> PortraitView? {
        guard let scheme = currentModel?.scheme else {
            return nil
        }
        
        func showRect(rect: CGRect, background: UIColor) {
            let path = UIBezierPath(rect: rect)
            background.setFill()
            path.fill()
        }
        
        let cornerRadius = 48.0
        var portraitRatio = 1.0
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            portraitRatio = 1.333 // 4:3
        }
        else if (UIDevice.current.userInterfaceIdiom == .pad) {
            portraitRatio = 1.2
        }
        
        let portraitWidth = 2048.0
        let portraitHeight = portraitWidth * portraitRatio
        let portraitSize = CGSize(width: portraitWidth, height: portraitHeight)
        
        let rect = CGRect(origin: .zero, size: portraitSize)
        let space = portraitSize.width * 0.1
        var topSpace = space
        var bottomSpace = space
        let leftSpace = space
        let rightSpace = space
        let schemeWidth = portraitSize.width - leftSpace - rightSpace
        var schemeHeight = portraitHeight * 0.2
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            topSpace = space * 2.0
            bottomSpace = topSpace
            schemeHeight = portraitHeight * 0.4
        }
        else if (UIDevice.current.userInterfaceIdiom == .pad) {
            topSpace = space * 1.0
            bottomSpace = topSpace
            schemeHeight = portraitHeight * 0.4
        }
        let schemeRectY = portraitHeight * 0.5 - schemeHeight * 0.5 - bottomSpace * 0.5
        let schemeRect = CGRect(x: (portraitSize.width - schemeWidth)/2.0, y: schemeRectY, width: schemeWidth, height:schemeHeight)
        
        let itemCount = scheme.items.count
        let itemWidth = schemeWidth / CGFloat(itemCount)
        let itemHeight = schemeHeight
        
        // Draw item
        var hexStingFontSize = space * 0.2
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            hexStingFontSize = space * 0.2
        }
        else if (UIDevice.current.userInterfaceIdiom == .pad) {
            hexStingFontSize = space * 0.15
        }
        
        let hexStringFontAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: hexStingFontSize),
            NSAttributedString.Key.foregroundColor: UIColor.black,
        ]
        
        UIGraphicsBeginImageContextWithOptions(portraitSize, false, 1.0)
        
        // Fill background
        let path = UIBezierPath(rect: rect)
        UIColor(hex: "#FFFFFF").setFill()
        path.fill()
                
        for i in 0 ..< itemCount {
            // draw color
            let color = scheme.items[i]
            let colorRect = CGRect(x: schemeRect.origin.x + CGFloat(i) * itemWidth, y: schemeRect.origin.y, width: itemWidth, height: itemHeight)
            
            let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
            var colorRectPath = UIBezierPath(rect: colorRect)
            if (i == 0) {
                colorRectPath = UIBezierPath(roundedRect: colorRect, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: cornerSize)
            }
            else if (i == itemCount - 1) {
                colorRectPath = UIBezierPath(roundedRect: colorRect, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: cornerSize)
            }
            UIColor(colorItem: color).setFill()
            colorRectPath.fill()
            
            // draw text
            let space0 = space*0.5
            let drawingString = NSAttributedString(string: color.hexString(), attributes: hexStringFontAttributes)
            let drawingSize = drawingString.size()
            let drawPoint = CGPoint(x: colorRect.origin.x + (colorRect.width - drawingSize.width)*0.5, y: colorRect.origin.y + colorRect.size.height + space0)
            drawingString.draw(at: drawPoint)
        }
        
        // draw footer
        if let footer = UIImage(named: "icon-app-footer") {
            let footerHeight = bottomSpace * 0.5
            let footerWidth = footerHeight
            let widthRatio  = footerWidth  / footer.size.width
            let heightRatio = footerHeight / footer.size.height
            
            var newSize: CGSize
            if (widthRatio < heightRatio) {
                newSize = CGSize(width: footer.size.width * heightRatio, height: footer.size.height * heightRatio)
            }
            else {
                newSize = CGSize(width: footer.size.width * widthRatio, height: footer.size.height * widthRatio)
            }
            
            let origin = CGPoint(x: (portraitWidth - newSize.width)*0.5, y: (portraitHeight-bottomSpace) + (bottomSpace - newSize.height)*0.5)
            
            UIColor.black.setFill()
            footer.draw(in: CGRect(origin: origin, size: newSize))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let portrait = ColorWheelPortraitView(frame: CGRect(origin: .zero, size: portraitSize))
        portrait.clipsToBounds = true
        portrait.image = image
        return portrait
    }
    
    override func getHues() -> Array<CGFloat>? {
        return hues
    }
        
    override func getPortraitScheme() -> ColorScheme? {
        if let scheme = currentModel?.scheme {
            return scheme
        }
        return nil
    }
    
    override func getKeyColorIndex() -> Int? {
        return ComposeModel.keyColorIndex
    }
    
}
