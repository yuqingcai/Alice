//
//  Analogous.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/6.
//

import Foundation

class AnalogousModel: ComposeModel {
    let maxHueDistance: Int32 = 60
    let miniHueDistance: Int32 = 20
    
    override init() {
        super.init()
        let _ = reset(hue: 0, saturation: 100, brightness: 100)
    }
    
    override func reset(hue: Int32, saturation: Int32, brightness: Int32) -> ColorScheme {
        saturationStates = [ false, false, false, false, false ]
        brightnessStates = [ false, false, false, false, false ]
        
        let hueDistance: Int32 = 20
        
        // 5 hues
        let hues: Array<Int32> = [
            ColorFunction.hueRotate(from: hue, with: hueDistance*2, in: .antiClockwise),
            ColorFunction.hueRotate(from: hue, with: hueDistance,   in: .antiClockwise),
            hue,
            ColorFunction.hueRotate(from: hue, with: hueDistance,   in: .clockwise),
            ColorFunction.hueRotate(from: hue, with: hueDistance*2, in: .clockwise)
        ]
        
        // 5 saturations
        var saturations: Array<Int32> = Array(repeating: 0, count: hues.count)
        saturations[0] = difference(to: saturation, with: -5 , in: 0...100)
        saturations[1] = difference(to: saturation, with: -5 , in: 0...100)
        saturations[2] = difference(to: saturation, with:  0 ,  in: 0...100)
        saturations[3] = difference(to: saturation, with: -5 , in: 0...100)
        saturations[4] = difference(to: saturation, with: -5 , in: 0...100)
        
        // 5 brightnesses
        var brightnesses: Array<Int32> = Array(repeating: 0, count: hues.count)
        brightnesses[0] = difference(to: brightness, with: -20, in: 0...100)
        brightnesses[1] = difference(to: brightness, with:  10, in: 0...100)
        brightnesses[2] = difference(to: brightness, with:  0 , in: 0...100)
        brightnesses[3] = difference(to: brightness, with:  10, in: 0...100)
        brightnesses[4] = difference(to: brightness, with: -20, in: 0...100)
        
        var items: Array<ColorItem> = []
        for i in 0 ..< hues.count {
            items.append(ColorItem(hue: hues[i], saturation: saturations[i], brightness: brightnesses[i], alpha: 100, weight: 100))
        }
        scheme = ColorScheme(items: items)
        return scheme
    }
    
    override func createHues(_ selector: Int, _ hue: Int32?) -> Array<Int32> {
        guard let hue = hue else {
            return getCurrentHues()
        }
        
        if (selector < 0 || selector >= ComposeModel.schemeSize) {
            return getCurrentHues()
        }
                
        let currentHues = getCurrentHues()
        var hues = Array(repeating: Int32(0), count: ComposeModel.schemeSize)
        var hueDistance: Int32 = 0
        
        if (selector == 2) {
            hueDistance = ColorFunction.hueDistance(from: currentHues[0], to: currentHues[1], in: .clockwise)
            hues[0] = ColorFunction.hueRotate(from: hue, with: hueDistance*2, in: .antiClockwise)
            hues[1] = ColorFunction.hueRotate(from: hue, with: hueDistance, in: .antiClockwise)
            hues[2] = hue
            hues[3] = ColorFunction.hueRotate(from: hue, with: hueDistance, in: .clockwise)
            hues[4] = ColorFunction.hueRotate(from: hue, with: hueDistance*2, in: .clockwise)
        }
        else {
            let keyHue = currentHues[2]
            if (selector == 0) {
                hueDistance = ColorFunction.hueDistance(from: hue, to: keyHue, in: .clockwise)/2
            }
            else if (selector == 1) {
                hueDistance = ColorFunction.hueDistance(from: hue, to: keyHue, in: .clockwise)
            }
            else if (selector == 3) {
                hueDistance = ColorFunction.hueDistance(from: hue, to: keyHue, in: .antiClockwise)
            }
            else if (selector == 4) {
                hueDistance = ColorFunction.hueDistance(from: hue, to: keyHue, in: .antiClockwise)/2
            }
            
            if (hueDistance <= miniHueDistance) {
                hueDistance = miniHueDistance
            }
            else if (hueDistance >= maxHueDistance) {
                hueDistance = maxHueDistance
            }
            
            hues[0] = ColorFunction.hueRotate(from: keyHue, with: hueDistance*2, in: .antiClockwise)
            hues[1] = ColorFunction.hueRotate(from: keyHue, with: hueDistance, in: .antiClockwise)
            hues[2] = keyHue
            hues[3] = ColorFunction.hueRotate(from: keyHue, with: hueDistance, in: .clockwise)
            hues[4] = ColorFunction.hueRotate(from: keyHue, with: hueDistance*2, in: .clockwise)
        }
        
        return hues
    }
 
}

