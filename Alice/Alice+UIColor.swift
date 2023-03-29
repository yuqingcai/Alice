//
//  Alice+UIColor.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/2/16.
//

import UIKit

extension UIColor {
    public convenience init(hex: String) {
        let r, g, b: CGFloat

        if (hex.hasPrefix("#")) {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff)) / 255
                    
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
            self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/100.0)
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

