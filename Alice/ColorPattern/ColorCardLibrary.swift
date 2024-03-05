//
//  ColorCardLibrary.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/7.
//

import UIKit

class ColorCardLibrary: NSObject {
    
    private let schemes: Array<ColorScheme> = [
        
        ColorScheme(items: [
            ColorItem(hex: "#3B0E1E"),
            ColorItem(hex: "#FF3838"),
            ColorItem(hex: "#FF535F"),
            ColorItem(hex: "#FF9098"),
            ColorItem(hex: "#FFFFFF")
        ]),
            
        ColorScheme(items: [
            ColorItem(hex: "#8B5FBF"),
            ColorItem(hex: "#61398F"),
            ColorItem(hex: "#FFFFFF"),
            ColorItem(hex: "#D6C6E1"),
            ColorItem(hex: "#9A73B5")
        ]),
        
        ColorScheme(items: [
            ColorItem(hex: "#FF6600"),
            ColorItem(hex: "#ff983f"),
            ColorItem(hex: "#ffffa1"),
            ColorItem(hex: "#F5F5F5"),
            ColorItem(hex: "#929292")
        ]),
        
        ColorScheme(items: [
            ColorItem(hex: "#3e5991"),
            ColorItem(hex: "#2b3f66"),
            ColorItem(hex: "#554291"),
            ColorItem(hex: "#3e9186"),
            ColorItem(hex: "#2b665e")
        ]),
        
        ColorScheme(items: [
            ColorItem(hex: "#f7a400"),
            ColorItem(hex: "#3a9efd"),
            ColorItem(hex: "#3e4491"),
            ColorItem(hex: "#292a73"),
            ColorItem(hex: "#1a1b4b")
        ]),
        
        ColorScheme(items: [
            ColorItem(hex: "#3ac3fd"),
            ColorItem(hex: "#2988b1"),
            ColorItem(hex: "#fd3aa3"),
            ColorItem(hex: "#b12972"),
            ColorItem(hex: "#fde33a")
        ]),
        
        ColorScheme(items: [
            ColorItem(hex: "#fcf03a"),
            ColorItem(hex: "#b0a829"),
            ColorItem(hex: "#3a8ffc"),
            ColorItem(hex: "#2964b0"),
            ColorItem(hex: "#fc3a6c")
        ]),
        
    ]
    
    func openDatabase() ->Bool {
        return true
    }
    
    func closeDatabase() {
    }
    
    func colorCard(at index: Int) -> ColorCard? {
        if index >= schemes.count {
            return nil
        }
        
        let scheme = schemes[index]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd001"
        let id = "ID." + formatter.string(from: Date())
        
        return ColorCard(id: id, scheme: scheme)
    }
    
    func numberOfColorCards() -> Int {
        return schemes.count
    }
    
}
