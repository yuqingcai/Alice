//
//  ColorSampleViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/7.
//

import UIKit

class ColorSampleViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var schemeScrollView: UIScrollView!
    @IBOutlet weak var schemePageController: UIPageControl!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var actionNavigationbarItem: UIBarButtonItem!
    
    var currentToolbarType: String?
    var imageView: UIImageView?
    var sampleColorCount = 10
    var indicatorView: UIActivityIndicatorView?
    let feedback = UIImpactFeedbackGenerator(style: .medium)
    var sampleSlots: Array<(SampleRegionView, ColorSchemeView)> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        
        configureNavigationbar()
        configureToolbar()
        configureImageScrollView()
        configureSchemeScrollView()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            sampleColorCount = 10
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            sampleColorCount = 20
        }
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSchemeNoticationResponder), name: ColorSampler.updatePhotoSchemeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appendSchemeNoticationResponder), name: ColorSampler.appendPhotoSchemeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotoSchemeFrameResponder), name: ColorSampler.updatePhotoSchemeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotoSchemeColorCountResponder), name: ColorSampler.updatePhotoSchemeColorCountNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removePhotoSchemeResponder), name: ColorSampler.removePhotoSchemeNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ColorSampler.removePhotoSchemeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: ColorSampler.updatePhotoSchemeColorCountNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: ColorSampler.updatePhotoSchemeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: ColorSampler.appendPhotoSchemeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: ColorSampler.updatePhotoSchemeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let generator = self.appDelegate.colorSchemeGenerator, let photo = generator.getPhoto() else {
            return
        }
        
        generator.setSampleType(.frequence)
        switchToolbar(to: "main")
        
        if (imageView == nil) {
            
            imageView = UIImageView(image: photo)
            guard let imageView = imageView else {
                return
            }
            
            imageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapImage))
            imageView.addGestureRecognizer(tapGesture)
            imageScrollView.addSubview(imageView)
            
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
        restoreSchemes()
    }
    
    func configureImageScrollView() {
        imageScrollView.layer.cornerRadius = 10;
        imageScrollView.layer.cornerCurve = .continuous
        imageScrollView.clipsToBounds = true;
    }
    
    func configureSchemeScrollView() {
        schemePageController.isUserInteractionEnabled = false
        schemeScrollView.isPagingEnabled = true
        schemeScrollView.layer.cornerRadius = 10;
        schemeScrollView.layer.cornerCurve = .continuous
        schemeScrollView.clipsToBounds = true
        schemeScrollView.showsHorizontalScrollIndicator = false
        schemeScrollView.showsVerticalScrollIndicator = false
    }
    
    func configureToolbar() {
    }
    
    func switchToolbar(to type:String) {
        var items:Array<UIBarButtonItem> = []
        let flexSpaace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        if (type.caseInsensitiveCompare("main") == .orderedSame) {
            let appendScheme = UIBarButtonItem(image: UIImage(named: "icon-add-region"), style: .plain, target: self, action: #selector(appendScheme(_ :)))
//            let appendPoint = UIBarButtonItem(image: UIImage(named: "icon-picker"), style: .plain, target: self, action: #selector(appendPoint(_ :)))
            
            items = [
                flexSpaace, appendScheme, flexSpaace//, appendPoint, flexSpaace
            ]
        }
        else if (type.caseInsensitiveCompare("regionOperation") == .orderedSame) {
            let move = UIBarButtonItem(image: UIImage(named: "icon-move-region"), style: .plain, target: self, action: #selector(presentRegionPropertyMove))
            let scale  = UIBarButtonItem(image: UIImage(named: "icon-scale-region"), style: .plain, target: self, action: #selector(presentRegionPropertyScale))
            let schemeSize = UIBarButtonItem(image: UIImage(named: "icon-color-scheme-count"), style: .plain, target: self, action: #selector(presentRegionPropertyModifyScheme))
            let remove = UIBarButtonItem(image: UIImage(named: "icon-remove-region"), style: .plain, target: self, action: #selector(removeScheme))
            items = [move, flexSpaace, scale, flexSpaace, schemeSize, flexSpaace, remove,]
        }
        
        currentToolbarType = type
        navigationController?.toolbar.setItems(items, animated: true)
    }
    
    private func restoreSchemes() {
        cleanSampleSlot()
        
        guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
            return
        }
        for scheme in schemes {
            appendSampleSlot(scheme)
        }
        makeKeyRegion(sampleSlots[activedSchemeIndex].0)
        
        schemePageController.numberOfPages = sampleSlots.count
        scrollSchemeView(to: activedSchemeIndex)
    }
    
    private func cleanSampleSlot() {
        sampleSlots.forEach({
            $0.0.removeFromSuperview()
            $0.1.removeFromSuperview()
        })
        sampleSlots = []
    }
    
    private func appendSampleSlot(_ scheme: ColorScheme) {
        guard let imageView = imageView else {
            return
        }
        
        // add UI region
        let region = SampleRegionView(frame: scheme.frame)
        region.isHidden = false
        region.isUserInteractionEnabled = true
        region.setupMarchingAnts(scaleFactor: imageScrollView.zoomScale)
        region.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panSampleRegion)))
        region.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSampleRegion)))
        region.alpha = 0.0
        imageView.addSubview(region)
        UIView.animate(withDuration: 0.5, delay: 0.0, animations: {
            region.alpha = 1.0
        })
        
        // add ColorScheme View
        let n = sampleSlots.count
        schemeScrollView.contentSize = CGSize(width: schemeScrollView.frame.size.width*CGFloat(n+1), height: schemeScrollView.frame.size.height);
        let inset = 8.0
        let x = schemeScrollView.frame.size.width*CGFloat(n) + inset
        let y = 0.0
        let width = schemeScrollView.frame.size.width - inset*2.0
        let height = schemeScrollView.frame.size.height
        let rect = CGRect(x: x, y: y, width: width, height: height)
        let schemeView = ColorSchemeView(frame: rect)
        schemeView.layer.cornerRadius = 10;
        schemeView.layer.cornerCurve = .continuous
        schemeView.clipsToBounds = true
        schemeView.items = scheme.items
        schemeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigateToColorTable)))
        schemeScrollView.addSubview(schemeView)
        
        sampleSlots.append((region, schemeView))
        makeKeyRegion(region)
    }
    
    private func removeSampleSlot(at index: Int) {
        let slot = sampleSlots[index]
        UIView.animate(withDuration: 0.5, delay: 0.0, animations: {
            slot.0.alpha = 0.0
        }) {_ in
            
            slot.0.removeFromSuperview()
            self.removeSchemeView(slot.1)
            
            self.sampleSlots.remove(at: index)
            self.schemePageController.numberOfPages = self.sampleSlots.count
            if let generator = self.appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex() {
                self.scrollSchemeView(to: activedSchemeIndex)
                self.makeKeyRegion(self.sampleSlots[activedSchemeIndex].0)
            }
        }
        
    }
    
    private func scrollSchemeView(to view: ColorSchemeView) {
        if let index = sampleSlots.firstIndex(where: { $0.1 == view }) {
            schemeScrollView.setContentOffset(CGPoint(x: CGFloat(index)*schemeScrollView.frame.size.width, y: 0.0), animated: true)
            schemePageController.currentPage = index
        }
    }
    
    private func scrollSchemeView(to index: Int) {
        if (index >= 0 && index < sampleSlots.count) {
            schemeScrollView.setContentOffset(CGPoint(x: CGFloat(index)*schemeScrollView.frame.size.width, y: 0.0), animated: true)
            schemePageController.currentPage = index
        }
    }
    
    private func removeSchemeView(_ view: ColorSchemeView) {
        if let index = sampleSlots.firstIndex(where: { $0.1 == view }) {
            view.removeFromSuperview()
            
            var i = index + 1
            while (i < sampleSlots.count) {
                let offset = schemeScrollView.frame.size.width
                UIView.animate(withDuration: 0.5, delay: 0.0, animations: {
                    self.sampleSlots[i].1.frame.origin.x -= offset
                })
                i += 1
            }
            schemeScrollView.contentSize = CGSize(width: schemeScrollView.frame.size.width*CGFloat(sampleSlots.count-1), height: schemeScrollView.frame.size.height);
        }
    }
        
    @IBAction func tapImage(_ sender: UIPanGestureRecognizer) {
        switchToolbar(to: "main")
    }
    
    @IBAction func panSampleRegion(_ sender: UIPanGestureRecognizer) {
        guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let view = sender.view as? SampleRegionView, let imageView = imageView else {
            return
        }

        view.superview?.bringSubviewToFront(view)

        let translation = sender.translation(in: imageView)
        sender.setTranslation(CGPoint.zero, in: imageView)

        let imageWidth = imageView.frame.size.width / imageScrollView.zoomScale
        let imageHeight = imageView.frame.size.height / imageScrollView.zoomScale
        var origin = CGPoint(x: view.frame.origin.x + translation.x, y: view.frame.origin.y + translation.y)
        if (origin.x < 0.0) {
            origin.x = 0.0
        }
        if (origin.y < 0.0) {
            origin.y = 0.0
        }
        if (origin.x + view.frame.size.width > imageWidth) {
            origin.x = imageWidth - view.frame.size.width
        }
        if (origin.y + view.frame.size.height > imageHeight) {
            origin.y = imageHeight - view.frame.size.height
        }
        
        view.frame.origin = origin
        
        if (sender.state == .began) {
            if let i = sampleSlots.firstIndex(where: {$0.0 == view}) {
                scrollSchemeView(to: i)
            }
            makeKeyRegion(view)
        }
        else if (sender.state == .ended) {
            if let i = sampleSlots.firstIndex(where: { $0.0 == view }) {
                let scheme = schemes[i]
                let frame = view.frame
                DispatchQueue.global(qos: .userInteractive).async {
                    generator.updateScheme(colorCount: scheme.items.count, frame: frame, index: i)
                    DispatchQueue.main.async {
                    }
                }
            }
        }
    }
        
    func makeKeyRegion(_ region: SampleRegionView) {
        sampleSlots.forEach({ $0.0.isKey = false })
        region.superview?.bringSubviewToFront(region)
        region.isKey = true
        
    }
    
    @IBAction func appendScheme(_ sender: Any) {
        guard let generator = appDelegate.colorSchemeGenerator, let photo = generator.getPhoto() else {
            return
        }
        
        var colorCount = 5
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            colorCount = 5
        }
        else if (UIDevice.current.userInterfaceIdiom == .pad) {
            colorCount = 10
        }
        
        let width = photo.size.width * 0.2
        let height = photo.size.height * 0.2
        let x = (photo.size.width - width)*0.5
        let y = (photo.size.height - height)*0.5
        let rect = CGRect(x: x, y: y, width: width, height: height)
        generator.sample(colorCount: colorCount, frame: rect)
    }
    
    @IBAction func appendPoint(_ sender: Any) {
//        guard let generator = appDelegate.colorSchemeGenerator, let photo = generator.getPhoto() else {
//            return
//        }
    }
    
    @IBAction func tapSampleRegion(_ sender:UIPinchGestureRecognizer) {
        guard let view = sender.view as? SampleRegionView, let generator = appDelegate.colorSchemeGenerator else {
            return
        }
        
        view.superview?.bringSubviewToFront(view)
        
        switchToolbar(to: "regionOperation")
        view.setupMarchingAnts(scaleFactor: imageScrollView.zoomScale)
        makeKeyRegion(view)

        if let i = sampleSlots.firstIndex(where: { $0.0 == view }) {
            scrollSchemeView(to: sampleSlots[i].1)
            generator.setActivedSchemeIndex(i)
        }
    }
    
    @IBAction func presentRegionPropertyMove(_ sender: Any) {
        performSegue(withIdentifier: "IDSegueSampleMove", sender: self)
    }
    
    @IBAction func presentRegionPropertyScale(_ sender: Any) {
        performSegue(withIdentifier: "IDSegueSampleScale", sender: self)
    }
    
    @IBAction func presentRegionPropertyModifyScheme(_ sender: Any) {
        performSegue(withIdentifier: "IDSegueSampleScheme", sender: self)
    }
    
    @IBAction func removeScheme(_ sender: Any) {
        guard let generator = appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex() else {
            return
        }
        
        let dialog = UIAlertController(title: nil, message: NSLocalizedString("DeleteScheme?-DialogMessage", comment: ""), preferredStyle: .alert)
        dialog.overrideUserInterfaceStyle = .dark
        
        let ok = UIAlertAction(title: NSLocalizedString("YES-DialogButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            generator.removeScheme(index: activedSchemeIndex)
        })
        let cancel = UIAlertAction(title: NSLocalizedString("NO-DialogButtonTitle", comment: ""), style: .cancel, handler: { (action) -> Void in
        })
        dialog.addAction(ok)
        dialog.addAction(cancel)
        self.present(dialog, animated: true, completion: nil)
        
    }
    
    @IBAction func close(_ sender: Any) {
        guard let generator = appDelegate.colorSchemeGenerator else {
            dismiss(animated: true)
            return
        }
        
        guard let snapshoot = generator.snapshoot(), let localLibrary = appDelegate.localLibrary else {
            generator.clear()
            dismiss(animated: true)
            return
        }
        
        // Unsubscription restrict feature
        if appDelegate.unsubscribedRestrict(feature: "SaveToLibrary") {
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
    
    @IBAction func appendSchemeNoticationResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            guard let generator = self.appDelegate.colorSchemeGenerator, let scheme = notification.userInfo?["scheme"] as? ColorScheme else {
                return
            }
            
            self.appendSampleSlot(scheme)
            
            self.schemePageController.numberOfPages = self.sampleSlots.count
            if let activedSchemeIndex = generator.getActivedSchemeIndex() {
                self.scrollSchemeView(to: activedSchemeIndex)
            }
            
        }
    }
    
    @IBAction func updateSchemeNoticationResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            guard let scheme = notification.userInfo?["scheme"] as? ColorScheme, let index = notification.userInfo?["index"] as? Int else {
                return
            }
            
            if (self.sampleSlots.count == 0 || index < 0 || index >= self.sampleSlots.count) {
                return
            }

            let colorSchemeView = self.sampleSlots[index].1
            colorSchemeView.items = scheme.items
        }
    }
    
    @IBAction func updatePhotoSchemeFrameResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            guard let scheme = notification.userInfo?["scheme"] as? ColorScheme, let index = notification.userInfo?["index"] as? Int else {
                return
            }
            
            if (self.sampleSlots.count == 0 || index < 0 || index >= self.sampleSlots.count) {
                return
            }

            let region = self.sampleSlots[index].0
            region.frame = scheme.frame
            region.setupMarchingAnts(scaleFactor: self.imageScrollView.zoomScale)
        }
    }
    
    @IBAction func updatePhotoSchemeColorCountResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
        }
    }
    
    @IBAction func removePhotoSchemeResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            guard let index = notification.userInfo?["index"] as? Int else {
                return
            }
            self.removeSampleSlot(at: index)
            
            if let generator = self.appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes() {
                if (schemes.count == 0) {
                    self.switchToolbar(to: "main")
                }
            }
        }
    }
        
    @IBAction func navigateToColorTable(_ sender: Any?) {
        performSegue(withIdentifier: "IDSegueColorSampleSchemeTable", sender: self)
    }
        
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("ColorSample-NavigationTitle", comment: "")
        
        let items = [
            
            UIAction(title: NSLocalizedString("SchemeList-MenuItem", comment: ""), image: UIImage(named: "icon-list"), handler: { (_) in
                self.performSegue(withIdentifier: "IDSegueColorSampleSchemeTable", sender: self)
            }),
            
            UIAction(title: NSLocalizedString("SaveToLibrary-MenuItem", comment: ""), image: UIImage(named: "icon-library"), handler: { (_) in
                                
                if let localLibrary = self.appDelegate.localLibrary, let generator = self.appDelegate.colorSchemeGenerator, let snapshoot = generator.snapshoot() {
                    
                    // Unsubscription restrict feature
                    if self.appDelegate.unsubscribedRestrict(feature: "SaveToLibrary") {
                        self.performSegue(withIdentifier: "IDSegueColorSampleToSubscribe", sender: self)
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
                self.performSegue(withIdentifier: "IDSeguePhotoPortrait", sender: self)
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
    
}

extension ColorSampleViewController : UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if (scrollView == imageScrollView) {
        }
        
        if (scrollView == schemeScrollView) {
            guard let generator = appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex() else {
                return
            }
            
            let index = Int(schemeScrollView.contentOffset.x / schemeScrollView.frame.size.width)
            if index != activedSchemeIndex {
                generator.setActivedSchemeIndex(index)
                schemePageController.currentPage = index
                makeKeyRegion(sampleSlots[index].0)
                
            }
            
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if (scrollView == imageScrollView) {
            return imageView
        }
        return nil
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if (scrollView == imageScrollView) {
            for slot in sampleSlots {
                slot.0.setupMarchingAnts(scaleFactor: imageScrollView.zoomScale)
            }
            
        }
    }
    
}
    
