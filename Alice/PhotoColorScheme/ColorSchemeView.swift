//
//  ColorSchemeView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/13.
//

import UIKit

class ColorSchemeView: UIView {
    
    var scheme:ColorScheme?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        guard let scheme = scheme else {
            return
        }
        
        var x = 0.0
        let y = 0.0
        
        //let sorted = scheme.items?.sorted(by: {$0.weight > $1.weight})
                
        for item in scheme.items! {
            //let width = CGFloat(item.weight)*i
            //let height = self.frame.size.height
            
            let width = self.frame.size.height
            let height = self.frame.size.height
            let drect = CGRect(x: x,y: y, width: width, height: height)
            let path = UIBezierPath(rect: drect)
            
            UIColor(red: item.red, green: item.green, blue: item.blue, alpha: 1.0).set()
            path.fill()
            
            x += width;
        }
    }
    

}
