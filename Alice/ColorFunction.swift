//
//  ColorFunction.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/1/4.
//

import UIKit
import simd
import ColorPaletteCodable

public class ColorItem: NSObject  {
    // 0 - 255
    var red: Int32?
    
    // 0 - 255
    var green: Int32?
    
    // 0 - 255
    var blue: Int32?
    
    // 0 - 360
    var hue: Int32? {
        didSet {
            // make hue in closed range: [0, 360]
            if (hue! > 360) {
                hue = 360
            }
            if (hue! < 0) {
                hue = 361 - abs((self.hue!%361))
            }
            syncRGBFromHSB()
        }
    }
    
    // 0 - 100
    var saturation: Int32? {
        didSet {
            if (saturation! > 100) {
                saturation = 100
            }
            if (saturation! < 0) {
                saturation = 0
            }
            syncRGBFromHSB()
        }
    }
    
    // 0 - 100
    var brightness: Int32? {
        didSet {
            if (brightness! > 100) {
                brightness = 100
            }
            if (brightness! < 0) {
                brightness = 0
            }
            syncRGBFromHSB()
        }
    }
    
    // 0 - 100
    var alpha: Int32? {
        didSet {
            if (alpha! > 100) {
                alpha = 100
            }
            if (alpha! < 0) {
                alpha = 0
            }
        }
    }
    
    // 0 - 100
    var weight: Int32? {
        didSet {
            if (weight! > 100) {
                weight = 100
            }
            if (weight! < 0) {
                weight = 0
            }
        }
    }
    
    init(red: Int32, green: Int32, blue: Int32, alpha: Int32, weight: Int32) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.weight = weight
        
        if (self.red! > 255) {
            self.red = 255
        }
        if (self.red! < 0) {
            self.red = 0
        }
        
        if (self.green! > 255) {
            self.green = 255
        }
        if (self.green! < 0) {
            self.green = 0
        }
        
        if (self.blue! > 255) {
            self.blue = 255
        }
        if (self.blue! < 0) {
            self.blue = 0
        }
        
        if (self.alpha! > 100) {
            self.alpha = 100
        }
        if (self.alpha! < 0) {
            self.alpha = 0
        }
        
        if (self.weight! > 100) {
            self.weight = 100
        }
        if (self.weight! < 0) {
            self.weight = 0
        }
                
        super.init()
    }
    
    init(hue: Int32, saturation: Int32, brightness: Int32, alpha: Int32, weight: Int32) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
        self.weight = weight
        
        // make hue in closed range: [0, 360]
        if (self.hue! > 360) {
            self.hue = 360
        }
        if (self.hue! < 0) {
            self.hue = 361 - abs((self.hue!%361))
        }
        
        if (self.saturation! > 100) {
            self.saturation = 100
        }
        if (self.saturation! < 0) {
            self.saturation = 0
        }
        
        if (self.brightness! > 100) {
            self.brightness = 100
        }
        if (self.brightness! < 0) {
            self.brightness = 0
        }
        
        if (self.alpha! > 100) {
            self.alpha = 100
        }
        if (self.alpha! < 0) {
            self.alpha = 0
        }
        
        if (self.weight! > 100) {
            self.weight = 100
        }
        if (self.weight! < 0) {
            self.weight = 0
        }
                
        let rgb = ColorFunction.hsb2rgb(hue: self.hue!, saturation: self.saturation!, brightness: self.brightness!, alpha: self.alpha!)
        self.red = rgb.0
        self.green = rgb.1
        self.blue = rgb.2
        
        if (self.red! > 255) {
            self.red = 255
        }
        if (self.red! < 0) {
            self.red = 0
        }
        
        if (self.green! > 255) {
            self.green = 255
        }
        if (self.green! < 0) {
            self.green = 0
        }
        
        if (self.blue! > 255) {
            self.blue = 255
        }
        if (self.blue! < 0) {
            self.blue = 0
        }
        
        super.init()
    }
    
    private func syncRGBFromHSB () {
        if let hue = hue, let saturation = saturation, let brightness = brightness, let alpha = alpha {
            let rgb = ColorFunction.hsb2rgb(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
            self.red = rgb.0
            self.green = rgb.1
            self.blue = rgb.2
        }
    }
    
    func hexString() -> String {
        if let red = self.red, let green = self.green, let blue = self.blue, let alpha = self.alpha {
            let hex = ColorFunction.rgb2hex(red: red, green: green, blue: blue, alpha: alpha)
            return String(format: "#%02X%02X%02X", hex.0, hex.1, hex.2)
        }
        return String(format: "#------")
    }
    
    func rgbString() -> String {
        if let red = self.red, let green = self.green, let blue = self.blue {
            return String(format: "R%03d G%03d B%03d", red, green, blue)
        }
        return String(format: "R--- G--- B---")
    }
    
    func rybString() -> String {
        if let red = self.red, let green = self.green, let blue = self.blue, let alpha = self.alpha {
            let ryb = ColorFunction.rgb2ryb(red: red, green: green, blue: blue, alpha: alpha)
            return String(format: "R%03d Y%03d B%03d", ryb.0, ryb.1, ryb.2)
        }
        return String(format: "R--- Y--- B---")
    }
    
    func hslString() -> String {
        if let red = self.red, let green = self.green, let blue = self.blue, let alpha = self.alpha {
            let hsl = ColorFunction.rgb2hsl(red: red, green: green, blue: blue, alpha: alpha)
            return String(format: "H%03d S%03d L%03d", hsl.0, hsl.1, hsl.2)
        }
        return String(format: "H--- S--- L---")
    }
    
    func hsbString() -> String {
        if let red = self.red, let green = self.green, let blue = self.blue, let alpha = self.alpha {
            let hsb = ColorFunction.rgb2hsb(red: red, green: green, blue: blue, alpha: alpha)
            return String(format: "H%03d S%03d B%03d", hsb.0, hsb.1, hsb.2)
        }
        return String(format: "H--- S--- B---")
    }
    
    func cmykString() -> String {
        if let red = self.red, let green = self.green, let blue = self.blue, let alpha = self.alpha {
            let cmyk = ColorFunction.rgb2cmyk(red: red, green: green, blue: blue, alpha: alpha)
            return String(format: "C%03d M%03d Y%03d K%03d", cmyk.0, cmyk.1, cmyk.2, cmyk.3)
        }
        return String(format: "C--- M--- Y--- K---")
    }
    
}

