//
//  Alice+UIImage.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/2/16.
//

import UIKit

extension UIImage {
    
    enum ImageResizeMode {
        case aspectFill
        case aspectFit
    }
        
    func resize(to size: CGSize, in mode: ImageResizeMode) -> UIImage? {
        var realSize: CGSize = .zero
        var ratio = 1.0
        if (mode == .aspectFill) {
            if (self.size.height < self.size.width) {
                ratio = size.height / self.size.height
            }
            else {
                ratio = size.width / self.size.width
            }
        }
        else if (mode == .aspectFit) {
            if (size.height < size.width) {
                ratio = size.height / self.size.height
            }
            else {
                ratio = size.width / self.size.width
            }
        }
        realSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: realSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(realSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func crop(in rect: CGRect) -> UIImage? {
        let cropRect = rect.integral
        let sourceCGImage = self.cgImage!
        let croppedCGImage = sourceCGImage.cropping(to: cropRect)!
        let croppedImge = UIImage(cgImage: croppedCGImage, scale: self.imageRendererFormat.scale, orientation: self.imageOrientation)
        return croppedImge
    }
    
    func cropCenter(size: CGSize) -> UIImage? {
        
        if (size.width > self.size.width || size.height > self.size.height) {
            return nil
        }
                
        var offsetX = 0.0
        var offsetY = 0.0
        
        if (size.width < self.size.width) {
            offsetX = (self.size.width - size.width) * 0.5
        }
        
        if (size.height < self.size.height) {
            offsetY = (self.size.height - size.height) * 0.5
        }
        
        let cropRect = CGRect(x: offsetX, y: offsetY, width: size.width, height: size.height).integral
        let sourceCGImage = self.cgImage!
        let croppedCGImage = sourceCGImage.cropping(to: cropRect)!
        let croppedImge = UIImage(cgImage: croppedCGImage, scale: self.imageRendererFormat.scale, orientation: self.imageOrientation)
        return croppedImge
    }
    
    func applyingMaskingBezierPath(_ path: UIBezierPath) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!
        context.addPath(path.cgPath)
        context.clip()
        draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let masked = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return masked
    }
    
    func png(isOpaque: Bool = true) -> Data? {
        flattened(isOpaque: isOpaque).pngData()
    }

    func jpg(isOpaque: Bool = true) -> Data? {
        flattened(isOpaque: isOpaque).jpegData(compressionQuality: 1.0)
    }
    
    func flattened(isOpaque: Bool = true) -> UIImage {
        if imageOrientation == .up {
            return self
        }
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in draw(at: .zero) }
    }
}
