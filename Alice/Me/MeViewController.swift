//
//  MeViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/10.
//

import UIKit

class MeViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var items: Array<(String, String, String, String)> = [
        (
            "Subscription",
            "icon-coffee",
            NSLocalizedString("Subscription-TableItem", comment: ""),
            "IDSegueSubscribe"
        ),
        
        (
            "Manual",
            "icon-manual",
            NSLocalizedString("Manual-TableItem", comment: ""),
            "IDSegueManual"
        ),
        
        (
            "PrivacyPolicy",
            "icon-eye-slash",
            NSLocalizedString("PrivacyPolicy-TableItem", comment: ""),
            "IDSeguePrivacyPolicy"
        ),
        (
            "Terms",
            "icon-plain-text",
            NSLocalizedString("TermsAndConditions-TableItem", comment: ""),
            "IDSegueTermsAndConditions"
        ),
        (
            "About",
            "icon-about",
            NSLocalizedString("About-TableItem", comment: ""),
            "IDSegueAbout"
        ),
    ]
        
    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
        configureNavigationbar()
        configureTabbar()
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
    
    func configureTabbar() {
        tabBarItem.title = NSLocalizedString("Me-TabbarTitle", comment: "")
    }
    
}

extension MeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // profile section
        if (section == 0) {
            return 1
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IDMeTableViewProfileCell", for:indexPath) as! MeTableViewProfileCell
            cell.selectionStyle = .none
            cell.backgroundView = UIView()
            cell.backgroundView?.backgroundColor = UIColor(named: "color-window-background")
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView?.backgroundColor = UIColor(named: "color-window-background")
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.iconView.image = UIImage(named: "illustration-coloury")
            
            if let marketingVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String  {
                cell.itemLabel.text = "Version " + marketingVersion
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IDMeTableViewItemCell", for:indexPath) as! MeTableViewItemCell
            cell.selectionStyle = .none
            cell.backgroundView = UIView()
            cell.backgroundView?.backgroundColor = UIColor(named: "color-window-background")
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView?.backgroundColor = UIColor(named: "color-window-background")
            cell.iconView.image = UIImage(named: items[indexPath.row].1)
            cell.itemLabel.text = items[indexPath.row].2
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 0.0)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180.0
        }
        return 55.0
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        return NSLocalizedString("Me-TableHeader", comment: "")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            performSegue(withIdentifier: items[indexPath.row].3, sender: self)
        }
    }
    
}
