//
//  NetworkNotificationViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/27.
//

import UIKit

class NetworkNotificationViewController: UIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var infoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        setupButtons()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
        
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        infoTextView.text = NSLocalizedString("NetworkSettingsCheckingRequest-DialogMessage", comment: "")
        infoImageView.image = UIImage(named: "illustration-offline-dinosaur")
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
        
        config.title = NSLocalizedString("YES-DialogButtonTitle", comment: "")
        confirmButton.configuration = config
        
        config.title = NSLocalizedString("Cancel-DialogButtonTitle", comment: "")
        cancelButton.configuration = config
    }
    
    @IBAction func redirectToNetworkSettings(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: {
            _ in
            self.dismiss(animated: true) {
            }
        })
    }
        
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true) {
        }
    }
}
