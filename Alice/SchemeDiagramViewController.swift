//
//  SchemeDiagramViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/1/6.
//

import UIKit

class SchemeDiagramViewController: UIViewController {
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var imageView: UIImageView?
    var image: UIImage?
    
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
        
        if (imageView == nil) {
            self.indicator.isHidden = false
            self.indicator.startAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (imageView == nil) {
            
            guard let generator = appDelegate.colorSchemeGenerator, let schemes = generator.getSchemes(), let activedSchemeIndex = generator.getActivedSchemeIndex() else {
                return
            }
            
            
            let scheme = schemes[activedSchemeIndex]
            
            if let image = ColorFunction.createSchemeDiagram(from:scheme) {
                
                self.image = image
                imageScrollView.contentSize = CGSize(width: image.size.width, height: image.size.height)
                
                imageView = UIImageView(image: image)
                
                if let imageView = imageView {
                    imageScrollView.addSubview(imageView)

                    var minimumZoomScale = 1.0

                    if (image.size.width >= image.size.height) {
                        minimumZoomScale = imageScrollView.frame.size.height / image.size.height
                    }
                    else if (image.size.width < image.size.height) {
                        minimumZoomScale = imageScrollView.frame.size.width / image.size.width
                    }
                    
                    if (image.size.width >= imageScrollView.frame.size.width ||
                        image.size.height >= imageScrollView.frame.size.height) {
                        imageScrollView.minimumZoomScale = minimumZoomScale
                        imageScrollView.maximumZoomScale = 1
                    }
                    else if (image.size.width < imageScrollView.frame.size.width ||
                        image.size.height < imageScrollView.frame.size.height) {
                        imageScrollView.minimumZoomScale = minimumZoomScale
                        imageScrollView.maximumZoomScale = minimumZoomScale
                    }

                    imageScrollView.zoomScale = minimumZoomScale

                    let offsetX = max((imageScrollView.frame.width - imageScrollView.contentSize.width) * 0.5, 0)
                    let offsetY = max((imageScrollView.frame.height - imageScrollView.contentSize.height) * 0.5, 0)
                    imageScrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
                }
                
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Snapshoot.removeAllSharedTempFiles()
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("SchemeDiagram-NavigationTitle", comment: "")
    }
    
    @IBAction func share(_ sender: Any) {
        
        // Unsubscription restrict feature
        if appDelegate.unsubscribedRestrict(feature: "share") {
            self.performSegue(withIdentifier: "IDSegueSchemeDiagramToSubscribe", sender: self)
            return
        }
        
        guard let generator = appDelegate.colorSchemeGenerator, let image = image else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let idString = formatter.string(from: Date())
        var fileName = "Coloury_Scheme_\(idString).jpg"
        if (generator.getName() != "") {
            fileName = generator.getName()+"_SchemeDiagram.jpg"
        }
        
        let shareTempDirectory = Snapshoot.getShareTempDirectory()
        let filePath = shareTempDirectory.appendingPathComponent(fileName)
        
        guard let data = image.pngData() else {
            return
        }
        
        do {
            try data.write(to: filePath)
        } catch {
            print("save scheme image share temp error: \(error).")
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
}

extension SchemeDiagramViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if (scrollView == imageScrollView) {
            return imageView
        }
        return nil
    }
}
    
