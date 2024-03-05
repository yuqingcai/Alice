//
//  Alice+UIColor.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/2/16.
//

import UIKit

extension UIColor {
    public convenience init(hex: String) {
        if (hex.hasPrefix("#")) {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255.0
                    let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255.0
                    let b = CGFloat((hexNumber & 0x0000ff)) / 255.0
                    
//                    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
//                    let colorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
//                    let colorSpace = CGColorSpace(name: CGColorSpace.adobeRGB1998)!
//                    let components: [CGFloat] = [r, g, b, 1.0]
//                    let color = CGColor(colorSpace: colorSpace, components: components)!
//                    self.init(cgColor: color)
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }

        self.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        return
    }
        
    public convenience init(colorItem: ColorItem) {
        if let red = colorItem.red, let green = colorItem.green, let blue = colorItem.blue, let alpha = colorItem.alpha {
            
            let r = CGFloat(red) / 255.0
            let g = CGFloat(green) / 255.0
            let b = CGFloat(blue) / 255.0
            let a = CGFloat(alpha) / 100.0
            
//            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
//            let colorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
//            let colorSpace = CGColorSpace(name: CGColorSpace.adobeRGB1998)!
//            let components: [CGFloat] = [r, g, b, a]
//            let color = CGColor(colorSpace: colorSpace, components: components)!
//            self.init(cgColor: color)
            self.init(red: r, green: g, blue: b, alpha: a)
        }
        else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
    
//
//    public convenience init(colorItem: ColorItem, hues: Array<CGFloat>) {
//        if let hue = colorItem.hue, let saturation = colorItem.saturation, let brightness = colorItem.brightness, let alpha = colorItem.alpha {
//            self.init(hue: hues[Int(hue)], saturation: CGFloat(saturation)/100.0, brightness: CGFloat(brightness)/100.0, alpha: CGFloat(alpha)/100.0)
//        }
//        else {
//            self.init(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0)
//        }
//    }
    
}