class ColorScheme: NSObject {
    var frame: CGRect
    var items: Array<ColorItem>
    
    init(frame: CGRect, items: Array<ColorItem>) {
        self.frame = frame
        self.items = items
        super.init()
    }
    
    init(items: Array<ColorItem>) {
        self.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
        self.items = items
        super.init()
    }
}


class ColorFunction: NSObject {
    static private let numberOfHue = 361
    static private let numberOfSaturation = 101
    
    static var wheelHues: Array<CGFloat>?
    static let keyColors: Array<UIColor> = [
        UIColor(hex: "#FF0101"), // 0
        UIColor(hex: "#FF2200"), // 15
        UIColor(hex: "#FF4600"), // 30
        UIColor(hex: "#FF7100"), // 45
        UIColor(hex: "#FF8A00"), // 60
        UIColor(hex: "#FFA701"), // 75
        UIColor(hex: "#FFC800"), // 90
        UIColor(hex: "#FFE900"), // 105
        UIColor(hex: "#F4FF00"), // 120
        UIColor(hex: "#91FF00"), // 135
        UIColor(hex: "#44FF01"), // 150
        UIColor(hex: "#01FF08"), // 165
        UIColor(hex: "#00FF48"), // 180
        UIColor(hex: "#00FF8C"), // 195
        UIColor(hex: "#00FFC7"), // 210
        UIColor(hex: "#01F4FF"), // 225
        UIColor(hex: "#00B6FF"), // 240
        UIColor(hex: "#007BFF"), // 255
        UIColor(hex: "#011AFF"), // 270
        UIColor(hex: "#2600FF"), // 285
        UIColor(hex: "#5C00FF"), // 300
        UIColor(hex: "#A900FF"), // 315
        UIColor(hex: "#E900FF"), // 330
        UIColor(hex: "#FF00B1"), // 345
    ]
    
    static func createWheelHues(_ type:String) {
        if (type.lowercased() == "rgb") {
            createRGBHues()
        }
        else if (type.lowercased() == "artist") {
            createJIHues()
        }
    }
    
    private static func createRGBHues() {
        var hues: Array<CGFloat> = Array(repeating: 0.0, count: numberOfHue)
        for i in 0 ..< numberOfHue {
            hues[i] = CGFloat(i)/CGFloat(numberOfHue)
        }
        wheelHues = hues
    }
    
