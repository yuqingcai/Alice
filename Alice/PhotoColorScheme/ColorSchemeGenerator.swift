//
//  ColorPicker.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/7.
//

import UIKit

struct ColorSchemeItem {
    let red:CGFloat
    let green:CGFloat
    let blue:CGFloat
    let alpha:CGFloat
    let weight:UInt32
}

struct ColorScheme {
    let region:CGRect
    let items:Array<ColorSchemeItem>?
}

class PhotoColorSchemeGenerator: NSObject {
    var schemes: Array<ColorScheme>?
    var source: UIImage?
    var sample: UIImage?
    let sampleWidth:UInt32 = 512
    let sampleHeight:UInt32 = 512
    var sampleRatio = 1.0
    
    public func setPhoto(_ photo:UIImage) {
        source = photo
        sample = resizeImage(image: source, targetSize: CGSize(width: CGFloat(sampleWidth), height: CGFloat(sampleHeight)))
        sampleRatio = getSampleRatio(source, sample)
        schemes = []
    }
    
    private func getSampleRatio(_ source:UIImage?, _ sample:UIImage?) -> CGFloat {
        var ratio = 1.0
        
        guard let source = source else {
            return 0.0
        }
        
        guard let sample = sample else {
            return 0.0
        }
        
        if (source.size.width >= source.size.height) {
            ratio = sample.size.width / source.size.width
        }
        else {
            ratio = sample.size.height / source.size.height
        }
        return ratio
    }
    
    private func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else {
            return nil
        }
                
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if (widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        }
        else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public func generate(_ colorCount:UInt32, _ region:CGRect) -> ColorScheme? {
        guard let input = sample?.cgImage else {
            return nil
        }
        
        guard let data = input.dataProvider?.data else {
            return nil
        }
        
        assert(input.colorSpace?.model == .rgb)
        
        let sampleRegion:CGRect = CGRect(x: region.origin.x*sampleRatio, y: region.origin.y*sampleRatio, width: region.size.width*sampleRatio, height: region.size.height*sampleRatio)
        let dominantColor:UnsafeMutablePointer<DominantColor> = DominantColorFromBitmapBuffer(UnsafePointer<UInt8>(CFDataGetBytePtr(data)), UInt32(input.bytesPerRow), UInt32(colorCount), UInt32(sampleRegion.origin.x), UInt32(sampleRegion.origin.y), UInt32(sampleRegion.size.width), UInt32(sampleRegion.size.height))
        var items:Array<ColorSchemeItem> = []
        let colors:UnsafeMutablePointer<RgbawColor> = dominantColor.pointee.colors
        for i in 0 ..< dominantColor.pointee.count {
            items.append(self.colorItemFromRGBSWColor(colors[Int(i)]))
        }
        FreeDominantColor(dominantColor)
        
        return ColorScheme(region: region, items: items)
    }
    
    public func appendScheme(_ scheme:ColorScheme?) {
        guard let scheme = scheme else {
            return
        }
        schemes?.append(scheme)
    }
    
    public func replaceScheme(at index:Int, to scheme:ColorScheme?) {
        guard let scheme = scheme else {
            return
        }
        schemes?[index] = scheme
    }
    
    public func dumpSchemes() {
        for scheme in schemes! {
            print(scheme.items)
        }
    }
    
    private func colorItemFromRGBSWColor(_ color:RgbawColor) -> ColorSchemeItem {
        let r:CGFloat = CGFloat(color.red) / 255.0
        let g:CGFloat = CGFloat(color.green) / 255.0
        let b:CGFloat = CGFloat(color.blue) / 255.0
        let a:CGFloat = CGFloat(color.alpha) / 255.0
        let w:UInt32 = UInt32(color.weight)
        return ColorSchemeItem(red: r, green: g, blue: b, alpha: a, weight: w)
    }
    
}
