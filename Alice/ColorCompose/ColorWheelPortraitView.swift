//
//  ColorWheelPortraitView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/6.
//

import UIKit

class ColorWheelPortraitView: PortraitView {
    var imageView: UIImageView?
    var image: UIImage? {
        didSet {
            if (imageView != nil) {
                imageView!.removeFromSuperview()
            }
            
            imageView = UIImageView(frame: CGRect(origin: .zero, size: bounds.size))
            if let imageView = imageView {
                imageView.image = image
                imageView.contentMode = .scaleAspectFit
                addSubview(imageView)
            }
        }
    }
    
    private func updateImageViewSize() {
        guard let imageView = imageView else {
            return
        }
        
        if (abs(frame.size.width - imageView.frame.size.width) < CGFLOAT_EPSILON &&
            abs(frame.size.height - imageView.frame.size.height) < CGFLOAT_EPSILON) {
            return
        }
        
        imageView.frame = CGRect(origin: .zero, size: frame.size)
    }
    
    override var bounds: CGRect {
        didSet {
            updateImageViewSize()
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateImageViewSize()
        }
    }
    
    override func convertToImage() -> UIImage {
        return super.convertToImage()
    }
}
