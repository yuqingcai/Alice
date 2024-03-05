//
//  AboutViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/2/7.
//

import UIKit

class AboutViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var recoverSamplesButton: UIButton!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        configureNavigationbar()
        setupButtons()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("About-NavigationTitle", comment: "")
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            displayNameLabel.text = displayName
        }
        
        if let marketingVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String  {
            versionLabel.text = "Version " + marketingVersion
        }

        if let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String  {
            copyrightLabel.text = copyright
        }
        
        indicator.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupButtons() {
        let titleTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = UIColor(named: "color-title")
            outgoing.font = UIFont.boldSystemFont(ofSize: 14)
            return outgoing
        }
        var config = UIButton.Configuration.filled()
        config.titleTextAttributesTransformer = titleTransformer
        config.baseBackgroundColor = UIColor(named: "color-button-background")
        config.imagePadding = 12
        config.titleAlignment = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
        config.cornerStyle = .medium
        
        config.title = NSLocalizedString("RecoverSamples-ButtonTitle", comment: "")
        recoverSamplesButton.configuration = config
    }
    
    @IBAction func recoverSamples(_ sender: Any) {
        
        let dialog = UIAlertController(title: nil, message: NSLocalizedString("RecoverSamples?-DialogMessage", comment: ""), preferredStyle: .alert)
        dialog.overrideUserInterfaceStyle = .dark
        if dialog.preferredStyle == .actionSheet {
            if let popoverPresentationController = dialog.popoverPresentationController {
                popoverPresentationController.sourceView = recoverSamplesButton
                popoverPresentationController.sourceRect = recoverSamplesButton.bounds
            }
        }
        
        let ok = UIAlertAction(title: NSLocalizedString("YES-DialogButtonTitle", comment: ""), style: .default) {_ in
            self.closeButton.isEnabled = false
            self.recoverSamplesButton.isEnabled = false
            self.indicator.isHidden = false
            self.indicator.startAnimating()
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                Settings.sharedInstance.recoverSamples()
                
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.indicator.isHidden = true
                    self.recoverSamplesButton.isEnabled = true
                    self.closeButton.isEnabled = true
                }
                
            }
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("NO-DialogButtonTitle", comment: ""), style: .cancel) {_ in
            
        }
        dialog.addAction(ok)
        dialog.addAction(cancel)
        
        present(dialog, animated: true)
    }
    
}
