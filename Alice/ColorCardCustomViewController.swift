//
//  ColorCardCustomViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/20.
//

import UIKit

class ColorCardCustomViewController: UIViewController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var schemeView: ColorSchemeView!
    @IBOutlet weak var colorWheelView: ColorWheelView!
    @IBOutlet weak var brightnessView: BrightnessView!
    
    var colorSelector: ColorWheelSelector?
    var brightnessSelector: ColorWheelSelector?
    var colorWheelRadius = 0.0
    var paningPoint = CGPoint(x: 0.0, y: 0.0)
    let feedback = UIImpactFeedbackGenerator(style: .medium)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        colorWheelView.hues = ColorFunction.wheelHues
        
        configureNavigationbar()
        configureSchemeView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activeSchemeIndex = generator.getActivedSchemeIndex() else {
            return
        }
        
        schemeView.items = schemes[activeSchemeIndex].items
                        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSchemeNotificationResponder), name: ColorCardGenerator.updateColorCombinationNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ColorCardGenerator.updateColorCombinationNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activeSchemeIndex = generator.getActivedSchemeIndex(), let keyColorIndex = generator.getKeyColorIndex() else {
            return
        }
        
        colorWheelRadius = colorWheelView.frame.size.width*0.5
        
        // color selectors
        if colorSelector == nil {

            let width = colorWheelView.frame.size.width*0.12
            let height = width
            let x = colorWheelView.frame.origin.x + colorWheelView.frame.size.width*0.5 - width*0.5
            let y = colorWheelView.frame.origin.y + colorWheelView.frame.size.height*0.5 - height*0.5
            let selectorRect = CGRect(x: x, y: y, width: width, height: height)
            colorSelector = ColorWheelSelector(frame: selectorRect)
            
            if let selector = colorSelector {
                
                selector.tag = 0
                view.addSubview(colorSelector!)
                
                selector.isActived = true
                selector.isKey = true
                
                let duration = 0.2
                var location: CGPoint = CGPoint(x: 0.0, y: 0.0)
                UIView.animate(withDuration: duration, delay: 0.0, animations: {
                    
                    let scheme = schemes[activeSchemeIndex]
                    let color = scheme.items[keyColorIndex]
                    
                    selector.color = UIColor(colorItem: color)
                            
                    // p0 is location in colorWheelView, convert it to current view'scoordinates
                    // then assign to selector
                    if let hue = color.hue, let saturation = color.saturation {
                        let p0 = self.colorWheelView.locationFrom(HS: (hue, saturation))
                        let p1 = self.view.convert(p0, from: self.colorWheelView)
                        location = p0
                        selector.center = p1
                                
                        selector.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panColor)))
                    }
                })
                {
                    if $0 == true {
                        self.colorWheelView.setPathLocations(locations: [location])
                    }
                }
                view.bringSubviewToFront(selector)
            }
        }
        
        // brightness selector
        if (brightnessSelector == nil) {
            
            let scheme = schemes[activeSchemeIndex]
            let color = scheme.items[keyColorIndex]
            
            brightnessView.gradientColor = UIColor(colorItem: color)
            let selectorRect = CGRect(x: 0.0, y: 0.0, width: 40,  height: 40)
            brightnessSelector = ColorWheelSelector(frame: selectorRect)
            
            if let brightnessSelector = brightnessSelector, let brightness = color.brightness {
                let p0 = brightnessView.selectorPosition(with: CGFloat(brightness))
                let p1 = view.convert(p0, from: brightnessView)
                brightnessSelector.center = p1
                view.addSubview(brightnessSelector)
                let panBrightnessGesture = UIPanGestureRecognizer(target: self, action: #selector(panBrightness))
                brightnessSelector.addGestureRecognizer(panBrightnessGesture)
            }
        }
        
        schemeView.items = schemes[activeSchemeIndex].items
        
    }
    
    @objc func panColor(_ sender: UIPanGestureRecognizer) {
        guard let generator = appDelegate.colorSchemeGenerator, let selector = sender.view as? ColorWheelSelector, let activeColorIndex = generator.getActivedColorIndex() else {
            return
        }
        
        let translation = sender.translation(in: view)
        
        if (sender.state == .began) {
            paningPoint = selector.center
        }
        else if (sender.state == .changed) {
            paningPoint = CGPoint(x: paningPoint.x + translation.x, y: paningPoint.y + translation.y)
        }
        else if (sender.state == .ended) {
            feedback.impactOccurred()
        }
        
        let p0 = view.convert(paningPoint, to: colorWheelView)
        let HS = colorWheelView.HSFrom(location: p0)
        
        generator.set(selector: activeColorIndex, hue: HS.0, saturation: HS.1, brightness: nil)
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
        
    @objc func panBrightness(_ sender: UIPanGestureRecognizer) {
        guard let generator = appDelegate.colorSchemeGenerator, let brightnessView = brightnessView, let selector = brightnessSelector, let activeColorIndex = generator.getActivedColorIndex() else {
            return
        }

        let translation = sender.translation(in: view)

        if (sender.state == .began) {
            paningPoint = selector.center
        }
        else if (sender.state == .changed) {
            paningPoint = CGPoint(x: paningPoint.x + translation.x, y: paningPoint.y + translation.y)
        }
        else if (sender.state == .ended) {
            feedback.impactOccurred()
        }
                
        let p0 = view.convert(paningPoint, to: brightnessView)
        let amp = brightnessView.value(from: p0)
        let value = ColorFunction.amp2Val(amp, 100.0)
        
        generator.set(selector: activeColorIndex, hue: nil, saturation: nil, brightness: value)
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    
    @objc func updateSchemeNotificationResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            
            guard let generator = self.appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex(), let keyColorIndex = generator.getKeyColorIndex(),  let colorSelector = self.colorSelector, let brightnessSelector = self.brightnessSelector else {
                return
            }
            
            let items = schemes[activedSchemeIndex].items
            
            // update selectors
            var location: CGPoint = CGPoint(x: 0.0, y: 0.0)
            
            let color = items[keyColorIndex]
            colorSelector.color = UIColor(colorItem: color)
            
            if let hue = color.hue, let saturation = color.saturation {
                // p0 is location in colorWheelView, convert it to current view'scoordinates
                // then assign to selector
                let p0 = self.colorWheelView.locationFrom(HS: (hue, saturation))
                let p1 = self.view.convert(p0, from: self.colorWheelView)
                location = p0
                colorSelector.center = p1
            }
            
            self.colorWheelView.setPathLocations(locations: [location])
            
            // update scheme view item
            UIView.animate(withDuration: 0.1, animations: {
                self.schemeView.items = items
            })
            
            // update brightness view and selector
            UIView.animate(withDuration: 0.1, animations: {
                let color = items[keyColorIndex]
                if let brightness = color.brightness {
                    let p0 = self.brightnessView.selectorPosition(with: CGFloat(brightness))
                    brightnessSelector.center = self.view.convert(p0, from: self.brightnessView)
                    self.brightnessView.gradientColor = UIColor(colorItem: color)
                    self.colorWheelView.brightness = ColorFunction.val2Amp(brightness, 100.0)
                }
            })
            
        }
    }
    
    func configureSchemeView() {
        schemeView.animate = false
        schemeView.layer.cornerRadius = 10.0
        schemeView.layer.cornerCurve = .continuous
        schemeView.clipsToBounds = true
        schemeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigateToColorTable)))
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func navigateToColorTable(_ sender: Any) {
        performSegue(withIdentifier: "IDSegueColorCardSchemeTable", sender: self)
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("ColorCardCustom-NavigationTitle", comment: "")
    }
    
}
