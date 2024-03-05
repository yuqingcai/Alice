//
//  ColorPatternGenerator.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/10.
//

import UIKit

class ColorPatternGenerator: NSObject {
    
    static let mainColorIndexChangedNotification: Notification.Name = Notification.Name("mainColorIndexChangedNotification")
    
    private var scheme: ColorScheme?
    
    var mainColorIndex: Int?
    
    func generate(by colorCard: ColorCard) {
        scheme = colorCard.scheme
        mainColorIndex = 0
    }
    
    func getScheme() -> ColorScheme? {
        return scheme
    }
    
    func getMainColorIndex() -> Int? {
        return mainColorIndex
    }
    
    func setMainColorIndex(_ index: Int) {
        
        mainColorIndex = index
        NotificationCenter.default.post(name: ColorPatternGenerator.mainColorIndexChangedNotification, object: self, userInfo: nil)
    }
    
}

