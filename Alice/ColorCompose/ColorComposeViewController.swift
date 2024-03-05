//
//  ColorComposeViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/10.
//

import UIKit

class ColorComposeViewController: UIViewController {
    
    @IBOutlet weak var actionNavigationbarItem: UIBarButtonItem!
    @IBOutlet weak var schemeView: ColorSchemeView!
    @IBOutlet weak var selectorController: ColorItemSelectorController!
    @IBOutlet weak var colorWheelView: ColorWheelView!
    @IBOutlet weak var brightnessView: BrightnessView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var colorSelectors: Array<ColorWheelSelector>?
    var brightnessSelector: ColorWheelSelector?
    let feedback = UIImpactFeedbackGenerator(style: .medium)
    var colorWheelRadius = 0.0
    var paningPoint = CGPoint(x: 0.0, y: 0.0)
    var currentToolbarType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        configureNavigationbar()
        configureToolbar()
        configureSchemeView()
        
        selectorController.delegate = self
        
        if let generator = self.appDelegate.colorSchemeGenerator {
            colorWheelView.hues = generator.getHues()
        }
    }
    
    func configureSchemeView() {
        schemeView.animate = false
        schemeView.layer.cornerRadius = 10.0
        schemeView.layer.cornerCurve = .continuous
        schemeView.clipsToBounds = true
        schemeView.delegate = self
//        schemeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigateToColorTable)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex(), let activedColorIndex = generator.getActivedColorIndex() else {
            return
        }
        
        let items = schemes[activedSchemeIndex].items
        schemeView.items = items
        selectorController.items = items
        selectorController.currentSelector = activedColorIndex
        
        brightnessView.gradientColor = UIColor(colorItem: items[Int(activedColorIndex)])
        infoLabel.text = ColorComposeTypeString(type: generator.getColorComposeType())
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSchemeNotificationResponder), name: ColorComposer.updateColorCombinationNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activedColorIndexChangedNotificationResponder), name: ColorComposer.activedColorIndexChangedNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ColorComposer.activedColorIndexChangedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: ColorComposer.updateColorCombinationNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let generator = self.appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex(), let activedColorIndex = generator.getActivedColorIndex(), let keyColorIndex = generator.getKeyColorIndex() else {
            return
        }
        
        let items = schemes[activedSchemeIndex].items
        
        colorWheelRadius = colorWheelView.frame.size.width*0.5
        
        // color selectors
        if colorSelectors == nil {

            colorSelectors = []
            
            for i in 0 ..< items.count {
                let width = colorWheelView.frame.size.width*0.12
                let height = width
                let x = colorWheelView.frame.origin.x + colorWheelView.frame.size.width*0.5 - width*0.5
                let y = colorWheelView.frame.origin.y + colorWheelView.frame.size.height*0.5 - height*0.5
                let selectorRect = CGRect(x: x, y: y, width: width, height: height)
                let selector = ColorWheelSelector(frame: selectorRect)
                selector.tag = i
                view.addSubview(selector)
                colorSelectors!.append(selector)
            }
            colorSelectors?[Int(activedColorIndex)].isActived = true
            colorSelectors?[Int(keyColorIndex)].isKey = true
            
            let duration = 0.2
            var locations :Array<CGPoint> = []
            UIView.animate(withDuration: duration, delay: 0.0, animations: {
                for i in 0 ..< items.count {
                    let color = items[i]
                    let selector = self.colorSelectors![i]
                    selector.color = UIColor(colorItem: color)
                    
                    // p0 is location in colorWheelView, convert it to current view'scoordinates
                    // then assign to selector
                    if let hue = color.hue, let saturation = color.saturation {
                        let p0 = self.colorWheelView.locationFrom(HS: (hue, saturation))
                        let p1 = self.view.convert(p0, from: self.colorWheelView)
                        locations.append(p0)
                        selector.center = p1
                        
                        selector.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panColor)))
                        selector.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.makeKeySelector)))
                        
                    }
                }
            })
            {
                if $0 == true {
                    self.colorWheelView.setPathLocations(locations: locations)
                }
            }
                        
            if let activedColorSelector = colorSelectors?[Int(activedColorIndex)] {
                view.bringSubviewToFront(activedColorSelector)
            }
            
        }
        
        // brightness selector
        if (brightnessSelector == nil) {
            
            let color = items[Int(activedColorIndex)]
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
        
        schemeView.items = items
        selectorController.items = items
        selectorController.currentSelector = activedColorIndex
        
        switchToolbar(to: "schemeStyle")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func panColor(_ sender: UIPanGestureRecognizer) {
        guard let generator = self.appDelegate.colorSchemeGenerator, let selector = sender.view as? ColorWheelSelector, let colorSelectors = colorSelectors else {
            return
        }
        
        let translation = sender.translation(in: view)
        
        if (sender.state == .began) {
            
            var i = 0
            while (i < colorSelectors.count) {
                if (colorSelectors[i] == selector) {
                    generator.setActivedColorIndex(i)
                    break
                }
                i += 1
            }
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
        generator.set(selector: selector.tag, hue: HS.0, saturation: HS.1, brightness: nil)
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func makeKeySelector(_ sender: UIPanGestureRecognizer) {
        guard let generator = self.appDelegate.colorSchemeGenerator, let selector = sender.view as? ColorWheelSelector, let colorSelectors = colorSelectors else {
            return
        }
        
        var i = 0
        while (i < colorSelectors.count) {
            if (colorSelectors[i] == selector) {
                generator.setActivedColorIndex(i)
                break
            }
            i += 1
        }
    }
    
    @objc func panBrightness(_ sender: UIPanGestureRecognizer) {
        guard let generator = self.appDelegate.colorSchemeGenerator, let brightnessView = brightnessView, let selector = brightnessSelector, let activedColorIndex = generator.getActivedColorIndex() else {
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
        generator.set(selector: activedColorIndex, hue: nil, saturation: nil, brightness: value)
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func updateSchemeNotificationResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            
            guard let generator = self.appDelegate.colorSchemeGenerator, let colorSelectors = self.colorSelectors, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex(), let activedColorIndex = generator.getActivedColorIndex(), let brightnessSelector = self.brightnessSelector else {
                return
            }
            
            let items = schemes[activedSchemeIndex].items
            
            // update selectors
            var locations :Array<CGPoint> = []
//            UIView.animate(withDuration: 0.1, animations: {
                
                for i in 0 ..< items.count {
                    let color = items[i]
                    let selector = self.colorSelectors![i]
                    colorSelectors[i].color = UIColor(colorItem: color)
                    
                    if let hue = color.hue, let saturation = color.saturation {
                        // p0 is location in colorWheelView, convert it to current view'scoordinates
                        // then assign to selector
                        let p0 = self.colorWheelView.locationFrom(HS: (hue, saturation))
                        let p1 = self.view.convert(p0, from: self.colorWheelView)
                        locations.append(p0)
                        selector.center = p1
//
//                        for selector in colorSelectors {
//                            if (selector.tag) == i {
//                                colorSelectors[i].center = p1
//                                colorSelectors[i].color = UIColor(colorItem: color)
//                            }
//                        }
                    }
                }
                
                self.colorWheelView.setPathLocations(locations: locations)
//            })
            
            // update scheme view item
            UIView.animate(withDuration: 0.1, animations: {
                self.schemeView.items = items
                self.selectorController.items = items
                self.selectorController.currentSelector = activedColorIndex
            })
            
            // update brightness view and selector
            UIView.animate(withDuration: 0.1, animations: {
                let color = items[Int(activedColorIndex)]
                if let brightness = color.brightness {
                    let p0 = self.brightnessView.selectorPosition(with: CGFloat(brightness))
                    brightnessSelector.center = self.view.convert(p0, from: self.brightnessView)
                    self.brightnessView.gradientColor = UIColor(colorItem: color)
                    self.colorWheelView.brightness = ColorFunction.val2Amp(brightness, 100.0)
                }
            })
            
        }
    }
        
    @objc func activedColorIndexChangedNotificationResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            guard let generator = self.appDelegate.colorSchemeGenerator, let colorSelectors = self.colorSelectors, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex(), let activedColorIndex = generator.getActivedColorIndex(), let brightnessSelector = self.brightnessSelector else {
                return
            }
            
            colorSelectors.forEach({
                $0.isActived = false
            })
            colorSelectors[activedColorIndex].isActived = true
            self.view.bringSubviewToFront(colorSelectors[activedColorIndex])
            self.selectorController.currentSelector = activedColorIndex
            
            
            // update brightness view and selector
            let color = schemes[activedSchemeIndex].items[Int(activedColorIndex)]
            if let brightness = color.brightness {
                let p0 = self.brightnessView.selectorPosition(with: CGFloat(brightness))
                brightnessSelector.center = self.view.convert(p0, from: self.brightnessView)
                self.brightnessView.gradientColor = UIColor(colorItem: color)
                self.colorWheelView.brightness = ColorFunction.val2Amp(brightness, 100.0)
            }
        }
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("ColorComposition-NavigationTitle", comment: "")
        
        let items = [
            
            UIAction(title: NSLocalizedString("SchemeList-MenuItem", comment: ""), image: UIImage(named: "icon-list"), handler: { (_) in
                self.performSegue(withIdentifier: "IDSegueColorComposeSchemeTable", sender: self)
            }),
            
            UIAction(title: NSLocalizedString("SaveToLibrary-MenuItem", comment: ""), image: UIImage(named: "icon-library"), handler: { (_) in
                
                if let localLibrary = self.appDelegate.localLibrary, let generator = self.appDelegate.colorSchemeGenerator, let snapshoot = generator.snapshoot() {
                    
                    // Unsubscription restrict feature
                    if self.appDelegate.unsubscribedRestrict(feature: "saveToLibrary") {
                        self.performSegue(withIdentifier: "IDSegueColorComposeToSubscribe", sender: self)
                    }
                    else {
                        if (!localLibrary.recorded(snapshoot: snapshoot)) {
                            localLibrary.save(snapshoot: snapshoot)
                        }
                        let dialog = UIAlertController(title: nil, message: NSLocalizedString("SaveComplete!-DialogMessage", comment: ""), preferredStyle: .alert)
                        dialog.overrideUserInterfaceStyle = .dark
                            
                        // Create OK button with action handler
                        let ok = UIAlertAction(title: NSLocalizedString("OK-DialogButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
                        })
                        dialog.addAction(ok)
                        self.present(dialog, animated: true, completion: nil)
                    }
                    
                }
            }),
            
            UIAction(title: NSLocalizedString("Portrait-MenuItem", comment: ""), image: UIImage(named: "icon-portrait"), handler: { (_) in
                self.performSegue(withIdentifier: "IDSegueColorCompositionPortrait", sender: self)
            }),
            
            UIAction(title: NSLocalizedString("EnterName-MenuItem", comment: ""), image: UIImage(named: "icon-edit-name"), handler: { (_) in
                if let generator = self.appDelegate.colorSchemeGenerator {
                    
                    let dialog = UIAlertController(title: nil, message: NSLocalizedString("EnterName-DialogMessage", comment: ""), preferredStyle: .alert)
                    dialog.overrideUserInterfaceStyle = .dark
                    dialog.addTextField(configurationHandler: { textField in
                        textField.placeholder = NSLocalizedString("AddNameToSearch-Label", comment: "")
                        textField.text = generator.getName()
                    })
                    
                    let submit = UIAlertAction(title: NSLocalizedString("OK-DialogButtonTitle", comment: ""), style: .default) { (action) -> Void in
                        let nameInput = dialog.textFields![0]
                        generator.set(name: nameInput.text)
                    }
                    
                    let cancel = UIAlertAction(title: NSLocalizedString("NO-DialogButtonTitle", comment: ""), style: .cancel, handler: { (action) -> Void in
                    })
                    
                    dialog.addAction(submit)
                    dialog.addAction(cancel)
                    
                    self.present(dialog, animated: true)
                }
                
            }),
            
        ]
        actionNavigationbarItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: items)
    }
        
    func configureToolbar() {
        
    }
    
    func switchToolbar(to type:String) {
        
        var items:Array<UIBarButtonItem> = []
        let flexSpaace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        if (type == "schemeStyle") {
            let analogous = UIBarButtonItem(image: UIImage(named: "icon-scheme-analogous"), style: .plain, target: self, action: #selector(selectSchemeStyleAnalogous))
            let monochromatic  = UIBarButtonItem(image: UIImage(named: "icon-scheme-monochromatic"), style: .plain, target: self, action: #selector(selectSchemeStyleMonochromatic))
            let triad = UIBarButtonItem(image: UIImage(named: "icon-scheme-triad"), style: .plain, target: self, action: #selector(selectSchemeStyleTriad))
            let complementary = UIBarButtonItem(image: UIImage(named: "icon-scheme-complementary"), style: .plain, target: self, action: #selector(selectSchemeStyleComplementary))
            let square = UIBarButtonItem(image: UIImage(named: "icon-scheme-square"), style: .plain, target: self, action: #selector(selectSchemeStyleSquare))
            let splitComplementary = UIBarButtonItem(image: UIImage(named: "icon-scheme-split-complementary"), style: .plain, target: self, action: #selector(selectSchemeStyleSplitComplementary))
            let custom = UIBarButtonItem(image: UIImage(named: "icon-scheme-custom"), style: .plain, target: self, action: #selector(selectSchemeStyleCustom))
            
            items = [analogous, flexSpaace, monochromatic, flexSpaace, triad, flexSpaace, complementary, flexSpaace, square, flexSpaace, splitComplementary, flexSpaace, custom]
        }
        currentToolbarType = type
        navigationController?.toolbar.setItems(items, animated: true)
    }
    
    @objc func selectSchemeStyleAnalogous(_ sender: Any) {
        guard let infoLabel, let generator = self.appDelegate.colorSchemeGenerator else {
            return
        }
        generator.setColorComposeType(type: .analogous)
        infoLabel.text = "Analogous"
    }
    
    @objc func selectSchemeStyleMonochromatic(_ sender: Any) {
        guard let infoLabel, let generator = self.appDelegate.colorSchemeGenerator else {
            return
        }
        generator.setColorComposeType(type: .monochromatic)
        infoLabel.text = "Monochromatic"
    }
    
    @objc func selectSchemeStyleTriad(_ sender: Any) {
        guard let infoLabel, let generator = self.appDelegate.colorSchemeGenerator else {
            return
        }
        generator.setColorComposeType(type: .triad)
        infoLabel.text = "Triad"
    }
    
    @objc func selectSchemeStyleComplementary(_ sender: Any) {
        guard let infoLabel, let generator = self.appDelegate.colorSchemeGenerator else {
            return
        }
        generator.setColorComposeType(type: .complementary)
        infoLabel.text = "Complementary"
    }
    
    @objc func selectSchemeStyleSquare(_ sender: Any) {
        guard let infoLabel, let generator = self.appDelegate.colorSchemeGenerator else {
            return
        }
        generator.setColorComposeType(type: .square)
        infoLabel.text = "Square"
    }
    
    @objc func selectSchemeStyleSplitComplementary(_ sender: Any) {
        guard let infoLabel, let generator = self.appDelegate.colorSchemeGenerator else {
            return
        }
        generator.setColorComposeType(type: .splitComplementary)
        infoLabel.text = "Split Complementary"
    }
    
    @objc func selectSchemeStyleCustom(_ sender: Any) {
        guard let infoLabel, let generator = self.appDelegate.colorSchemeGenerator else {
            return
        }
        generator.setColorComposeType(type: .custom)
        infoLabel.text = "Custom"
    }
    
    @IBAction func navigateToColorTable(_ sender: Any) {
        performSegue(withIdentifier: "IDSegueColorComposeSchemeTable", sender: self)
    }
            
    @IBAction func close(_ sender: Any) {
        guard let generator = self.appDelegate.colorSchemeGenerator else {
            dismiss(animated: true)
            return
        }
        
        guard let snapshoot = generator.snapshoot(), let localLibrary = appDelegate.localLibrary else {
            generator.clear()
            dismiss(animated: true)
            return
        }
        
        // Unsubscription restrict feature
        if appDelegate.unsubscribedRestrict(feature: "saveToLibrary") {
            generator.clear()
            dismiss(animated: true)
            return
        }
        
        if (localLibrary.recorded(snapshoot: snapshoot)) {
            localLibrary.save(snapshoot: snapshoot)
            generator.clear()
            dismiss(animated: true)
        }
        else {
            let dialog = UIAlertController(title: nil, message: NSLocalizedString("SaveToLibrary?-DialogMessage", comment: ""), preferredStyle: .alert)
            dialog.overrideUserInterfaceStyle = .dark
            
            let ok = UIAlertAction(title: NSLocalizedString("YES-DialogButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
                localLibrary.save(snapshoot: snapshoot)
                generator.clear()
                self.dismiss(animated: true)
            })
            let cancel = UIAlertAction(title: NSLocalizedString("NO-DialogButtonTitle", comment: ""), style: .cancel, handler: { (action) -> Void in
                generator.clear()
                self.dismiss(animated: true)
            })
            dialog.addAction(ok)
            dialog.addAction(cancel)
            self.present(dialog, animated: true, completion: nil)
        }
    }
    
}

extension ColorComposeViewController: ColorItemSelectorDelegate {
    func activedSelector(index: Int) {
        guard let generator = appDelegate.colorSchemeGenerator else {
            return
        }
        generator.setActivedColorIndex(index)
    }
}
