//
//  ColorSampler.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/7.
//

import UIKit

class ColorSampler: ColorSchemeGenerator {
    
    static let appendPhotoSchemeNotification: Notification.Name = Notification.Name("appendPhotoSchemeNotification")
    static let updatePhotoSchemeNotification: Notification.Name = Notification.Name("updatePhotoSchemeNotification")
    static let updatePhotoSchemeFrameNotification: Notification.Name = Notification.Name("updatePhotoSchemeFrameNotification")
    static let updatePhotoSchemeColorCountNotification: Notification.Name = Notification.Name("updatePhotoSchemeColorCountNotification")
    static let removePhotoSchemeNotification: Notification.Name = Notification.Name("removePhotoSchemeNotification")
    
    private var schemes: Array<ColorScheme>?
    private var subject: UIImage?
    private let subjectWidth: UInt32 = 300
    private let subjectHeight: UInt32 = 300
    private var defaultColorCount = 5
    
    private var activedSchemeIndex: Int?
    var miniSampleRatio = 0.1
    var sampleType: SampleType = .frequence
    
    private var photo: UIImage? {
        didSet {
            if let photo = self.photo {
                subject = createSampleTarget(photo, CGSize(width: CGFloat(subjectWidth), height: CGFloat(subjectHeight)))
            }
            schemes = nil
            activedSchemeIndex = -1
            createDateTime = nil
            uuid = nil
            name = nil
        }
    }
    
    override func set(photo: UIImage) {
        self.photo = photo
        
        if let photo = self.photo {
            let width = photo.size.width * 0.2
            let height = photo.size.height * 0.2
            let x = (photo.size.width - width)*0.5
            let y = (photo.size.height - height)*0.5
            let rect = CGRect(x: x, y: y, width: width, height: height)
            if let scheme = generate(colorCount: defaultColorCount, frame: rect, photo: photo, subject: subject, type: sampleType) {
                schemes = []
                schemes!.append(scheme)
                activedSchemeIndex = 0
            }
        }
    }
    
    override func getPhoto() -> UIImage? {
        return photo
    }
    
    private func getSubjectRatio(_ source: UIImage?, _ subject: UIImage?) -> CGFloat {
        var ratio = 1.0
        
        guard let source = source else {
            return 0.0
        }
        
        guard let subject = subject else {
            return 0.0
        }
        
        if (source.size.width >= source.size.height) {
            ratio = subject.size.width / source.size.width
        }
        else {
            ratio = subject.size.height / source.size.height
        }
        return ratio
    }
    
    private func createSampleTarget(_ image: UIImage?, _ size: CGSize) -> UIImage? {
        return image?.resize(to: size, in: .aspectFill)
    }
    
