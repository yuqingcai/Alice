//
//  ComposeModel.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/6.
//

import Foundation

class ComposeModel: NSObject {
    static var schemeSize: Int = 5
    static let keyColorIndex: Int = 2
    
    var scheme: ColorScheme
    var saturationStates: Array<Bool> = [ false, false, false, false, false ]
    var brightnessStates: Array<Bool> = [ false, false, false, false, false ]
    
    override init() {
        let items = [
            ColorItem(hue: 0, saturation: 20, brightness: 100, alpha: 100, weight: 100),
            ColorItem(hue: 0, saturation: 40, brightness: 100, alpha: 100, weight: 100),
            ColorItem(hue: 0, saturation: 60, brightness: 100, alpha: 100, weight: 100),
            ColorItem(hue: 0, saturation: 80, brightness: 100, alpha: 100, weight: 100),
            ColorItem(hue: 0, saturation: 100, brightness: 100, alpha: 100, weight: 100)
        ]
        scheme = ColorScheme(items: items)
        super.init()
    }
    
    func getCurrentHues() -> Array<Int32> {
        var hues: Array<Int32> = []
        for item in scheme.items {
            if let hue = item.hue {
                hues.append(hue)
            }
            else {
                hues.append(0)
            }
        }
        return hues
    }
    
    func getCurrentSaturations() -> Array<Int32> {
        var saturations: Array<Int32> = []
        for item in scheme.items {
            if let saturation = item.saturation {
                saturations.append(saturation)
            }
            else {
                saturations.append(0)
            }
        }
        return saturations
    }
        
    func getCurrentBrightnesses() -> Array<Int32> {
        var brightnesses: Array<Int32> = []
        for item in scheme.items {
            if let brightness = item.brightness {
                brightnesses.append(brightness)
            }
            else {
                brightnesses.append(0)
            }
        }
        return brightnesses
    }
    
    func modifyReflectValue(value: Int32, distance: Int32, reflected: UnsafeMutablePointer<Bool>, range: ClosedRange<Int32>) -> Int32 {
       
        var changed: Int32 = 0
       
        if reflected.pointee == false {
            if value + distance < range.lowerBound {
                changed = abs(value + distance)
                reflected.pointee = true
            }
            else if value + distance > range.upperBound {
                changed = range.upperBound - (value + distance - range.upperBound)
                reflected.pointee = true
            }
            else {
                changed = value + distance
            }
        }
        else {
            if value - distance < range.lowerBound {
                changed = abs(value - distance)
                reflected.pointee = false
            }
            else if value - distance > range.upperBound {
                changed = range.upperBound - (value - distance - range.upperBound)
                reflected.pointee = false
            }
            else {
                changed = value - distance
            }
            
        }
        return changed
    }
    
    func difference(to target: Int32, with distance: Int32, in range: ClosedRange<Int32>) -> Int32 {
        var value: Int32 = target + distance
        
        if value < range.lowerBound {
            if target + abs(distance) <= range.upperBound {
                value = target + abs(distance)
            }
            else {
                value = range.lowerBound
            }
        }
        else if value > range.upperBound {
            if target - abs(distance) >= range.lowerBound {
                value = target - abs(distance)
            }
            else {
                value = range.upperBound
            }
        }
        return value
    }
            
    func reset(hue: Int32, saturation: Int32, brightness: Int32) -> ColorScheme {
        let items = [
            ColorItem(hue: hue, saturation: saturation, brightness: brightness, alpha: 100, weight: 100),
            ColorItem(hue: hue, saturation: saturation, brightness: brightness, alpha: 100, weight: 100),
            ColorItem(hue: hue, saturation: saturation, brightness: brightness, alpha: 100, weight: 100),
            ColorItem(hue: hue, saturation: saturation, brightness: brightness, alpha: 100, weight: 100),
            ColorItem(hue: hue, saturation: saturation, brightness: brightness, alpha: 100, weight: 100)
        ]
        scheme = ColorScheme(items: items)
        return scheme
    }
    
    func generate(selector: Int, hue: Int32?, saturation: Int32?, brightness: Int32?) -> ColorScheme {
        let hues: Array<Int32> = createHues(selector, hue)
        let saturations: Array<Int32> = createSaturations(selector, saturation)
        let brightnesses: Array<Int32> = createBrightnesses(selector, brightness)
        
        var items: Array<ColorItem> = []
        for i in 0 ..< ComposeModel.schemeSize {
            items.append(ColorItem(hue: hues[i], saturation: saturations[i], brightness: brightnesses[i], alpha: 100, weight: 100))
        }
        scheme = ColorScheme(items: items)
        return scheme
    }
    
    func createHues(_ selector: Int, _ hue: Int32?) -> Array<Int32> {
        return getCurrentHues()
    }
    
    func createSaturations(_ selector: Int, _ saturation: Int32?) -> Array<Int32> {
        
        guard let saturation = saturation else {
            return getCurrentSaturations()
        }
        
        // keyColorIndex is 2
        guard let keySaturation = scheme.items[2].saturation else {
            return getCurrentSaturations()
        }
        
        if (selector < 0 || selector >= ComposeModel.schemeSize) {
            return getCurrentSaturations()
        }
        
        var saturations = getCurrentSaturations()
        
        if (selector == 2) {
            saturations[selector] = saturation
            
            let distance = saturation - keySaturation
            
            saturations[0] = modifyReflectValue(value: saturations[0], distance: distance, reflected: &saturationStates[0], range: 0...100)
            saturations[1] = modifyReflectValue(value: saturations[1], distance: distance, reflected: &saturationStates[1], range: 0...100)
            saturations[3] = modifyReflectValue(value: saturations[3], distance: distance, reflected: &saturationStates[3], range: 0...100)
            saturations[4] = modifyReflectValue(value: saturations[4], distance: distance, reflected: &saturationStates[4], range: 0...100)
        }
        else {
            saturations[selector] = saturation
            saturationStates[selector] = false
        }
                
        return saturations
    }
    
    func createBrightnesses(_ selector: Int, _ brightness: Int32?) -> Array<Int32> {
        
        guard let brightness = brightness else {
            return getCurrentBrightnesses()
        }
        
        guard let keyBrightness = scheme.items[2].brightness else {
            return getCurrentBrightnesses()
        }
        
        if (selector < 0 || selector >= ComposeModel.schemeSize) {
            return getCurrentBrightnesses()
        }
        
        var brightnesses = getCurrentBrightnesses()
        
        if (selector == 2) {
            brightnesses[selector] = brightness
            
            let distance = brightness - keyBrightness
            
            brightnesses[0] = modifyReflectValue(value: brightnesses[0], distance: distance, reflected: &brightnessStates[0], range: 0...100)
            brightnesses[1] = modifyReflectValue(value: brightnesses[1], distance: distance, reflected: &brightnessStates[1], range: 0...100)
            brightnesses[3] = modifyReflectValue(value: brightnesses[3], distance: distance, reflected: &brightnessStates[3], range: 0...100)
            brightnesses[4] = modifyReflectValue(value: brightnesses[4], distance: distance, reflected: &brightnessStates[4], range: 0...100)
        }
        else {
            brightnesses[selector] = brightness
            brightnessStates[selector] = false
        }
        
        return brightnesses
    }
    
}

