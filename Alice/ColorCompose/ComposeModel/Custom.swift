//
//  Custom.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/6.
//

import Foundation

class CustomModel: ComposeModel {
    
    override init() {
        super.init()
        let _ = reset(hue: 0, saturation: 100, brightness: 100)
    }
    
    override func reset(hue: Int32, saturation: Int32, brightness: Int32) -> ColorScheme {
        saturationStates = [ false, false, false, false, false ]
        brightnessStates = [ false, false, false, false, false ]
        
        // 5 hues
        let hues = getCurrentHues()
        let saturations = getCurrentSaturations()
        let brightnesses = getCurrentBrightnesses()
                
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
        
        var hues = getCurrentHues()
        hues[selector] = hue
        
        return hues
    }
    
    override func createSaturations(_ selector: Int, _ saturation: Int32?) -> Array<Int32> {
        guard let saturation = saturation else {
            return getCurrentSaturations()
        }
        
        if (selector < 0 || selector >= ComposeModel.schemeSize) {
            return getCurrentSaturations()
        }
        
        var saturations = getCurrentSaturations()
        saturations[selector] = saturation
        
        return saturations
    }
    
    override func createBrightnesses(_ selector: Int, _ brightness: Int32?) -> Array<Int32> {
        guard let brightness = brightness else {
            return getCurrentBrightnesses()
        }
        
        if (selector < 0 || selector >= ComposeModel.schemeSize) {
            return getCurrentBrightnesses()
        }
        
        var brightnesses = getCurrentBrightnesses()
        brightnesses[selector] = brightness
        
        return brightnesses
    }
}
