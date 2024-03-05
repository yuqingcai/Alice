//
//  ColorCardGenerator.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/20.
//

import UIKit

class ColorCardGenerator: ColorSchemeGenerator {
    
    static let updateColorCombinationNotification: Notification.Name = NSNotification.Name("updateColorCombinationNotification")
    static let activedColorIndexChangedNotification: Notification.Name = NSNotification.Name("activedColorIndexChangedNotification")
    
    let activedSchemeIndex: Int = 0
    var activedColorIndex: Int = 0
    var keyColorIndex: Int = 0
    
    var scheme: ColorScheme
    
    override init() {
        let items = [
            ColorItem(hue:  0, saturation: 10, brightness: 100, alpha: 100, weight: 100),
            ColorItem(hue: 30, saturation: 10, brightness: 100, alpha: 100, weight: 100),
            ColorItem(hue: 60, saturation: 10, brightness: 100, alpha: 100, weight: 100),
            ColorItem(hue: 90, saturation: 10, brightness: 100, alpha: 100, weight: 100),
            ColorItem(hue: 120, saturation: 10, brightness: 100, alpha: 100, weight: 100),
        ]
        scheme = ColorScheme(items: items)
        super.init()
    }
    
    override func set(selector: Int, hue: Int32?, saturation: Int32?, brightness: Int32?) {
        if selector != activedColorIndex {
            return
        }
        
        var item0 = scheme.items[0]
        var item1 = scheme.items[1]
        var item2 = scheme.items[2]
        var item3 = scheme.items[3]
        var item4 = scheme.items[4]
        
        if let hue = hue {
            item0.hue = hue
        }
        
        if let saturation = saturation {
            item0.saturation = saturation
        }
        
        if let brightness = brightness {
            item0.brightness = brightness
        }
//
//        item1.saturation = item0.saturation
//        item2.saturation = item0.saturation
//        item3.saturation = item0.saturation
//        item4.saturation = item0.saturation
//
//        item1 = adjustColorItem(source: item0, target: item1, contrastRatio: 1.0)
//        item2 = adjustColorItem(source: item0, target: item2, contrastRatio: 1.0)
//        item3 = adjustColorItem(source: item0, target: item3, contrastRatio: 1.0)
//        item4 = adjustColorItem(source: item0, target: item4, contrastRatio: 1.0)
//
        scheme.items = [
            item0,
            item1,
            item2,
            item3,
            item4,
        ]
        
        
        let L = getRelativeLuminance(item: item0)
        if let hue = item0.hue, let saturation = item0.saturation, let brightness = item0.brightness {
            print(String(format: "(%03d %03d %03d): %.4f", hue, saturation, brightness, L))
        }
        
//        let ratio0 = ContrastRatio(item0: item, item1: ColorItem(red: 255, green: 255, blue: 255, alpha: 100, weight: 100))
//        let ratio1 = ContrastRatio(item0: item, item1: ColorItem(red: 0, green: 0, blue: 0, alpha: 100, weight: 100))
//
//        if let red = item.red, let green = item.green, let blue = item.blue {
//            print(String(format: "(%03d %03d %03d): %.4f, %.4f, %.4f", red, green, blue, L, ratio0, ratio1))
//        }
        NotificationCenter.default.post(name: ColorCardGenerator.updateColorCombinationNotification, object: self, userInfo: nil)
    }
    
    func adjustColorItem(source: ColorItem, target: ColorItem, contrastRatio: CGFloat) -> ColorItem {
        var result = target
        while (true) {
            var ratio = getContrastRatio(item0: source, item1: result)
            if (abs(ratio - contrastRatio) < 0.1) {
                break
            }
            
            let L0 = getRelativeLuminance(item: source)
            let L1 = getRelativeLuminance(item: result)
            
            if (L0 > L1) {
                result.brightness! += 1
            }
            else {
                result.brightness! -= 1
            }
            
            if (result.brightness! <= 0 || result.brightness! >= 100) {
                print("can't find!")
                break
            }
            
        }
        return result
    }
    
    func getContrastRatio(item0: ColorItem, item1: ColorItem) -> CGFloat {
        let L0 = getRelativeLuminance(item: item0) + 0.05
        let L1 = getRelativeLuminance(item: item1) + 0.05
        
        if L0 < L1 {
            return L1 / L0
        }
        else {
            return L0 / L1
        }
    }
    
    func getRelativeLuminance(item: ColorItem) -> CGFloat {
        var L = 0.0
        
        if let red = item.red, let green = item.green, let blue = item.blue {
            let r = CGFloat(red)/255.0
            let g = CGFloat(green)/255.0
            let b = CGFloat(blue)/255.0
            
            var R = 0.0
            var G = 0.0
            var B = 0.0
            if (r < 0.03928 || fabs(r - 0.03928) < CGFLOAT_EPSILON) {
                R = r / 12.92
            }
            else {
                R = pow(((r + 0.055)/1.055), 2.4)
            }
            
            if (g < 0.03928 || fabs(g - 0.03928) < CGFLOAT_EPSILON) {
                G = g / 12.92
            }
            else {
                G = pow(((g + 0.055)/1.055), 2.4)
            }
            
            if (b < 0.03928 || fabs(b - 0.03928) < CGFLOAT_EPSILON) {
                B = b / 12.92
            }
            else {
                B = pow(((b + 0.055)/1.055), 2.4)
            }
            
            L = (0.2126*R) + (0.7152*G) + (0.0722*B)
        }
        
        return L
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
    
    override func getSchemes() -> Array<ColorScheme>? {
        return [scheme]
    }
}
