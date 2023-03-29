//
//  NavigationController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/1/19.
//

import UIKit

class NavigationController: UINavigationController, UINavigationControllerDelegate, UINavigationBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        delegate = self
        
        view.backgroundColor = UIColor(named: "color-window-background")
        toolbar.tintColor = UIColor(named: "color-toolbar-item")
        
        navigationBar.tintColor = UIColor(named: "color-navigationbar-item")
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor(named: "color-navigationbar-item") ?? UIColor.white,
        ]
//        navigationBar.delegate = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