    private static func createJIHues() {
        var keyHues: Array<CGFloat> = []
        for color in keyColors {
            var hue: CGFloat = 0.0
            color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
            keyHues.append(hue)
        }
        
        // make color wheel array with 361 items
        var hues: Array<CGFloat> = Array(repeating: 0.0, count: numberOfHue)
        if (hues.count < keyHues.count) {
            print("Error: wheel hues count should not less than key hues count")
            return
        }
        
        let s = numberOfHue / keyHues.count
        var l = 0
        
        for i in 0 ..< keyHues.count {
            var h1: CGFloat = 0.0
            var h2: CGFloat = 0.0

            if (i < keyHues.count - 1) {
                h1 = keyHues[i]
                h2 = keyHues[i + 1]
            }
            else if (i == keyHues.count - 1) {
                h1 = keyHues[i]
                h2 = 1.0
            }
            
            let d = abs(h2 - h1) / CGFloat(s)
            for j in 0 ..< s {
                l = i*s+j
                hues[l] = h1 + (d * CGFloat(j))
            }
        }
        
        l += 1
        while (l < numberOfHue) {
            hues[l] = 1.0
            l += 1
        }
        wheelHues = hues
    }
    
    // red:     0 - 255
    // green:   0 - 255
    // blue:    0 - 255
    // alpha:   0 - 100
    static func rgb2hex(red: Int32, green: Int32, blue: Int32, alpha: Int32) -> (Int32, Int32, Int32, Int32) {
        return (red, green, blue, alpha)
    }
    
    // red:     0 - 255
    // green:   0 - 255
    // blue:    0 - 255
    // alpha:   0 - 100
    static func rgb2ryb(red: Int32, green: Int32, blue: Int32, alpha: Int32)  -> (Int32, Int32, Int32, Int32) {
        var r = CGFloat(red)
        var g = CGFloat(green)
        var b = CGFloat(blue)
                
        // Remove the white from the color
        let w = min(r, g, b)
        r -= w
        g -= w
        b -= w
        
        let maxGreen = max(r, g, b)
        // Get the yellow out of the red+green
        var y = min(r, g)
        r -= y
        g -= y
        
        // If this unfortunate conversion combines blue and green, then cut each in half to
        // preserve the value's maximum range.
        if b > CGFLOAT_EPSILON && g > CGFLOAT_EPSILON {
            b /= 2.0
            g /= 2.0
        }
        
        // Redistribute the remaining green.
        y += g
        b += g
        
        // Normalize to values.
        let maxYellow = max(r, y, b);
        
        if maxYellow > 0 {
            let N = maxGreen / maxYellow;
            r *= N
            y *= N
            b *= N
        }
        
        // Add the white back in.
        r += w
        y += w
        b += w
        
        // r:       0 - 255
        // y:       0 - 255
        // b:       0 - 255
        // alpha:   0 - 100
        return (Int32(r), Int32(y), Int32(b), alpha)
    }
    
    // red:     0 - 255
    // green:   0 - 255
    // blue:    0 - 255
    // alpha:   0 - 100
    static func rgb2hsl(red: Int32, green: Int32, blue: Int32, alpha: Int32) -> (Int32, Int32, Int32, Int32) {
        
        let r = CGFloat(red) / 255.0
        let g = CGFloat(green) / 255.0
        let b = CGFloat(blue) / 255.0
        
        let cmax = max(r, g, b)
        let cmin = min(r, g, b)
        let delta = cmax - cmin
                    
        var h = 0.0
        if delta < CGFLOAT_EPSILON {
            h = 0.0
        }
        else {
            if fabs(cmax - r) < CGFLOAT_EPSILON {
                h = fmod(60.0 * ((g - b) / delta) + 360.0, 360.0)
            }
            else if fabs(cmax - g) < CGFLOAT_EPSILON {
                h = fmod(60.0 * ((b - r) / delta) + 120, 360.0)
            }
            else if fabs(cmax - b) < CGFLOAT_EPSILON {
                h = fmod(60.0 * ((r - g) / delta) + 240.0, 360.0)
            }
        }
        
        let l = (cmax + cmin) / 2.0
        
        var s = 0.0
        if delta < CGFLOAT_EPSILON {
            s = 0.0
        }
        else {
            s = delta / (1.0 - abs(2.0*l - 1.0))
        }
        
        // h:       0 - 360
        // s:       0 - 100
        // l:       0 - 100
        // alpha:   0 - 100
        return (Int32(h+0.5), Int32(s*100.0+0.5), Int32(l*100.0+0.5), alpha)
    }
    
