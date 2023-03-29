//
//  MeViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/10.
//

import UIKit

class MeViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
        configureNavigationbar()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func configureNavigationbar() {
        navigationBar.clipsToBounds = true
        navigationBar.topItem?.title = NSLocalizedString("Me-NavigationTitle", comment: "")
    }

}