    private func generate(colorCount: Int, frame: CGRect, photo: UIImage?, subject: UIImage?, type: SampleType) -> ColorScheme? {
        guard let photo = photo else {
            return nil
        }
        
        var input: CGImage? = nil
        var sampleRect: CGRect = .zero
        var ratio = 1.0
        var adjust = frame
        
        if (frame.origin.x < 0.0) {
            adjust.origin.x = 0
        }
        if (frame.origin.y < 0.0) {
            adjust.origin.y = 0
        }
        if (frame.origin.x + frame.size.width > photo.size.width) {
            adjust.size.width = photo.size.width - frame.origin.x
        }
        if (frame.origin.y + frame.size.height > photo.size.height) {
            adjust.size.height = photo.size.height - frame.origin.y
        }
        
        if let subject = subject {
            input = subject.cgImage
            ratio = getSubjectRatio(photo, subject)
            
        }
        else {
            input = photo.cgImage
            ratio = 1.0
        }
        
        guard let input = input, let data = input.dataProvider?.data else {
            return nil
        }
        
        if (input.colorSpace?.model != .rgb) {
            return nil
        }
        
        var redOrder = 0
        var greenOrder = 1
        var blueOrder = 2
        var alphaOrder = 3
        sampleRect = CGRect(x: adjust.origin.x * ratio,
                            y: adjust.origin.y * ratio,
                            width: adjust.size.width * ratio,
                            height: adjust.size.height * ratio)
        
        if (input.byteOrderInfo == .orderDefault) {
            redOrder = 0
            greenOrder = 1
            blueOrder = 2
            alphaOrder = 3
        }
        else if (input.byteOrderInfo == .order32Little) {
            redOrder = 2
            greenOrder = 1
            blueOrder = 0
            alphaOrder = 3
        }
        
        var dominantColor: UnsafeMutablePointer<DominantColor>? = nil
        if (type == .frequence) {
            dominantColor = DominantColorByFrequenceFromBitmapBuffer(UnsafePointer<UInt8>(CFDataGetBytePtr(data)), UInt32(input.bytesPerRow), UInt32(colorCount), UInt32(sampleRect.origin.x), UInt32(sampleRect.origin.y), UInt32(sampleRect.size.width), UInt32(sampleRect.size.height), UInt32(redOrder), UInt32(greenOrder), UInt32(blueOrder), UInt32(alphaOrder))
        }
        else if (type == .sensitive) {
            dominantColor = DominantColorBySensitiveFromBitmapBuffer(UnsafePointer<UInt8>(CFDataGetBytePtr(data)), UInt32(input.bytesPerRow), UInt32(colorCount), UInt32(sampleRect.origin.x), UInt32(sampleRect.origin.y), UInt32(sampleRect.size.width), UInt32(sampleRect.size.height), UInt32(redOrder), UInt32(greenOrder), UInt32(blueOrder), UInt32(alphaOrder))
        }
        
        if let dominantColor = dominantColor {
            var items: Array<ColorItem> = []
            let colors: UnsafeMutablePointer<RawColor> = dominantColor.pointee.colors
            for i in 0 ..< dominantColor.pointee.count {
                let item = ColorItem(red: colors[Int(i)].red, green: colors[Int(i)].green, blue: colors[Int(i)].blue, alpha: colors[Int(i)].alpha, weight: colors[Int(i)].weight)
                items.append(item)
            }
            
            FreeDominantColor(dominantColor)
            
            let scheme = ColorScheme(frame: frame, items: items.sorted(by: { $0.weight! > $1.weight! }))
            return scheme
        }
        
        return nil
    }
    
    override func sample(colorCount: Int, frame: CGRect) {
        if (schemes == nil) {
            schemes = []
        }
        if let scheme = generate(colorCount: colorCount, frame: frame, photo: photo, subject: subject, type: sampleType) {
            schemes!.append(scheme)
            let index = schemes!.endIndex - 1
            activedSchemeIndex = index
            NotificationCenter.default.post(name: ColorSampler.appendPhotoSchemeNotification, object: self, userInfo: ["scheme": schemes![index], "index": index])
        }
    }
    
    override func updateScheme(colorCount: Int, frame: CGRect, index: Int) {
        if (schemes == nil) {
            return
        }
        
        if (index >= schemes!.count) {
            return
        }
        
        guard let photo = self.photo else {
            return
        }
        
        if (frame.size.width < photo.size.width*miniSampleRatio ||
            frame.size.height < photo.size.height*miniSampleRatio) {
            return
        }
        
        if let scheme = generate(colorCount: colorCount, frame: frame, photo: photo, subject: subject, type: sampleType) {
            schemes![index] = scheme
            NotificationCenter.default.post(name: ColorSampler.updatePhotoSchemeNotification, object: self, userInfo: ["scheme": schemes![index], "index": index])
        }
    }
    
    override func setScheme(frame: CGRect, index: Int) {
        if (schemes == nil) {
            return
        }
        
        if (index >= schemes!.count) {
            return
        }
        
        guard let photo = self.photo else {
            return
        }
        
        if (frame.size.width < photo.size.width*miniSampleRatio ||
            frame.size.height < photo.size.height*miniSampleRatio) {
            return
        }
        
        schemes![index].frame = frame
        NotificationCenter.default.post(name: ColorSampler.updatePhotoSchemeFrameNotification, object: self, userInfo: ["scheme": schemes![index], "index": index])
    }
    
    override func setScheme(colorCount: Int, index: Int) {
        if (schemes == nil) {
            return
        }
            
        if (index >= schemes!.count) {
            return
        }
        
        NotificationCenter.default.post(name: ColorSampler.updatePhotoSchemeColorCountNotification, object: self, userInfo: ["scheme": schemes![index], "index": index])
    }
    
