//
//  Alice+UIView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/2/16.
//

import UIKit

extension UIView {
    @objc func convertToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
        
    func hasTapGestureRecognizer() -> Bool {
        if let gestureRecognizers = gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                if (gestureRecognizer is UITapGestureRecognizer) {
                    return true
                }
            }
            return false
        }
        return false
    }
}