    // red:     0 - 255
    // green:   0 - 255
    // blue:    0 - 255
    // alpha:   0 - 100
    static func rgb2hsb(red: Int32, green: Int32, blue: Int32, alpha: Int32) -> (Int32, Int32, Int32, Int32) {
        let r = CGFloat(red) / 255.0
        let g = CGFloat(green) / 255.0
        let b = CGFloat(blue) / 255.0
        
        let cmax = max(r, g, b)
        let cmin = min(r, g, b)
        let delta = cmax - cmin
        
        var hue = 0.0
        if delta < CGFLOAT_EPSILON {
            hue = 0.0
        }
        else {
            if fabs(cmax - r) < CGFLOAT_EPSILON {
                hue = fmod(60.0 * ((g - b) / delta) + 360.0, 360.0)
            }
            else if fabs(cmax - g) < CGFLOAT_EPSILON {
                hue = fmod(60.0 * ((b - r) / delta) + 120, 360.0)
            }
            else if fabs(cmax - b) < CGFLOAT_EPSILON {
                hue = fmod(60.0 * ((r - g) / delta) + 240.0, 360.0)
            }
        }
        
        var saturation = 0.0
        if cmax < CGFLOAT_EPSILON {
            saturation = 0.0
        }
        else {
            saturation = delta / cmax
        }
        
        let brightness = cmax
        
        // hue:         0 - 360
        // saturation:  0 - 100
        // brightness:  0 - 100
        // alpha:       0 - 100
        return (Int32(hue+0.5), Int32(saturation*100.0+0.5), Int32(brightness*100.0+0.5), alpha)
    }
    
    // hue:             0 - 360
    // saturation:      0 - 100
    // brightness:      0 - 100
    // alpha:           0 - 100
    static func hsb2rgb(hue: Int32, saturation: Int32, brightness: Int32, alpha: Int32) -> (Int32, Int32, Int32, Int32) {
        
        guard let wheelHues = wheelHues else {
            return  (Int32(0), Int32(0), Int32(0), alpha)
        }
        
        if (hue > 360 || hue < 0 || saturation > 100 || saturation < 0 || brightness > 100 || brightness < 0) {
            return (Int32(0), Int32(0), Int32(0), alpha)
        }
        
        let h = Int32(wheelHues[Int(hue)]*360)
        
        let s = CGFloat(saturation)/100.0
        let v = CGFloat(brightness)/100.0
        let C = s * v;
        let X = C * (1 - abs(fmod(CGFloat(h) / 60.0, 2) - 1))
        let m = v - C
        var r = 0.0
        var g = 0.0
        var b = 0.0
        
        if (h >= 0 && h < 60){
            r = C
            g = X
            b = 0
        }
        else if (h >= 60 && h < 120) {
            r = X
            g = C
            b = 0
        }
        else if (h >= 120 && h < 180) {
            r = 0
            g = C
            b = X
        }
        else if (h >= 180 && h < 240) {
            r = 0
            g = X
            b = C
        }
        else if (h >= 240 && h < 300) {
            r = X
            g = 0
            b = C
        }
        else {
            r = C
            g = 0
            b = X
        }
        let R = (r + m) * 255.0
        let G = (g + m) * 255.0
        let B = (b + m) * 255.0
        
        // R:       0 - 255
        // G:       0 - 255
        // B:       0 - 255
        // alpha:   0 - 100
        return (Int32(R+0.5), Int32(G+0.5), Int32(B+0.5), alpha)
    }
        
    // red:     0 - 255
    // green:   0 - 255
    // blue:    0 - 255
    // alpha:   0 - 100
    static func rgb2cmyk(red: Int32, green: Int32, blue: Int32, alpha: Int32) -> (Int32, Int32, Int32, Int32, Int32) {
        
        let r = CGFloat(red) / 255.0
        let g = CGFloat(green) / 255.0
        let b = CGFloat(blue) / 255.0
        
        let k = 1.0 - max(r, g, b)
        var c = 0.0
        var m = 0.0
        var y = 0.0
        
        if (fabs(k - 1.0) < CGFLOAT_EPSILON) {
            c = 0.0
            m = 0.0
            y = 0.0
        }
        else {
            c = (1.0 - r - k) / (1.0 - k)
            m = (1.0 - g - k) / (1.0 - k)
            y = (1.0 - b - k) / (1.0 - k)
        }
        
        // c:       0 - 100
        // m:       0 - 100
        // y:       0 - 100
        // k:       0 - 100
        // alpha:   0 - 100
        return (Int32(c*100+0.5), Int32(m*100+0.5), Int32(y*100+0.5), Int32(k*100+0.5), alpha)
    }
    
    static func jsonString(from scheme: ColorScheme, type: String, name: String?) -> String? {
        
        var idString = ""
        if let name = name {
            idString = name
        }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            idString = formatter.string(from: Date())
        }
        
        var string = "{\"Coloury_\(idString)\":["
        
