//
//  SchemeTableViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/24.
//

import UIKit
import LinkPresentation
import ZIPFoundation

class SchemeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let hexTypeString = "HEX"
    let rgbTypeString = "RGB"
    let rybTypeString = "RYB"
    let hslTypeString = "HSL"
    let hsbTypeString = "HSB"
    let cmykTypeString = "CMYK"
    let feedback = UIImpactFeedbackGenerator(style: .medium)
    
    @IBOutlet weak var schemeScrollView: UIScrollView!
    @IBOutlet weak var schemePageController: UIPageControl!
    @IBOutlet weak var schemeTableView: UITableView!
    @IBOutlet weak var colorTypeNavigationbarItem: UIBarButtonItem!
    @IBOutlet weak var shareNavigationbarItem: UIBarButtonItem!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var colorType = "HEX"
    var tableRowInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    var notificationView: NotificationView?
    var showNotification = false
    var schemeViewAnimate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationbar()
        configureToolbar()
        
        overrideUserInterfaceStyle = .dark
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indicator.startAnimating()
        indicator.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
            return
        }

        
        if (schemeScrollView.subviews.count >= 1) {
            schemeViewAnimate = false
            schemeScrollView.subviews.forEach({
                $0.removeFromSuperview()}
            )
        }
        
        schemeScrollView.contentSize = CGSize(width: schemeScrollView.frame.size.width * Double(schemes.count), height: schemeScrollView.frame.size.height)
        schemeScrollView.isPagingEnabled = true
        schemeScrollView.backgroundColor = UIColor(named: "color-window-background")

        for i in 0 ..< schemes.count {
            let inset = 8.0
            let schemeViewSize = CGSize(width: schemeScrollView.frame.size.width - inset*2.0, height: schemeScrollView.frame.size.height)
            let frame = CGRect(x: Double(i)*schemeScrollView.frame.size.width + inset, y: 0.0, width: schemeViewSize.width, height: schemeViewSize.height)

            let schemeView = ColorSchemeView(frame: frame)

            schemeView.layer.cornerRadius = 10.0
            schemeView.layer.cornerCurve = .continuous
            schemeView.clipsToBounds = true
            schemeView.animate = schemeViewAnimate
            schemeView.items = schemes[i].items
            schemeScrollView.addSubview(schemeView)
        }
        
        showNotification = false
        schemeScrollView.setContentOffset(CGPoint(x: CGFloat(activedSchemeIndex)*schemeScrollView.frame.size.width, y: 0.0), animated: true)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(showSchemeImage(sender:)))
        schemeScrollView.addGestureRecognizer(recognizer)

        schemePageController.isUserInteractionEnabled = false
        schemePageController.numberOfPages = schemes.count
        if (schemePageController.numberOfPages == 1) {
            schemePageController.isHidden = true
        }
        schemePageController.currentPage = activedSchemeIndex

        schemeTableView.delegate = self
        schemeTableView.dataSource = self
                
        indicator.stopAnimating()
        indicator.isHidden = true
        
        schemeTableView.delegate = self
        schemeTableView.dataSource = self
        
        // reload tableview with animation
        UIView.transition(with: schemeTableView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.schemeTableView.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Snapshoot.removeAllSharedTempFiles()
    }
    
    @IBAction func showSchemeImage(sender: Any) {
        self.performSegue(withIdentifier: "IDSegueSchemeImage", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
            return 0
        }
        let scheme = schemes[activedSchemeIndex]
        return scheme.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
            return tableView.dequeueReusableCell(withIdentifier: "IDSchemeTableViewCell", for:indexPath) as! SchemeTableViewCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IDSchemeTableViewCell", for:indexPath) as! SchemeTableViewCell
        cell.selectionStyle = .none
        cell.backgroundView = UIView()
        cell.backgroundView?.backgroundColor = UIColor(named: "color-window-background")
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor(named: "color-window-background")
        cell.colorView.backgroundColor = cell.backgroundView?.backgroundColor
        cell.labelView.backgroundColor = cell.backgroundView?.backgroundColor
        
        let imageViewWidth = cell.frame.height - tableRowInsets.top - tableRowInsets.bottom
        let imageViewHeight = imageViewWidth
        let labelViewHeight = imageViewWidth
        cell.colorView.frame = CGRect(x: tableRowInsets.left, y: tableRowInsets.top, width:imageViewWidth, height: imageViewHeight)
        
        cell.labelView.frame = CGRect(x: tableRowInsets.left + imageViewWidth + tableRowInsets.left, y: tableRowInsets.top, width: cell.frame.size.width - tableRowInsets.left - imageViewWidth - tableRowInsets.left, height: labelViewHeight)
        
        let item = schemes[activedSchemeIndex].items[indexPath.item]
        
        cell.colorView.backgroundColor = UIColor(colorItem: item)
        cell.colorView.layer.cornerRadius = 10.0
        cell.colorView.layer.cornerCurve = .continuous
        cell.colorView.clipsToBounds = true
        
        let labelInsetX = 0.0
        let labelInsetY = (cell.labelView.frame.size.height - cell.label.frame.size.height) / 2.0
        let labelWidth = cell.labelView.frame.size.width - labelInsetX*2.0
        let labelHeight = cell.label.frame.height
        
        cell.label.frame = CGRect(x: labelInsetX, y: labelInsetY, width: labelWidth, height: labelHeight)
        cell.label.text = detailString(item: item, type: colorType)
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: tableRowInsets.left + imageViewWidth + tableRowInsets.left, bottom: 0, right: tableRowInsets.right)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rows = 7
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            rows = 7
        }
        else if (UIDevice.current.userInterfaceIdiom == .pad) {
            rows = 10
        }
        return tableView.frame.size.height / CGFloat(rows) + tableRowInsets.top + tableRowInsets.bottom
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        feedback.impactOccurred()
                
        guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
            return
        }
        
        let scheme = schemes[activedSchemeIndex]
        let detail = detailString(item: scheme.items[indexPath.item], type: colorType)
        let pasteboard = UIPasteboard.general
        pasteboard.string = detail
    
        if notificationView == nil {
            let width = view.frame.size.width * 0.5
            let height = 32.0
            let x = (view.frame.size.width - width) * 0.5
            let y = (view.frame.size.height - height) - 32.0
            notificationView = NotificationView(frame: CGRect(x: x, y: y, width: width, height: height))
            
            if showNotification == true {
               return
            }
            
            if let notificationView = notificationView {
                notificationView.text = NSLocalizedString("CopiedtoClipard-Text", comment: "")
                notificationView.layer.cornerRadius = 10.0
                notificationView.layer.cornerCurve = .continuous
                notificationView.clipsToBounds = true
                notificationView.backgroundColor = UIColor(named: "color-notification-background")
                notificationView.alpha = 1.0
                view.addSubview(notificationView)
    
                let duration = 1.0
                UIView.animateKeyframes(withDuration: duration, delay: 0.0, animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.8) {
                        notificationView.alpha = 0.8
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                        notificationView.alpha = 0.0
                    }
                }) {_ in
                    notificationView.removeFromSuperview()
                    self.notificationView = nil
                    self.showNotification = true
                }
    
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if (scrollView == schemeScrollView) {
            guard let generator = appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex() else {
                return
            }
            
            let index = Int(schemeScrollView.contentOffset.x / schemeScrollView.frame.size.width)
            if index != activedSchemeIndex {
                generator.setActivedSchemeIndex(index)
                schemePageController.currentPage = index
                
                // reload tableview with animation
                UIView.transition(with: schemeTableView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.schemeTableView.reloadData()
                })
            }
        }
        
    }
    
    func detailString(item: ColorItem, type: String) -> String {
        var string = ""
        
        if type == hexTypeString {
            string = item.hexString()
        }
        else if type == rgbTypeString {
            string = item.rgbString()
        }
        else if type == rybTypeString {
            string = item.rybString()
        }
        else if type == hslTypeString {
            string = item.hslString()
        }
        else if type == hsbTypeString {
            string = item.hsbString()
        }
        else if type == cmykTypeString {
            string = item.cmykString()
        }
        
        return string
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("SchemeTable-NavigationTitle", comment: "")
    }
    
    func configureToolbar() {
        configureToolbarItemDetailType()
        configureToolbarItemShare()
    }
    
    func configureToolbarItemDetailType() {
        colorTypeNavigationbarItem.title = colorType
        
        let iconHex: UIImage? = UIImage(named: "icon-hex")
        let iconRGB: UIImage? = UIImage(named: "icon-rgb")
        let iconRYB: UIImage? = UIImage(named: "icon-ryb")
        let iconHSL: UIImage? = UIImage(named: "icon-hsl")
        let iconHSB: UIImage? = UIImage(named: "icon-hsb")
        let iconCMYK: UIImage? = UIImage(named: "icon-cmyk")
        
        let items = [
            UIAction(title: hexTypeString, image: iconHex, handler: { (_) in
                self.colorType = self.hexTypeString
                self.schemeTableView.reloadData()
            }),
            UIAction(title: rgbTypeString, image: iconRGB, handler: { (_) in
                self.colorType = self.rgbTypeString
                self.schemeTableView.reloadData()
            }),
            UIAction(title: rybTypeString, image: iconRYB, handler: { (_) in
                self.colorType = self.rybTypeString
                self.schemeTableView.reloadData()
            }),
            UIAction(title: hslTypeString, image: iconHSL, handler: { (_) in
                self.colorType = self.hslTypeString
                self.schemeTableView.reloadData()
            }),
            UIAction(title: hsbTypeString, image: iconHSB, handler: { (_) in
                self.colorType = self.hsbTypeString
                self.schemeTableView.reloadData()
            }),
            UIAction(title: cmykTypeString, image: iconCMYK, handler: { (_) in
                self.colorType = self.cmykTypeString
                self.schemeTableView.reloadData()
            }),
        ]
        colorTypeNavigationbarItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: items)
    }
        
    func configureToolbarItemShare() {
        let clipboard = UIAction(title: NSLocalizedString("CopytoClipboard-MenuItem", comment: ""), image: UIImage(systemName: "list.clipboard"), handler: { (_) in
            
            // Unsubscription restrict feature
            if self.appDelegate.unsubscribedRestrict(feature: "share") {
                self.performSegue(withIdentifier: "IDSegueSchemeTableToSubscribe", sender: self)
                return
            }
            
            guard let generator = self.appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
                return
            }
            
            guard let plainTextString = ColorFunction.plainText(from: schemes[activedSchemeIndex], type: self.colorType) else {
                return
            }
                        
            let pasteboard = UIPasteboard.general
            pasteboard.string = plainTextString
            
            let dialogMessage = UIAlertController(title: nil, message: NSLocalizedString("CopytoClipboardComplete-DialogMessage", comment: ""), preferredStyle: .alert)
            dialogMessage.overrideUserInterfaceStyle = .dark
            
            let ok = UIAlertAction(title: NSLocalizedString("OK-DialogButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
        })
        
        let image = UIAction(title: NSLocalizedString("Scheme-MenuItem", comment: ""), image: UIImage(named: "icon-scheme-diagram"), handler: { (_) in
            self.performSegue(withIdentifier: "IDSegueSchemeImage", sender: self)
        })
                
        let ase = UIAction(title: NSLocalizedString("AdobeSwatchExchange-MenuItem", comment: ""), image: UIImage(named: "icon-adobe"), handler: { (_) in
            
            // Unsubscription restrict feature
            if self.appDelegate.unsubscribedRestrict(feature: "share") {
                self.performSegue(withIdentifier: "IDSegueSchemeTableToSubscribe", sender: self)
                return
            }
            
            guard let generator = self.appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
                return
            }
                        
            let shareTempDirectory = Snapshoot.getShareTempDirectory()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let idString = formatter.string(from: Date())
            var fileName = "Coloury_\(idString).ase"
            if (generator.getName() != "") {
                fileName = generator.getName()+".ase"
            }
            
            let filePath = shareTempDirectory.appendingPathComponent(fileName)
            guard let data = ColorFunction.aseData(from: schemes[activedSchemeIndex], name: idString) else {
                return
            }
            
            do {
                try data.write(to: filePath)
            } catch {
                print("save ASE share temp error: \(error).")
                return
            }
            
            let url = URL(fileURLWithPath: filePath.path)
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.overrideUserInterfaceStyle = .dark
            activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList]
            activityViewController.completionWithItemsHandler = {
                (activityType, completed, returnedItems, error) in
                // remove ase file
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try? FileManager.default.removeItem(at: filePath)
                }
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
            }
            else if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
            }
            
            self.present(activityViewController, animated: true) {
            }
            
        })
        
        let procreate = UIAction(title: NSLocalizedString("ProcreateSwatches-MenuItem", comment: ""), image: UIImage(named: "icon-procreate"), handler: { (_) in
            
            // Unsubscription restrict feature
            if self.appDelegate.unsubscribedRestrict(feature: "share") {
                self.performSegue(withIdentifier: "IDSegueSchemeTableToSubscribe", sender: self)
                return
            }
            
            guard let generator = self.appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
                return
            }
                        
            let shareTempDirectory = Snapshoot.getShareTempDirectory()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let idString = formatter.string(from: Date())
            let rawFileName = "Swatches.json"
            let rawFilePath = shareTempDirectory.appendingPathComponent(rawFileName)
            var zipFileName = "Coloury_\(idString).swatches"
            if (generator.getName() != "") {
                zipFileName = generator.getName()+".swatches"
            }
            
            let zipFilePath = shareTempDirectory.appendingPathComponent(zipFileName)
            
            // procreate swatches file is a zip archive from a json file named Swatches.json
            // first, we create a json Data from procreateSwatches,
            // secondary, create a file named 'Swatches.json'
            // finally, create a zip archive from 'Swatches.json' file
            guard let data = ColorFunction.procreateSwatches(from: schemes[activedSchemeIndex], name: zipFileName) else {
                return
            }
            
            // create raw file
            do {
                try data.write(to: rawFilePath)
            }
            catch {
                print("save Procreate Swatches share temp error: \(error).")
                return
            }
            
            // create zip atchive
            do {
                try FileManager.default.zipItem(at: rawFilePath, to: zipFilePath)
            }
            catch {
                print("Creation of ZIP archive failed with error:\(error)")
                return
            }
            
            
            // share
            let url = URL(fileURLWithPath: zipFilePath.path)
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.overrideUserInterfaceStyle = .dark
            activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList]
            activityViewController.completionWithItemsHandler = {
                (activityType, completed, returnedItems, error) in
                // remove raw file
                if FileManager.default.fileExists(atPath: rawFilePath.path) {
                    try? FileManager.default.removeItem(at: rawFilePath)
                }
                
                // remove zip file
                if FileManager.default.fileExists(atPath: zipFilePath.path) {
                    try? FileManager.default.removeItem(at: zipFilePath)
                }
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
            }
            else if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
            }
            
            self.present(activityViewController, animated: true) {
            }
        })
                
        let plainText = UIAction(title: NSLocalizedString("PlainText-MenuItem", comment: ""), image: UIImage(named: "icon-plain-text"), handler: { (_) in
            
            // Unsubscription restrict feature
            if self.appDelegate.unsubscribedRestrict(feature: "share") {
                self.performSegue(withIdentifier: "IDSegueSchemeTableToSubscribe", sender: self)
                return
            }
            
            guard let generator = self.appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
                return
            }
            
            let shareTempDirectory = Snapshoot.getShareTempDirectory()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let idString = formatter.string(from: Date())
            var fileName = "Coloury_\(self.colorType)_\(idString).TXT"
            if (generator.getName() != "") {
                fileName = generator.getName()+".TXT"
            }
            let filePath = shareTempDirectory.appendingPathComponent(fileName)
            
            guard let plainTextString = ColorFunction.plainText(from: schemes[activedSchemeIndex], type: self.colorType), let data = plainTextString.data(using: .utf8) else {
                return
            }
            
            do {
                try data.write(to: filePath)
            } catch {
                print("save Plain Text share temp error: \(error).")
                return
            }

            let url = URL(fileURLWithPath: filePath.path)
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.overrideUserInterfaceStyle = .dark
            activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList]
            activityViewController.completionWithItemsHandler = {
                (activityType, completed, returnedItems, error) in
                // remove text file
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try? FileManager.default.removeItem(at: filePath)
                }
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
            }
            else if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
            }
            
            self.present(activityViewController, animated: true) {
            }
        })
        
        let json = UIAction(title: NSLocalizedString("JSON-MenuItem", comment: ""), image: UIImage(named: "icon-json"), handler: { (_) in
            
            // Unsubscription restrict feature
            if self.appDelegate.unsubscribedRestrict(feature: "share") {
                self.performSegue(withIdentifier: "IDSegueSchemeTableToSubscribe", sender: self)
                return
            }
            
            guard let generator = self.appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
                return
            }
                        
            let shareTempDirectory = Snapshoot.getShareTempDirectory()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let idString = formatter.string(from: Date())
            var fileName = "Coloury_\(self.colorType)_\(idString).json"
            if (generator.getName() != "") {
                fileName = generator.getName()+".json"
            }
            let filePath = shareTempDirectory.appendingPathComponent(fileName)
            
            guard let jsonString = ColorFunction.jsonString(from: schemes[activedSchemeIndex], type: self.colorType, name: idString), let data = jsonString.data(using: .utf8) else {
                return
            }
            
            do {
                try data.write(to: filePath)
            } catch {
                print("save json share temp error: \(error).")
                return
            }
            
            let url = URL(fileURLWithPath: filePath.path)
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.overrideUserInterfaceStyle = .dark
            activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList]
            activityViewController.completionWithItemsHandler = {
                (activityType, completed, returnedItems, error) in
                // remove json file
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try? FileManager.default.removeItem(at: filePath)
                }
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
            }
            else if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
            }
            
            self.present(activityViewController, animated: true) {
            }
        })
        
        let group0 = UIMenu(title: "", options: .displayInline, children: [clipboard])
        let group1 = UIMenu(title: "", options: .displayInline, children: [image])
        let group2 = UIMenu(title: "", options: .displayInline, children: [ase, procreate, plainText, json])
        
        shareNavigationbarItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [group0, group1, group2])
    }
    
}