    override func removeScheme(index: Int) {
        if (schemes == nil) {
            return
        }
        
        guard let activedSchemeIndex = activedSchemeIndex else {
            return
        }
        
        let scheme = schemes!.remove(at: index)
        if (schemes!.count == 0) {
            self.activedSchemeIndex = nil
        }
        else if (activedSchemeIndex >= schemes!.count) {
            self.activedSchemeIndex = schemes!.count - 1
        }
        
        NotificationCenter.default.post(name: ColorSampler.removePhotoSchemeNotification, object: self, userInfo: ["scheme": scheme, "index": index])
    }
    
    override func getType() -> ColorSchemeGeneratorType {
        return .colorSample
    }
    
    override func getThumbnail() -> UIImage? {
        guard let photo = photo else {
            return nil
        }
        
        let width = 512.0
        let height = 512.0
        let rawSize = photo.size
        let widthRatio  = width  / rawSize.width
        let heightRatio = height / rawSize.height
        
        var newSize: CGSize
        if (widthRatio < heightRatio) {
            newSize = CGSize(width: rawSize.width * heightRatio, height: rawSize.height * heightRatio)
        }
        else {
            newSize = CGSize(width: rawSize.width * widthRatio, height: rawSize.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        var rect = CGRect(origin: .zero, size: newSize)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        photo.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let resizedImage = newImage else {
            return nil
        }
        
        // Crop
        let sideLength = min(resizedImage.size.width, resizedImage.size.height)
        let sourceSize = resizedImage.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0
        let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength,height: sideLength).integral
        let sourceCGImage = resizedImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(to: cropRect)!
        let croppedImge = UIImage(cgImage: croppedCGImage, scale: resizedImage.imageRendererFormat.scale, orientation: resizedImage.imageOrientation)
        
        // Draw scheme
        rect = CGRect(origin: .zero, size: croppedImge.size)
        UIGraphicsBeginImageContextWithOptions(croppedImge.size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        croppedImge.draw(in: rect)
        
        if let scheme = getPortraitScheme() {
            let space = croppedImge.size.width / 10.0
            let schemeWidth = croppedImge.size.width - space*2
            let itemCount = scheme.items.count
            let itemWidth = schemeWidth / CGFloat(itemCount)
            let itemHeight = itemWidth
            let schemeHeight = itemHeight
                                
            let schemeRect = CGRect(x: (croppedImge.size.width - schemeWidth)/2.0, y: croppedImge.size.height - space - itemHeight, width: schemeWidth, height: schemeHeight)
                                
            context?.saveGState()
            // Draw shadow
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
                let colorRectPath = UIBezierPath(rect: CGRect(x: schemeRect.origin.x + CGFloat(i) * itemWidth, y: schemeRect.origin.y, width: itemWidth, height: itemHeight))
                UIColor(colorItem: color).setFill()
                colorRectPath.fill()
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    override func getSchemes() -> Array<ColorScheme>? {
        return schemes
    }
    
    override func getActivedSchemeIndex() -> Int? {
        return activedSchemeIndex
    }
    
    override func setActivedSchemeIndex(_ index: Int) {
        activedSchemeIndex = index
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
        photo = snapshoot.photo
        subject = createSampleTarget(photo, CGSize(width: CGFloat(subjectWidth), height: CGFloat(subjectHeight)))
        uuid = snapshoot.uuid
        name = snapshoot.name
        schemes = snapshoot.schemes
        activedSchemeIndex = snapshoot.activedSchemeIndex
        createDateTime = snapshoot.createDateTime
    }
    
    override func clear() {
        photo = nil
        schemes = nil
        activedSchemeIndex = nil
        createDateTime = nil
        uuid = nil
        name = nil
    }
        
    override func getPortrait() -> PortraitView? {
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
        
        let portrait = PhotoPortraitView(frame: CGRect(origin: .zero, size: portraitSize))
        portrait.photo = photo
        
        if let scheme = getPortraitScheme() {
            portrait.scheme = scheme
        }
        return portrait
    }
    
    override func getPortraitScheme() -> ColorScheme? {
        guard let photo = photo else {
            return nil
        }
        let subject = createSampleTarget(photo, CGSize(width: CGFloat(200), height: CGFloat(200)))
        return generate(colorCount: 5, frame: CGRect(x: 0.0, y: 0.0, width: photo.size.width, height: photo.size.height), photo: photo, subject: subject, type: .frequence)
    }
        
    override func setSampleType(_ type: SampleType) {
        sampleType = type
    }
}
