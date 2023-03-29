//
//  PortraitViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/24.
//

import UIKit

class PortraitViewController: UIViewController {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var portraitView: PortraitView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        configureNavigationbar()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (portraitView == nil) {
            self.indicator.isHidden = false
            self.indicator.startAnimating()
            
            if let generator = appDelegate.colorSchemeGenerator {
                portraitView = generator.getPortrait()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let portraitView = portraitView else {
            return
        }
        
        let ratio = view.frame.size.width / portraitView.frame.size.width
        let width = view.frame.size.width
        let height = portraitView.frame.size.height * ratio
        let x = 0.0
        let y = (view.frame.size.height - height)*0.5
        portraitView.frame = CGRect(x: x, y: y, width: width, height: height)
        view.addSubview(portraitView)
        
        self.indicator.isHidden = true
        self.indicator.stopAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Snapshoot.removeAllSharedTempFiles()
    }
    
    @IBAction func share(_ sender: Any) {
        // Unsubscription restrict feature
        if appDelegate.unsubscribedRestrict(feature: "share") {
            performSegue(withIdentifier: "IDSegueSchemePortraitToSubscribe", sender: self)
            return
        }
        
        guard let generator = appDelegate.colorSchemeGenerator, let image = portraitView?.convertToImage() else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let idString = formatter.string(from: Date())
        var fileName = "Coloury_Portrait_\(idString).jpg"
        if (generator.getName() != "") {
            fileName = generator.getName()+"_Portrait.jpg"
        }
        
        let shareTempDirectory = Snapshoot.getShareTempDirectory()
        let filePath = shareTempDirectory.appendingPathComponent(fileName)
        
        guard let data = image.pngData() else {
            return
        }
        
        do {
            try data.write(to: filePath)
        }
        catch {
            print("save portraitImage share temp error: \(error).")
            return
        }
        
        let url = URL(fileURLWithPath: filePath.path)
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.overrideUserInterfaceStyle = .dark
        activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList]
        activityViewController.completionWithItemsHandler = {
            (activityType, completed, returnedItems, error) in
            // remove jpg file
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
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("Portrait-NavigationTitle", comment: "")
    }
        
}
