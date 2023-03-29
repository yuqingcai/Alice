//
//  PhotoPortraitView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/6.
//

import UIKit

class PhotoPortraitView: PortraitView {
    private var imageScrollView: UIScrollView
    private var schemeView: ColorSchemeView
    private var infoView: ColorSchemeInfoSingleLineView
    private var footerView: UIImageView
    private var imageView: UIImageView?
    private var footer: UIImage?
    
    var photo: UIImage? {
        didSet {
            
            if (imageView != nil) {
                imageView!.removeFromSuperview()
            }
            
            imageView = UIImageView(image: photo)
            
            if let imageView = imageView {
                imageScrollView.addSubview(imageView)
                updateImageScrollViewZoom()
            }
        }
    }
    
    private func updateImageScrollViewZoom() {
        
        if let photo = photo {
            
            let s = photo.size.width / imageScrollView.frame.size.width
            if s > 1.0 {
                imageScrollView.minimumZoomScale = 1.0/s
                imageScrollView.maximumZoomScale = 1.0
                imageScrollView.zoomScale = 1.0/s
            }
            else {
                imageScrollView.minimumZoomScale = 1.0/s
                imageScrollView.maximumZoomScale = 1.0/s
                imageScrollView.zoomScale = 1.0/s
            }
            
            if imageScrollView.contentSize.height < imageScrollView.frame.size.height {
                let s2 = imageScrollView.frame.size.height / imageScrollView.contentSize.height
                imageScrollView.zoomScale *= s2
            }
            if imageScrollView.contentSize.width < imageScrollView.frame.size.width {
                let s3 = imageScrollView.frame.size.width / imageScrollView.contentSize.width
                imageScrollView.zoomScale *= s3
            }
            imageScrollView.minimumZoomScale = imageScrollView.zoomScale
                            
            if imageScrollView.contentSize.width >= imageScrollView.frame.size.width {
                let offsetX = (imageScrollView.contentSize.width - imageScrollView.frame.size.width) / 2.0
                imageScrollView.contentOffset.x = offsetX
            }
        }
    }
    
    var scheme: ColorScheme? {
        didSet {
            guard let scheme = scheme else {
                return
            }
            
            schemeView.items = scheme.items
            infoView.colorItems = scheme.items
            
        }
    }
    
    private func updateLayout() {
        let space = frame.size.width * 0.1
        var topSpace = space
        var bottomSpace = space
        let leftSpace = space
        let rightSpace = space
        
        let imageScrollViewWidth = frame.size.width - leftSpace - rightSpace
        var imageScrollViewHeight = frame.size.height * 0.2
        var schemeViewHeight = frame.size.height * 0.1
        var textViewHeight = frame.size.height * 0.1
        var footerViewHeight = bottomSpace * 0.6
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            topSpace = space * 1.0
            bottomSpace = space * 1.2
            imageScrollViewHeight = frame.size.height * 0.55
            schemeViewHeight = frame.size.height * 0.17
            textViewHeight = schemeViewHeight * 0.3
            footerViewHeight = bottomSpace * 0.6
        }
        else if (UIDevice.current.userInterfaceIdiom == .pad) {
            topSpace = space * 0.6
            bottomSpace = space * 1.0
            imageScrollViewHeight = frame.size.height * 0.55
            schemeViewHeight = frame.size.height * 0.2
            textViewHeight = schemeViewHeight * 0.3
            footerViewHeight = bottomSpace * 0.5
        }
        let imageScrollRect = CGRect(x: leftSpace, y: topSpace, width: imageScrollViewWidth, height: imageScrollViewHeight)
        imageScrollView.frame = imageScrollRect
        
        var space0 = space*0.4
        //if (UIDevice.current.userInterfaceIdiom == .phone) {
//            space0 = space*0.4
        //}
        //else if (UIDevice.current.userInterfaceIdiom == .pad) {
        //    space0 = space*0.2
        //}
        
