//
//  TabBarController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/11.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        configureItems()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func configureItems() {
        if let viewControllers = viewControllers {
            for controller in viewControllers {
                if controller is CreationViewController {
                    controller.tabBarItem.title = NSLocalizedString("Creation-TabbarTitle", comment: "")
                }
                else if controller is ColorCardLibraryViewController {
                    controller.tabBarItem.title = NSLocalizedString("ColorCard-TabbarTitle", comment: "")
                }
                else if controller is MeViewController {
                    controller.tabBarItem.title = NSLocalizedString("Me-TabbarTitle", comment: "")
                }
            }
        }
    }
}
