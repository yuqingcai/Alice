//
//  SampleRegionView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/10.
//

import UIKit

class SampleRegionView: UIView {
    
    var matchingAntLayer: CAShapeLayer?
    var backgroundColor0: UIColor = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 0.5)
    var backgroundColor1: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    var borderColor: UIColor = UIColor.white
        
    override init(frame: CGRect) {
        isKey = false
        super.init(frame: frame)
        self.setupMarchingAnts(scaleFactor: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        isKey = false
        super.init(coder: aDecoder)
        self.setupMarchingAnts(scaleFactor:1.0)
    }
    
    func setupMarchingAnts(scaleFactor: CGFloat) {

        if let layer = self.matchingAntLayer {
            layer.removeAnimation(forKey: "lineDashPhase")
            layer.removeFromSuperlayer()
        }
        self.matchingAntLayer = nil
        
        self.matchingAntLayer = CAShapeLayer();
        guard let shapeLayer = self.matchingAntLayer else {
            return
        }
        
        shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height)
        if (isKey) {
            shapeLayer.fillColor = backgroundColor0.cgColor
        }
        else {
            shapeLayer.fillColor = backgroundColor1.cgColor
        }
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.lineWidth = 1.0 / scaleFactor
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [NSNumber(value: 4.0/scaleFactor), NSNumber(value: 4.0/scaleFactor)]
        shapeLayer.path = UIBezierPath(rect: bounds).cgPath
        
        let animation = CABasicAnimation(keyPath: "lineDashPhase")
        animation.fromValue = 0.0
        // toValue is lineDashPattern length(painted segments and unpainted segments in user-space-unit-long)
        animation.toValue = shapeLayer.lineDashPattern?.reduce(0, { $0 + $1.intValue })
        animation.duration = 0.8
        animation.repeatCount = Float.greatestFiniteMagnitude
        shapeLayer.add(animation, forKey: "lineDashPhase")
        
        self.layer.addSublayer(shapeLayer)
    }
    
    var isKey: Bool {
        didSet {
            if (isKey == true) {
                matchingAntLayer?.fillColor = backgroundColor0.cgColor
            }
            else {
                matchingAntLayer?.fillColor = backgroundColor1.cgColor
            }
        }
    }
    
}