        for i in 0 ..< scheme.items.count {
            let item = scheme.items[i]
            if type.caseInsensitiveCompare("hex") == .orderedSame {
                string += "\"\(item.hexString())\""
            }
            else if type.caseInsensitiveCompare("rgb") == .orderedSame {
                string += "\"\(item.rgbString())\""
            }
            else if type.caseInsensitiveCompare("ryb") == .orderedSame {
                string += "\"\(item.rybString())\""
            }
            else if type.caseInsensitiveCompare("hsl") == .orderedSame {
                string += "\"\(item.hslString())\""
            }
            else if type.caseInsensitiveCompare("hsb") == .orderedSame {
                string += "\"\(item.hsbString())\""
            }
            else if type.caseInsensitiveCompare("cmyk") == .orderedSame {
                string += "\"\(item.cmykString())\""
            }
            
            if i < scheme.items.count - 1 {
                string += ","
            }
            
        }
        string += "]}"
        
        if let data = string.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return String(decoding: jsonData, as:UTF8.self)
        }
        
        return string
    }
    
    // Adobe Swatch Exchange (ase) data
    static func aseData(from scheme: ColorScheme, name: String?) -> Data? {
        var idString = ""
            if let name = name {
            idString = name
        }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            idString = formatter.string(from: Date())
        }
        
        var colors:[PAL.Color] = []
        for i in 0 ..< scheme.items.count {
            let item = scheme.items[i]
            if let red = item.red, let green = item.green, let blue = item.blue {
                let color = PAL.Color.rgb(name: "",   Float32(red)/255.0, Float32(green)/255.0, Float32(blue)/255.0)
                colors.append(color)
            }
        }
        let palette = PAL.Palette(name: idString, colors: colors)
        // Create an ASE coder
        let coder = PAL.Coder.ASE()
        
        // Get the .ase format data
        let data = try? coder.encode(palette)
        
        return data
    }
    
    // Procreate Swatches data
    static func procreateSwatches(from scheme: ColorScheme, name: String?) -> Data? {
        var idString = ""
        if let name = name {
            idString = name
        }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            idString = "Coloury_" + formatter.string(from: Date())
        }
        
        var string = "[{"
        string += "\"name\" : \"\(idString)\","
        
        string += "\"swatches\" : ["
        
        for i in 0 ..< scheme.items.count {
            let item = scheme.items[i]
            
            if let red = item.red, let green = item.green, let blue = item.blue, let alpha = item.alpha {
                let hsb = rgb2hsb(red: red, green: green, blue: blue, alpha: alpha)
                let hue = CGFloat(hsb.0)/360.0
                let saturation = CGFloat(hsb.1)/100.0
                let brightness = CGFloat(hsb.2)/100.0
                string += "{\"hue\" : \"\(hue)\", \"saturation\" : \"\(saturation)\", \"brightness\" : \"\(brightness)\"},"
            }
        }
        
        // remove last ',' in json array string
        if (string.last == ",") {
            string.removeLast()
        }
        
        
        string += "]"
        string += "}]"
        
        if let data = string.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
           return jsonData
        }
        
        return nil
    }
    
    static func plainText(from scheme: ColorScheme, type: String) -> String? {
        var string = ""
        
        for i in 0 ..< scheme.items.count {
            let item = scheme.items[i]
            if type.caseInsensitiveCompare("hex") == .orderedSame {
                string += item.hexString()
            }
            else if type.caseInsensitiveCompare("rgb") == .orderedSame {
                string += item.rgbString()
            }
            else if type.caseInsensitiveCompare("ryb") == .orderedSame {
                string += item.rybString()
            }
            else if type.caseInsensitiveCompare("hsl") == .orderedSame {
                string += item.hslString()
            }
            else if type.caseInsensitiveCompare("hsb") == .orderedSame {
                string += item.hsbString()
            }
            else if type.caseInsensitiveCompare("cmyk") == .orderedSame {
                string += item.cmykString()
            }
            string += "\n"
        }

        return string
    }
    
    static func createSchemeDiagram(from scheme: ColorScheme) -> UIImage? {
        let ratio = 4.0 / 3.0
        let width = 2048.0
        let height = width * ratio
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
        //let context = UIGraphicsGetCurrentContext()
        
        let insets0 = UIEdgeInsets(top: height*0.02, left: width*0.02, bottom: height*0.15, right: width*0.02)
        let backgroundRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let contentRect = CGRect(x: insets0.left, y: insets0.top, width: width-insets0.left-insets0.right, height: height-insets0.top-insets0.bottom)
        
        var itemWidth = 0.0
        var itemHeight = 0.0
        if (scheme.items.count == 5) {
            itemWidth = contentRect.width / 3.0
            itemHeight = contentRect.height / 2.0
        }
        else if (scheme.items.count == 10) {
            itemWidth = contentRect.width / 5.0
            itemHeight = contentRect.height / 2.0
        }
        else if (scheme.items.count == 15) {
            itemWidth = contentRect.width / 5.0
            itemHeight = contentRect.height / 3.0
        }
        else if (scheme.items.count == 20) {
            itemWidth = contentRect.width / 5.0
            itemHeight = contentRect.height / 4.0
        }
        
        let itemPerRow = Int(contentRect.width / itemWidth)
        let background = UIBezierPath(rect: backgroundRect)
        let backgroundColor = UIColor(hex: "#FFFFFF")
        
        let content = UIBezierPath(rect: contentRect)
        let contentBackgroundColor = UIColor(hex: "#FFFFFF")
        
        backgroundColor.setFill()
        background.fill()
        
        contentBackgroundColor.setFill()
        content.fill()
        
        for i in 0 ..< scheme.items.count {
            let item = scheme.items[i]
            
            let x = contentRect.origin.x + CGFloat(i % itemPerRow) * itemWidth
            let y = contentRect.origin.y + CGFloat(i / itemPerRow) * itemHeight
            let itemRect = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            let insets1 = UIEdgeInsets(top: height*0.005, left: width*0.01, bottom: height*0.01, right: width*0.01)
            
            var ratio = 1.0
            if (scheme.items.count == 5) {
                ratio = 0.7
            }
            else if (scheme.items.count == 10) {
                ratio = 0.45
            }
            else if (scheme.items.count == 15) {
                ratio = 0.6
            }
            else if (scheme.items.count == 20) {
                ratio = 0.55
            }
            
            // draw color rect
            let colorRect = CGRect(x: itemRect.origin.x + insets1.left, y: itemRect.origin.y, width: itemRect.size.width-insets1.left-insets1.right, height: itemRect.size.height*ratio)
            let colorPath = UIBezierPath(rect: colorRect)
            let color = UIColor(colorItem: item)
            
            UIColor.black.setStroke()
            color.setFill()
            colorPath.fill()
            
            // if color is too light to be almost white, we draw the outline
            var saturation: CGFloat = 0.0
            var brightness: CGFloat = 0.0
            color.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: nil)
            if (saturation <= 0.05 && brightness >= 0.95) {
                colorPath.lineWidth = 2.0
                colorPath.stroke()
            }
            
            
            // draw value info
            let infoRect = CGRect(x: itemRect.origin.x + insets1.left, y: colorRect.origin.y + colorRect.size.height + insets1.top, width: itemRect.size.width-insets1.left-insets1.right, height: itemRect.size.height*(1-ratio) - insets1.top - insets1.bottom)
            
            //let info = UIBezierPath(rect: infoRect)
            //UIColor(hex: "#121212").setFill()
            //info.fill()
            
            let insets2 = UIEdgeInsets(top: width*0.005, left: width*0.005, bottom: width*0.005, right: width*0.005)
            
            // draw hex string
            let hexString = item.hexString()
            var hexStringFont = UIFont(name: "Arial Bold", size: 38.0)
            if hexStringFont == nil {
                hexStringFont = UIFont.boldSystemFont(ofSize: 38.0)
            }
            
            let hexStringRect = CGRect(x: infoRect.origin.x, y: infoRect.origin.y, width: infoRect.size.width, height: hexStringFont!.ascender + abs(hexStringFont!.descender))
            
            let hexFontAttributes = [
                NSAttributedString.Key.font: hexStringFont,
                NSAttributedString.Key.foregroundColor: UIColor(hex: "#000000"),
            ]
            (hexString as NSString).draw(in: hexStringRect, withAttributes: hexFontAttributes as [NSAttributedString.Key : Any])
            
            // draw rgb string
            let rgbString = item.rgbString()
            var rgbStringFont = UIFont(name: "Menlo", size: 20.0)
            if rgbStringFont == nil {
                rgbStringFont = UIFont.systemFont(ofSize: 20.0)
            }
            
            let rgbStringRect = CGRect(x: hexStringRect.origin.x, y: hexStringRect.origin.y + hexStringRect.height + insets2.top, width:  hexStringRect.size.width, height: rgbStringFont!.ascender + abs(rgbStringFont!.descender))
            
            let rgbFontAttributes = [
                NSAttributedString.Key.font: rgbStringFont,
                NSAttributedString.Key.foregroundColor: UIColor(hex: "#000000"),
            ]
            (rgbString as NSString).draw(in: rgbStringRect, withAttributes: rgbFontAttributes as [NSAttributedString.Key : Any])
            
            // draw ryb string
            let rybString = item.rybString()
            var rybStringFont = UIFont(name: "Menlo", size: 20.0)
            if rybStringFont == nil {
                rybStringFont = UIFont.systemFont(ofSize: 20.0)
            }
                
            let rybStringRect = CGRect(x: rgbStringRect.origin.x, y: rgbStringRect.origin.y + rgbStringRect.height + insets2.top, width: rgbStringRect.size.width, height: rybStringFont!.ascender + abs(rybStringFont!.descender))
            
            let rybFontAttributes = [
                NSAttributedString.Key.font: rybStringFont,
                NSAttributedString.Key.foregroundColor: UIColor(hex: "#000000"),
            ]
            (rybString as NSString).draw(in: rybStringRect, withAttributes: rybFontAttributes as [NSAttributedString.Key : Any])
            
            
            // draw hsl string
            let hslString = item.hslString()
            var hslStringFont = UIFont(name: "Menlo", size: 20.0)
            if hslStringFont == nil {
                hslStringFont = UIFont.systemFont(ofSize: 20.0)
            }
            
            let hslStringRect = CGRect(x: rybStringRect.origin.x, y: rybStringRect.origin.y + rybStringRect.height + insets2.top, width: rybStringRect.size.width, height:hslStringFont!.ascender + abs(hslStringFont!.descender))
            
            let hslFontAttributes = [
                NSAttributedString.Key.font: hslStringFont,
                NSAttributedString.Key.foregroundColor: UIColor(hex: "#000000"),
            ]
            (hslString as NSString).draw(in: hslStringRect, withAttributes: hslFontAttributes as [NSAttributedString.Key : Any])

            
            // draw hsb string
            let hsbString = item.hsbString()
            var hsbStringFont = UIFont(name: "Menlo", size: 20.0)
            if hsbStringFont == nil {
                hsbStringFont = UIFont.systemFont(ofSize: 20.0)
            }
            
            let hsbStringRect = CGRect(x: hslStringRect.origin.x, y: hslStringRect.origin.y + hslStringRect.height + insets2.top, width: hslStringRect.size.width, height: hsbStringFont!.ascender + abs(hsbStringFont!.descender))
            
            let hsbFontAttributes = [
                NSAttributedString.Key.font: hsbStringFont,
                NSAttributedString.Key.foregroundColor: UIColor(hex: "#000000"),
            ]
            (hsbString as NSString).draw(in: hsbStringRect, withAttributes: hsbFontAttributes as [NSAttributedString.Key : Any])
                        
            // draw cmyk string
            let cmykString = item.cmykString()
            var cmykStringFont = UIFont(name: "Menlo", size: 20.0)
            if cmykStringFont == nil {
                cmykStringFont = UIFont.systemFont(ofSize: 20.0)
            }
                
            let cmykStringRect = CGRect(x: hsbStringRect.origin.x, y: hsbStringRect.origin.y + hsbStringRect.height + insets2.top, width: hsbStringRect.size.width, height: cmykStringFont!.ascender + abs(cmykStringFont!.descender))
            
            let cmykFontAttributes = [
                NSAttributedString.Key.font: cmykStringFont,
                NSAttributedString.Key.foregroundColor: UIColor(hex: "#000000"),
            ]
            (cmykString as NSString).draw(in: cmykStringRect, withAttributes: cmykFontAttributes as [NSAttributedString.Key : Any])
        }
        
        if let footer = UIImage(named: "icon-app-footer") {
            let footerWidth = width * 0.05
            let footerHeight = height * 0.05
            let widthRatio  = footerWidth  / footer.size.width
            let heightRatio = footerHeight / footer.size.height
            
            var footerSize: CGSize
            if (widthRatio < heightRatio) {
                footerSize = CGSize(width: footer.size.width * heightRatio, height: footer.size.height * heightRatio)
            }
            else {
                footerSize = CGSize(width: footer.size.width * widthRatio, height: footer.size.height * widthRatio)
            }
            
            let footerOrigin = CGPoint(x: width - width*0.02 - footerSize.width, y: height-footerSize.height-(height*0.02))
            
            UIColor.black.setFill()
            footer.draw(in: CGRect(origin: footerOrigin, size: footerSize))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func amp2Val(_ amplitude: CGFloat, _ range: CGFloat) -> Int32 {
        return Int32(amplitude*range+0.5)
    }
    
    
    static func val2Amp(_ value: Int32, _ range: CGFloat) -> CGFloat {
        return CGFloat(value)/range
    }
    
    static func createColorWheelImage(hues: Array<CGFloat>?, radius: CGFloat) -> UIImage? {
        guard let hues = hues else {
            return nil
        }
        
        let size = CGSize(width: radius*2.0, height: radius*2.0)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        UIGraphicsGetCurrentContext()
        
        let ad = Measurement(value: Double(2.0), unit: UnitAngle.degrees)
        let ar = Float(ad.converted(to: .radians).value)

        let translateMatrix = ColorFunction.makeTranslationMatrix(tx: Float(size.width/2.0), ty: Float(size.height/2.0))
        
        // hue range: [0, 360]
        for h in 0 ..< hues.count {
            let angle = Measurement(value: Double(h), unit: UnitAngle.degrees)
            let radians = Float(-angle.converted(to: .radians).value)
            let rotationMatrix = ColorFunction.makeRotationMatrix(angle: radians)
            let k = radius / CGFloat(numberOfSaturation)
            
            // saturation range: [0, 100]
            for s in 0 ..< numberOfSaturation {
                let x0 = 0.0
                let y0 = 0.0
                let x1 = x0 + radius-CGFloat(s)*k
                let x2 = x0 + radius-CGFloat(s)*k
                let y1 = y0 + radius*tan(CGFloat(-ar)/2)
                let y2 = y0 + radius*tan(CGFloat(ar)/2)

                let pv0 = simd_float3(x: Float(x0), y: Float(y0), z: 1.0)
                let pv1 = simd_float3(x: Float(x1), y: Float(y1), z: 1.0)
                let pv2 = simd_float3(x: Float(x2), y: Float(y2), z: 1.0)

                let pvr0 = translateMatrix*(rotationMatrix * pv0)
                let pvr1 = translateMatrix*(rotationMatrix * pv1)
                let pvr2 = translateMatrix*(rotationMatrix * pv2)

                let path = UIBezierPath()
                path.move(to: CGPoint(x: CGFloat(pvr0.x), y: CGFloat(pvr0.y)))
                path.addLine(to: CGPoint(x: CGFloat(pvr1.x), y: CGFloat(pvr1.y)))
                path.addLine(to: CGPoint(x: CGFloat(pvr2.x), y: CGFloat(pvr2.y)))
                path.close()

                let saturation = 1.0 - CGFloat(s)*0.01
                UIColor(hue: hues[h], saturation: saturation, brightness: 1.0, alpha: 1.0).setFill()
                path.fill()

            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func makeTranslationMatrix(tx: Float, ty: Float) -> simd_float3x3 {
        var matrix = matrix_identity_float3x3
        
        matrix[2, 0] = tx
        matrix[2, 1] = ty
        
        return matrix
    }
    
    static func makeRotationMatrix(angle: Float) -> simd_float3x3 {
        let rows = [
            simd_float3(cos(angle), -sin(angle), 0),
            simd_float3(sin(angle), cos(angle), 0),
            simd_float3(0,          0,          1)
        ]
        
        return float3x3(rows: rows)
    }
    
    
    enum HueRotateDirection {
        case clockwise
        case antiClockwise
    }
    
    private static func hueDistanceClockwise(from a: Int32, to b: Int32) -> Int32 {
        var _a: Int32 = a % 361
        var _b: Int32 = b % 361
        
        if (_a < 0) {
            _a = 360 - abs(_a)
        }

        if (_b < 0) {
            _b = 360 - abs(_b)
        }
        
        var distance: Int32 = 0

        if (_a >= _b) {
            distance = _a - _b
        }
        else {
            distance = _a + (361 - b)
        }
        
        return distance
    }
    
    private  static func hueDistanceAntiClockwise(from a: Int32, to b: Int32) -> Int32 {
        var _a: Int32 = a % 361
        var _b: Int32 = b % 361

        if (_a < 0) {
            _a = 360 - abs(_a)
        }

        if (_b < 0) {
            _b = 360 - abs(_b)
        }

        var distance: Int32 = 0

        if (_a <= _b) {
            distance = _b - _a
        }
        else {
            distance = _b + (361 - a)
        }
        
        return distance
    }
    
    static func hueDistance(from a: Int32, to b: Int32, in direction: HueRotateDirection) -> Int32 {
        switch (direction) {
        case .clockwise:
            return hueDistanceClockwise(from: a, to: b)
        case .antiClockwise:
            return hueDistanceAntiClockwise(from: a, to: b)
        }
    }
    
    private  static func hueRotateClockwise(from a: Int32, with distance: Int32) -> Int32 {
        var hue = a - distance
        if (hue > 360) {
            hue %= 361
        }
        if (hue < 0) {
            hue = 361 - abs((hue%361))
        }
        return hue
    }
    
    private static func hueRotateAntiClockwise(from a: Int32, with distance: Int32) -> Int32 {
        var hue = a + distance
        if (hue > 360) {
            hue %= 361
        }
        if (hue < 0) {
            hue = 361 - abs((hue%361))
        }
        return hue
    }
    
    static func hueRotate(from a: Int32, with distance: Int32, in direction: HueRotateDirection) -> Int32 {
        switch (direction) {
        case .clockwise:
            return hueRotateClockwise(from: a, with: distance)
        case .antiClockwise:
            return hueRotateAntiClockwise(from: a, with: distance)
        }
    }
    
}
