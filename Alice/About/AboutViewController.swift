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
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    
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
        
        config.title = NSLocalizedString("PrivacyPolicy-ButtonTitle", comment: "")
        privacyPolicyButton.configuration = config
        
        config.title = NSLocalizedString("TermsAndConditions-ButtonTitle", comment: "")
        termsAndConditionsButton.configuration = config
    }
    
    @IBAction func recoverSamples(_ sender: Any) {
        
        closeButton.isEnabled = false
        recoverSamplesButton.isEnabled = false
        indicator.isHidden = false
        indicator.startAnimating()
                
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
    
}
