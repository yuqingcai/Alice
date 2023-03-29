//
//  ColorIndexView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/11.
//

import UIKit
import simd

class ColorWheelSelector: UIView {
    
    var defaultSize: CGSize?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultSize = frame.size
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultSize = frame.size
        backgroundColor = UIColor.clear
    }
    
    var color: UIColor = UIColor.white
    {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isKey: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isActived: Bool = false
    {
        didSet {
            if let defaultSize = defaultSize {
                let c0 = center
                var size = defaultSize
                
                if (isActived == true) {
                    size.width *= 1.5
                    size.height *= 1.5
                }
                
                frame.size = size
                center = c0
            }
            setNeedsDisplay()
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        var space: CGFloat = rect.width / 5.0
        var lineWidth = 3.0
        
        if (isActived) {
            space = rect.width / 10.0
            lineWidth = 5.0
        }
        else {
            space = rect.width / 5.0
            lineWidth = 3.0
        }
        
        let knob = UIBezierPath(ovalIn: CGRectInset(rect, space, space))
        UIColor(named: "color-wheel-selector-outline")?.setStroke()
        color.setFill()
        knob.lineWidth = lineWidth
        knob.stroke()
        knob.fill()
        
        if (isKey) {
            let radius = lineWidth * 0.5
            let rect = CGRect(origin: CGPoint(x: (rect.width - radius*2.0)*0.5, y: (rect.height - radius*2.0)*0.5), size: CGSize(width: radius*2.0, height: radius*2.0))
            let dot = UIBezierPath(ovalIn: rect)
            UIColor(named: "color-wheel-selector-outline")?.setFill()
            dot.fill()
        }
    }
}

class BrightnessView: UIView {
    
    private let ratio = 0.8
    private let barHeight = 8.0
    
    var gradientColor: UIColor = UIColor.white
    {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func selectorPosition(with value: CGFloat) -> CGPoint {
        let barWidth = frame.size.width * ratio
        
        if value < 0.0 || value > 100.0 {
            return CGPoint(x: 0.0, y: 0.0)
        }
        return CGPoint(x: ((frame.size.width - barWidth) * 0.5) + ((barWidth/100.0) * value), y: (frame.size.height - barHeight) * 0.5 + barHeight * 0.5)
    }
       
    
    override func draw(_ rect: CGRect) {
        let barWidth = frame.size.width * ratio
        
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        gradientColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        let startColor = UIColor(hue: hue, saturation: 1.0, brightness: 0.0, alpha: 1.0)
        let endColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        
        let pathRect = CGRect(x: (frame.size.width - barWidth) * 0.5, y: (frame.size.height - barHeight) * 0.5, width: barWidth, height: barHeight)
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: pathRect.size.height*0.5)
                
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()
        defer { ctx.restoreGState() } // clean up graphics state changes when the method returns

        path.addClip() // use the path as the clipping region
        
        let colors = [startColor, endColor]
        let cgColors = colors.map({ $0.cgColor })
        guard let gradient = CGGradient(colorsSpace: nil, colors: cgColors as CFArray, locations: nil)
            else { return }

        ctx.drawLinearGradient(gradient, start: CGPoint(x: pathRect.origin.x, y: pathRect.origin.y), end: CGPoint(x: pathRect.origin.x + pathRect.size.width, y: pathRect.origin.y), options: [])
    }
    
    func validate(location: CGPoint) -> CGPoint {
        let barWidth = frame.size.width * ratio
        
        let space = (frame.size.width - barWidth)*0.5
        var p1 = location
        
        p1.y = frame.size.height*0.5
        
        if (p1.x < space) {
            p1.x = space
        }
        else if (location.x > space + barWidth) {
            p1.x = space + barWidth
        }
        
        return p1
    }
    
    func value(from location: CGPoint) -> CGFloat {
        let validated = validate(location: location)
        let barWidth = frame.size.width * ratio
        let space = (frame.size.width - barWidth)*0.5
        return (validated.x - space) / barWidth
    }
}


class ColorWheelView: UIView {
    
    private class ColorContent: UIView {
        private var image: UIImage?
        
        var hues: Array<CGFloat>? {
            didSet {
                update()
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.cornerRadius = frame.size.width*0.5
            clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            layer.cornerRadius = 0.0
            clipsToBounds = true
        }
        
        init(frame: CGRect, hues: Array<CGFloat>?) {
            self.hues = hues
            super.init(frame: frame)
            layer.cornerRadius = frame.size.width*0.5
            clipsToBounds = true
        }
        
        override var frame: CGRect {
            didSet {
                layer.cornerRadius = frame.size.width*0.5
                setNeedsDisplay()
            }
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            if let image = image {
                image.draw(at: CGPointZero)
            }
        }
        
        func update() {
            image = ColorFunction.createColorWheelImage(hues: hues, radius: self.bounds.size.width*0.5)
            setNeedsDisplay()
        }
    }
    
    private class PathMask: UIView {
        var locations: Array<CGPoint>? {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            
            if let locations = locations {
                
//                let path = UIBezierPath()
//                UIColor.white.setStroke()
//                path.lineWidth = 1.5
//                path.move(to: CGPoint(x: locations[0].x, y: locations[0].y))
//                for i in 1 ..< locations.count {
//                    let location = locations[i]
//                    path.addLine(to: CGPoint(x: location.x, y: location.y))
//                    path.stroke()
//                }
                
                for location in locations {
                    let bounds = self.bounds
                    let path = UIBezierPath()

                    path.move(to: CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0))
                    path.addLine(to: CGPoint(x: location.x, y: location.y))
                    path.close()

                    UIColor.white.setStroke()
                    path.lineWidth = 1.5
                    path.stroke()

                }
            }
            
            
        }
    }
    
    var brightness: CGFloat = 1.0 {
        didSet {
            if let brightnessMask = brightnessMask {
                brightnessMask.layer.opacity = Float(1.0 - brightness)
            }
        }
    }
    
    var hues: Array<CGFloat>? {
        didSet {
            if let colorContent = colorContent {
                colorContent.hues = hues
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            if (abs(oldValue.size.width - bounds.size.width) < CGFLOAT_EPSILON &&
                abs(oldValue.size.height - bounds.size.height) < CGFLOAT_EPSILON) {
                return
            }
            
            let space = 0.0
            let rect = CGRect(x: space, y: space, width: frame.size.width - (space*2.0), height: frame.size.width - (space*2.0))
            
            if let colorContent = colorContent {
                colorContent.frame = rect
                colorContent.update()
            }
            
            if let brightnessMask = brightnessMask {
                brightnessMask.frame = rect
                brightnessMask.layer.cornerRadius = brightnessMask.frame.size.width * 0.5
            }
            
            
            if let pathMask = pathMask {
                pathMask.frame = rect
                pathMask.layer.cornerRadius = pathMask.frame.size.width * 0.5
            }
        }
    }
    
    private var colorContent: ColorContent?
    private var brightnessMask: UIView?
    private var pathMask: PathMask?
    
    func setPathLocations(locations: Array<CGPoint>) {
        if let pathMask = pathMask {
            pathMask.locations = locations
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createSubviews(nil)
    }
    
    init(frame: CGRect, hues: Array<CGFloat>) {
        super.init(frame: frame)
        createSubviews(hues)
    }
    
    func createSubviews(_ hues: Array<CGFloat>?) {
        let space = 0.0
        let rect = CGRect(x: space, y: space, width: frame.size.width - (space*2.0), height: frame.size.width - (space*2.0))
        
        colorContent = ColorContent(frame: rect, hues: hues)
        brightnessMask = UIView(frame: rect)
        pathMask = PathMask(frame: rect)
        
        if let colorContent = colorContent, let brightnessMask = brightnessMask, let pathMask = pathMask {
            addSubview(colorContent)
            
            insertSubview(brightnessMask, aboveSubview: colorContent)
            brightnessMask.layer.cornerRadius = brightnessMask.frame.size.width * 0.5
            brightnessMask.clipsToBounds = true
            brightnessMask.backgroundColor = UIColor.black
            brightnessMask.layer.opacity = 0.0
            
            insertSubview(pathMask, aboveSubview: brightnessMask)
            pathMask.layer.cornerRadius = brightnessMask.frame.size.width * 0.5
            pathMask.clipsToBounds = true
            pathMask.backgroundColor = UIColor.clear
            pathMask.layer.opacity = 1.0
        }
    }
    
    func validateColorWheelLocation(p0: CGPoint) -> CGPoint {
        let center: CGPoint = CGPoint(x: frame.size.width*0.5, y: frame.size.height*0.5)
        let radius: CGFloat = frame.size.width*0.5
        
        var p1 = CGPoint(x: p0.x - center.x, y: p0.y - center.y)
        p1.y *= -1.0
        
        var p2 = CGPoint(x: 0.0, y: 0.0)
        
        if (abs(p1.y) < CGFLOAT_EPSILON && abs(p1.x) < CGFLOAT_EPSILON) {
            p2.y = 0.0
            p2.x = 0.0
        }
        else if (abs(p1.y) < CGFLOAT_EPSILON && p1.x > 0) {
            p2.y = 0.0
            p2.x = p1.x
            if (p2.x > radius) {
                p2.x = radius
            }
        }
        else if (abs(p1.x) < CGFLOAT_EPSILON && p1.y > 0) {
            p2.x = 0.0
            p2.y = p1.y
            if (p2.y > radius) {
                p2.y = radius
            }
        }
        else if (abs(p1.y) < CGFLOAT_EPSILON && p1.x < 0) {
            p2.y = 0.0
            p2.x = p1.x
            if (p2.x < -radius) {
                p2.x = -radius
            }
        }
        else if (abs(p1.x) < CGFLOAT_EPSILON && p1.y < 0) {
            p2.x = 0.0
            p2.y = p1.y
            if (p2.y < -radius) {
                p2.y = -radius
            }
        }
        else {
            var hue = rad2deg(atan(p1.y/p1.x))
            
            if (p1.x > 0 && p1.y > 0) {
                p2 = p1
                let rad = deg2rad(hue)
                let x = radius * cos(rad)
                let y = radius * sin(rad)
                if (p2.x > x) {
                    p2.x = x
                }
                if (p2.y > y) {
                    p2.y = y
                }
            }
            else if (p1.x < 0 && p1.y > 0) {
                hue += 180.0
                
                p2 = p1
                let rad = deg2rad(hue)
                let x = radius * cos(rad)
                let y = radius * sin(rad)
                if (p2.x < x) {
                    p2.x = x
                }
                if (p2.y > y) {
                    p2.y = y
                }
            }
            else if (p1.x < 0 && p1.y < 0) {
                hue += 180
                
                p2 = p1
                let rad = deg2rad(hue)
                let x = radius * cos(rad)
                let y = radius * sin(rad)
                if (p2.x < x) {
                    p2.x = x
                }
                if (p2.y < y) {
                    p2.y = y
                }
            }
            else if (p1.x > 0 && p1.y < 0) {
                hue += 360
                
                p2 = p1
                let rad = deg2rad(hue)
                let x = radius * cos(rad)
                let y = radius * sin(rad)
                if (p2.x > x) {
                    p2.x = x
                }
                if (p2.y < y) {
                    p2.y = y
                }
            }
        }
        
        p2.y *= -1
        p2.x += center.x
        p2.y += center.y
        
        return p2
    }
    
    func HSFrom(location: CGPoint) -> (Int32, Int32) {
        let validated = validateColorWheelLocation(p0: location)
        let center: CGPoint = CGPoint(x: frame.size.width*0.5, y: frame.size.height*0.5)
        let radius: CGFloat = frame.size.width*0.5
        
        var p1 = CGPoint(x: validated.x - center.x, y: validated.y - center.y)
        p1.y *= -1.0
        
        var hue = 0.0
        var saturation = 0.0
        
        if (abs(p1.y) < CGFLOAT_EPSILON && abs(p1.x) < CGFLOAT_EPSILON) {
            hue = 0.0
            saturation = 0.0
        }
        else if (abs(p1.y) < CGFLOAT_EPSILON && p1.x > 0) {
            hue = 0.0
            saturation = abs(p1.x) / radius * 100.0
        }
        else if (abs(p1.x) < CGFLOAT_EPSILON && p1.y > 0) {
            hue = 90.0
            saturation = abs(p1.y) / radius * 100.0
        }
        else if (abs(p1.y) < CGFLOAT_EPSILON && p1.x < 0) {
            hue = 180.0
            saturation = abs(p1.y) / radius * 100.0
        }
        else if (abs(p1.x) < CGFLOAT_EPSILON && p1.y < 0) {
            hue = 270.0
            saturation = abs(p1.y) / radius * 100.0
        }
        else {
            hue = rad2deg(atan(p1.y/p1.x))
            if (p1.x > 0 && p1.y > 0) {
            }
            else if (p1.x < 0 && p1.y > 0) {
                hue += 180.0
            }
            else if (p1.x < 0 && p1.y < 0) {
                hue += 180.0
            }
            else if (p1.x > 0 && p1.y < 0) {
                hue += 360.0
            }
            
            saturation = (sqrt(pow(p1.x, 2) + pow(p1.y, 2)) / radius) * 100.0
        }
        
        return (Int32(hue + 0.5), Int32(saturation + 0.5))
    }
    
    func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    func locationFrom(HS: (Int32, Int32)) -> CGPoint {
        let center: CGPoint = CGPoint(x: frame.size.width*0.5, y: frame.size.height*0.5)
        let radius: CGFloat = frame.size.width*0.5
        
        let hue = HS.0
        let saturation = HS.1
        
        var x = 0.0
        var y = 0.0
        
        x = cos(deg2rad(Double(hue))) * radius * (CGFloat(saturation) / 100.0)
        y = sin(deg2rad(Double(hue))) * radius * (CGFloat(saturation) / 100.0)
        
        y *= -1.0
        x += center.x
        y += center.y
        
        return CGPoint(x: x, y: y)
    }
}