        let schemeRect = CGRect(x: leftSpace, y: imageScrollRect.origin.y + imageScrollRect.size.height + space0, width: imageScrollRect.size.width, height: schemeViewHeight)
        schemeView.frame = schemeRect
        
        let space1 = 0.0
        let textRect = CGRect(x: leftSpace, y: schemeRect.origin.y + schemeRect.size.height + space1, width: imageScrollRect.size.width, height: textViewHeight)
        infoView.frame = textRect
        
        if let footer = footer {
            let ratio = footerViewHeight / footer.size.height
            let footerViewWidth = footer.size.width * ratio
            let footerRect = CGRect(x: (frame.size.width - footerViewWidth)*0.5, y: (frame.size.height - bottomSpace) + (bottomSpace - footerViewHeight)*0.5, width: footerViewWidth, height: footerViewHeight)
            footerView.frame = footerRect
        }
        
        updateImageScrollViewZoom()
    }
    
    override var bounds: CGRect {
        didSet {
            updateLayout()
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateLayout()
        }
    }
    
    override init(frame: CGRect) {
        let cornerRadius = 16.0
        
        imageScrollView = UIScrollView(frame: .zero)
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.layer.cornerRadius = cornerRadius
        imageScrollView.layer.cornerCurve = .continuous
        imageScrollView.clipsToBounds = true
        
        schemeView = ColorSchemeView(frame: .zero)
        schemeView.layer.cornerRadius = cornerRadius
        schemeView.layer.cornerCurve = .continuous
        schemeView.clipsToBounds = true
        
        infoView = ColorSchemeInfoSingleLineView(frame: .zero)
        infoView.clipsToBounds = true
                
        footer = UIImage(named: "icon-app-footer")
        footerView = UIImageView(frame: .zero)
        footerView.layer.cornerRadius = cornerRadius
        footerView.layer.cornerCurve = .continuous
        footerView.clipsToBounds = true
        footerView.contentMode = .scaleAspectFit
        footerView.tintColor = UIColor.black
        footerView.image = footer
        
        super.init(frame: frame)
        
        imageScrollView.delegate = self
        addSubview(imageScrollView)
        addSubview(schemeView)
        addSubview(infoView)
        addSubview(footerView)
        
        updateLayout()
        
        backgroundColor = UIColor(hex: "#FFFFFF")
    }
    
    required init?(coder: NSCoder) {
        let cornerRadius = 16.0
        
        imageScrollView = UIScrollView(frame: .zero)
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.layer.cornerRadius = cornerRadius
        imageScrollView.layer.cornerCurve = .continuous
        imageScrollView.clipsToBounds = true
        
        schemeView = ColorSchemeView(frame: .zero)
        schemeView.layer.cornerRadius = cornerRadius
        schemeView.layer.cornerCurve = .continuous
        schemeView.clipsToBounds = true
        
        infoView = ColorSchemeInfoSingleLineView(frame: .zero)
        infoView.clipsToBounds = true
        
        footer = UIImage(named: "icon-app-footer")
        footerView = UIImageView(frame: .zero)
        footerView.layer.cornerRadius = cornerRadius
        footerView.layer.cornerCurve = .continuous
        footerView.clipsToBounds = true
        footerView.contentMode = .scaleAspectFit
        footerView.tintColor = UIColor.black
        footerView.image = footer
        
        super.init(coder: coder)
        
        imageScrollView.delegate = self
        addSubview(imageScrollView)
        addSubview(schemeView)
        addSubview(infoView)
        addSubview(footerView)
        
        updateLayout()
        
        backgroundColor = UIColor(hex: "#FFFFFF")
    }
    
    override func convertToImage() -> UIImage {
        return super.convertToImage()
    }
}

extension PhotoPortraitView : UIScrollViewDelegate {
        
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if (scrollView == imageScrollView) {
            return imageView
        }
        return nil
    }
    
    
}
