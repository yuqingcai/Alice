//
//  Monochromatic.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/6.
//

import Foundation

class MonochromaticModel: ComposeModel {
    
    override init() {
        super.init()
        let _ = reset(hue: 0, saturation: 100, brightness: 100)
    }
    
    override func reset(hue: Int32, saturation: Int32, brightness: Int32) -> ColorScheme {
        // 5 hues
        let hues: Array<Int32> = Array(repeating: hue, count: ComposeModel.schemeSize)
        // 5 saturations
        
        saturationStates = [ false, false, false, false, false ]
        var saturations: Array<Int32> = Array(repeating: 0, count: hues.count)
        saturations[0] = difference(to: saturation, with:  0 , in: 0...100)
        saturations[1] = difference(to: saturation, with: -50, in: 0...100)
        saturations[2] = difference(to: saturation, with:  0 , in: 0...100)
        saturations[3] = difference(to: saturation, with: -50, in: 0...100)
        saturations[4] = difference(to: saturation, with:  0 , in: 0...100)
                
        // 5 brightnesses
        brightnessStates = [ false, false, false, false, false ]
        var brightnesses: Array<Int32> = Array(repeating: 0, count: hues.count)
        brightnesses[0] = difference(to: brightness, with: -50, in: 0...100)
        brightnesses[1] = difference(to: brightness, with:  10 , in: 0...100)
        brightnesses[2] = difference(to: brightness, with:  0 , in: 0...100)
        brightnesses[3] = difference(to: brightness, with: -50, in: 0...100)
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
        
        let hues = Array(repeating: Int32(hue), count: ComposeModel.schemeSize)
        return hues
    }
    
}
