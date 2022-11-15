//
//  ColorWheelView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/11.
//

import UIKit
import simd

class ColorWheelView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        let radius = self.bounds.size.width / 2
        
        let angle = Measurement(value: Double(2.0), unit: UnitAngle.degrees)
        let a = Float(angle.converted(to: .radians).value)
        
        let translateMatrix = makeTranslationMatrix(tx: Float(self.bounds.size.width/2.0), ty: Float(self.bounds.size.height/2.0))
        
        for h in 0..<360 {
            let angle = Measurement(value: Double(h), unit: UnitAngle.degrees)
            let radians = Float(angle.converted(to: .radians).value)
            let rotationMatrix = makeRotationMatrix(angle: radians)
            
            let k = radius / 100.0
            for s in 0..<100 {
                
                let x0 = self.bounds.origin.x
                let y0 = self.bounds.origin.y
                let x1 = x0 + radius-CGFloat(s)*k
                let x2 = x0 + radius-CGFloat(s)*k
                let y1 = y0 + radius*tan(CGFloat(-a)/2)
                let y2 = y0 + radius*tan(CGFloat(a)/2)
                
                let pv0 = simd_float3(x: Float(x0), y: Float(y0), z: 1.0)
                let pv1 = simd_float3(x: Float(x1), y: Float(y1), z: 1.0)
                let pv2 = simd_float3(x: Float(x2), y: Float(y2), z: 1.0)
                
                let pvr0 = translateMatrix*(rotationMatrix * pv0)
                let pvr1 = translateMatrix*(rotationMatrix * pv1)
                let pvr2 = translateMatrix*(rotationMatrix * pv2)
                
                let context : CGContext = UIGraphicsGetCurrentContext()!
                context.beginPath()
                context.move(to: CGPoint(x: CGFloat(pvr0.x), y: CGFloat(pvr0.y)))
                context.addLine(to: CGPoint(x: CGFloat(pvr1.x), y: CGFloat(pvr1.y)))
                context.addLine(to: CGPoint(x: CGFloat(pvr2.x), y: CGFloat(pvr2.y)))
                context.closePath()
                
                
//                var m0 = rotationMatrix * simd_float3x3(simd_float3(x: Float(x0), y: Float(y0), z: 1.0),
//                                       simd_float3(x: x1, y: y1, z: 1.0),
//                                       simd_float3(x: x2, y: y2, z: 1.0))
//
//                m0 = rotationMatrix * m0    // rotation
//                m0 = translateMatrix * m0   // translate
//
//                let context : CGContext = UIGraphicsGetCurrentContext()!
//                context.beginPath()
//                context.move(to: CGPoint(x: CGFloat(m0.columns.0.x), y: CGFloat(m0.columns.0.y)))
//                context.addLine(to: CGPoint(x: CGFloat(m0.columns.1.x), y: CGFloat(m0.columns.1.y)))
//                context.addLine(to: CGPoint(x: CGFloat(m0.columns.2.x), y: CGFloat(m0.columns.2.y)))
//                context.closePath()
                
                
                
                let hue = 1.0-CGFloat(h)/360.0
                let saturation = 1.0-CGFloat(s)*0.01
                context.setFillColor(UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0).cgColor)
                context.fillPath()
            }
        }
        
    }
    
    func makeTranslationMatrix(tx: Float, ty: Float) -> simd_float3x3 {
        var matrix = matrix_identity_float3x3
        
        matrix[2, 0] = tx
        matrix[2, 1] = ty
        
        return matrix
    }
    
    func makeRotationMatrix(angle: Float) -> simd_float3x3 {
        let rows = [
            simd_float3(cos(angle), -sin(angle), 0),
            simd_float3(sin(angle), cos(angle), 0),
            simd_float3(0,          0,          1)
        ]
        
        return float3x3(rows: rows)
    }

}
