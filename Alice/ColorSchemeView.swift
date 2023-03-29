//
//  ColorSchemeView.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/13.
//

import UIKit

protocol ColorItemSelectorDelegate {
    func activedSelector(index: Int) -> Void
}

class ColorItemSelectorController: UIView {
    var delegate: ColorItemSelectorDelegate?
    
    var items: Array<ColorItem>? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var currentSelector: Int? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activeItem)))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activeItem)))
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIColor(named: "color-window-background")?.setFill()
        UIRectFill(rect)
        
        guard let items = items else {
            return
        }
        
        if (items.count == 0) {
            return
        }

        let itemWidth = frame.size.width / CGFloat(items.count)
        let itemHeight = 6.0
        let inset = 3.0
        for i in 0 ..< items.count {
            let x = itemWidth * CGFloat(i) + inset
            let y = 1.0
            let rect = CGRect(x: x, y: y, width: itemWidth-(inset*2.0), height: itemHeight)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.height*0.5)
            path.lineWidth = 1.0
            if i == currentSelector {
                UIColor(named: "color-wheel-selector-actived")?.setFill()
            }
            else {
                UIColor(named: "color-wheel-selector-unactived")?.setFill()
            }
            path.fill()
        }

    }
    
    @objc func activeItem(_ sender: UITapGestureRecognizer) {
        guard let delegate = delegate, let items = items else {
            return
        }
        
        let regionWidthPerItem = frame.size.width / CGFloat(items.count)
        let location = sender.location(in: self)
        let index = location.x / regionWidthPerItem
        
        currentSelector = Int(index)
        
        delegate.activedSelector(index: currentSelector!)
    }
    
}

class ColorSchemeItemView: UIView {
    var index: Int
    override init(frame: CGRect) {
        index = 0
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        index = 0
        super.init(coder: coder)
    }
}

class ColorSchemeView: UIView {
    
    var delegate: ColorItemSelectorDelegate?
    
    private var columns: Int?
    var itemViews: Array<ColorSchemeItemView>?
    var animate: Bool = true
    
    var items: Array<ColorItem>? {
        didSet {
            if (columns == nil) {
                return
            }
            
            if (items == nil) {
                removeItemViews()
            }
            else {
                if (itemViews == nil) {
                    createItemViews()
                }
                else {
                    if let itemViews = itemViews, let items = items {
                        if (itemViews.count != items.count) {
                            removeItemViews()
                            createItemViews()
                        }
                        else {
                            updateItemViews()
                        }
                    }
                    
                }
            }
        }
    }
    
    func getItemView(by index: Int) -> UIView? {
        var target: UIView? = nil
        for subview in subviews {
            if (subview is ColorSchemeItemView && subview.tag == index ) {
                target = subview
                break
            }
        }
        return target
    }
    
    func createItemViews() {
        guard let columns = columns, let items = items else {
            return
        }
        
        var rows = 0
        var itemViewWidth = 0.0
        var itemViewHeight = 0.0
        
        if (items.count > columns) {
            rows = Int(CGFloat(items.count) / CGFloat(columns) + 0.5)
            itemViewWidth = frame.size.width / CGFloat(columns)
            itemViewHeight = frame.size.height / CGFloat(rows)
        }
        else {
            rows = 1
            itemViewWidth = frame.size.width / CGFloat(items.count)
            itemViewHeight = frame.size.height / CGFloat(rows)
        }
        
        itemViews = []
        for i in 0 ..< items.count {
            let rect = CGRect(x: itemViewWidth*Double((i%columns)), y: itemViewHeight*Double((i/columns)), width: itemViewWidth, height: itemViewHeight)
            let itemView = ColorSchemeItemView(frame: rect)
            setItemViewBackgroundColor(view: itemView, colorItem: items[i])
            if (animate == true) {
                itemView.alpha = 0.0
            }
            itemView.index = i
            if delegate != nil {
                itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(activeItem)))
            }
            addSubview(itemView)
            itemViews?.append(itemView)
        }
        
        if (animate == true) {
            if let itemViews = itemViews {
                
                let duration = 0.5
                UIView.animateKeyframes(withDuration: duration, delay: 0.0, options:[]) {
                    for i in 0 ..< itemViews.count {
                        let relativeStartTime = duration / CGFloat(itemViews.count) * CGFloat(i)
                        let relativeDuration =  duration / CGFloat(itemViews.count)
                        UIView.addKeyframe(withRelativeStartTime: relativeStartTime, relativeDuration: relativeDuration) {
                            itemViews[i].alpha = 1.0
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    @objc func activeItem(_ sender: UITapGestureRecognizer) {
        guard let delegate = delegate, let view = sender.view as? ColorSchemeItemView else {
            return
        }
        
        delegate.activedSelector(index: view.index)
    }
    
    func updateItemViews() {
        guard let items = items, let itemViews = itemViews else {
            return
        }
        
        if (animate == true) {
            let duration = 0.5
            for i in 0 ..< itemViews.count {
                UIView.animate(withDuration: duration, delay: 0.0, animations: {
                    self.setItemViewBackgroundColor(view: itemViews[i], colorItem: items[i])
                })
            }
            
        }
        else {
            for i in 0 ..< items.count {
                setItemViewBackgroundColor(view: itemViews[i], colorItem: items[i])
            }
        }
        
    }
    
    func setItemViewBackgroundColor(view: UIView, colorItem: ColorItem) {
        view.backgroundColor = UIColor(colorItem: colorItem)
    }
    
    func updateItemViewsBound() {
        guard let columns = columns, let itemViews = itemViews, let items = items else {
            return
        }
        
        var rows = 0
        var itemViewWidth = 0.0
        var itemViewHeight = 0.0
        
        if (items.count > columns) {
            rows = Int(CGFloat(items.count) / CGFloat(columns) + 0.5)
            itemViewWidth = frame.size.width / CGFloat(columns)
            itemViewHeight = frame.size.height / CGFloat(rows)
        }
        else {
            rows = 1
            itemViewWidth = frame.size.width / CGFloat(items.count)
            itemViewHeight = frame.size.height / CGFloat(rows)
        }
        
        for i in 0 ..< itemViews.count {
            let rect = CGRect(x: itemViewWidth*Double((i%columns)), y: itemViewHeight*Double((i/columns)), width: itemViewWidth, height: itemViewHeight)
            itemViews[i].frame = rect
        }
        
    }
    
    func removeItemViews() {
        if let itemViews = itemViews {
            itemViews.forEach({
                $0.removeFromSuperview()
            })
            self.itemViews = nil
        }
    }
    
    override var bounds: CGRect {
        didSet {
            updateItemViewsBound()
        }
    }
    
    override var frame: CGRect {
        didSet{
            updateItemViewsBound()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupColumnsWithDeviceType()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupColumnsWithDeviceType()
    }
    
    func setupColumnsWithDeviceType() {
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            columns = 5
        }
        else if (UIDevice.current.userInterfaceIdiom == .pad) {
            columns = 10
        }
    }
    
}
