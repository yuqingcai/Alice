//
//  PickerRegionView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/10.
//

import UIKit

class PickerRegionView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        let width = self.frame.size.height
        let height = self.frame.size.height
        let drect = CGRect(x: 0,y: 0, width: width, height: height)
        let path = UIBezierPath(rect: drect)
        
        UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5).set()
        path.fill()
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touchs began")
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touchs move")
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print ("touches ended")
//    }
    
}
