//
//  Complementary.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/6.
//

import Foundation

class ComplementaryModel: ComposeModel {
    
    override init() {
        super.init()
        
        let _ = reset(hue: 0, saturation: 100, brightness: 100)
    }
    
    override func reset(hue: Int32, saturation: Int32, brightness: Int32) -> ColorScheme {
        saturationStates = [ false, false, false, false, false ]
        brightnessStates = [ false, false, false, false, false ]
        
        let hueDistance: Int32 = 180
        // 5 hues
        let hues: Array<Int32> = [
            hue,
            hue,
            hue,
            ColorFunction.hueRotate(from: hue, with: hueDistance, in: .antiClockwise),
            ColorFunction.hueRotate(from: hue, with: hueDistance, in: .antiClockwise)
        ]
        
        // 5 saturations
        var saturations: Array<Int32> = Array(repeating: 0, count: hues.count)
        saturations[0] = difference(to: saturation, with:  10, in: 0...100)
        saturations[1] = difference(to: saturation, with: -20, in: 0...100)
        saturations[2] = difference(to: saturation, with:  0 ,  in: 0...100)
        saturations[3] = difference(to: saturation, with:  20, in: 0...100)
        saturations[4] = difference(to: saturation, with:  0 , in: 0...100)
        
        // 5 brightnesses
        var brightnesses: Array<Int32> = Array(repeating: 0, count: hues.count)
        brightnesses[0] = difference(to: brightness, with: -30, in: 0...100)
        brightnesses[1] = difference(to: brightness, with:  20, in: 0...100)
        brightnesses[2] = difference(to: brightness, with:  0 , in: 0...100)
        brightnesses[3] = difference(to: brightness, with: -30, in: 0...100)
        brightnesses[4] = difference(to: brightness, with:  0 , in: 0...100)
        
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
        
        var hues = Array(repeating: Int32(0), count: ComposeModel.schemeSize)
        let hueDistance: Int32 = 180
        
        if (selector == 0 || selector == 1 || selector == 2) {
            hues[0] = hue
            hues[1] = hue
            hues[2] = hue
            hues[3] = ColorFunction.hueRotate(from: hue, with: hueDistance, in: .antiClockwise)
            hues[4] = ColorFunction.hueRotate(from: hue, with: hueDistance, in: .antiClockwise)
        }
        else if (selector == 3 || selector == 4) {
            hues[3] = hue
            hues[4] = hue
            hues[0] = ColorFunction.hueRotate(from: hue, with: hueDistance, in: .antiClockwise)
            hues[1] = ColorFunction.hueRotate(from: hue, with: hueDistance, in: .antiClockwise)
            hues[2] = ColorFunction.hueRotate(from: hue, with: hueDistance, in: .antiClockwise)
        }
        
        return hues
    }
    
}
