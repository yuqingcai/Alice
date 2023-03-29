//
//  NotificationView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/1/10.
//

import UIKit

class NotificationView: UIView {
    var text: String?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        guard let text = text else {
            return
        }
        
        let textAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0),
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#000000"),
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: textAttributes as [NSAttributedString.Key : Any])
        
        let drawingSize = attributedString.size()
        let rect = CGRect(x: rect.origin.x + (rect.size.width - drawingSize.width)*0.5, y: rect.origin.y + (rect.size.height - drawingSize.height)*0.5, width: drawingSize.width, height: drawingSize.height)
        
        attributedString.draw(in: rect)
        
    }
    

}
