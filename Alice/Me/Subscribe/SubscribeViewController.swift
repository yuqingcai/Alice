//
//  SubscribeViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/2/7.
//

import UIKit
import StoreKit

class SubscribeViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var promptTextView: UITextView!
    @IBOutlet weak var subscriptionTextView: UITextView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var productTableView: UITableView!
    
    var verifyReceiptState = true
    var productSelectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    var tableRowInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        configureNavigationbar()
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        promptTextView.text = NSLocalizedString("Prompt-Label", comment: "")
        subscriptionTextView.text = NSLocalizedString("SubscriptionPrompt-Label", comment: "")
        subscriptionTextView.textColor = UIColor.white
        if let copyrightString = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String  {
            copyrightLabel.text = copyrightString
        }
        
        productTableView.isHidden = false
        
        // products notification
        NotificationCenter.default.addObserver(self, selector: #selector(gotProductsNotificationResponder), name: AppStore.gotProductNotification, object: nil)
                
        // purchase notification
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseSuccessfulResponder), name: AppStore.purchaseSuccessfulNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchasingResponder), name: AppStore.purchasingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailedResponder), name: AppStore.purchaseFailedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseRestoredResponder), name: AppStore.purchaseRestoredNotification, object: nil)
        
        // UIScene
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillDeactivateResponder), name: UIScene.willDeactivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidActivateResponder), name: UIScene.didActivateNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // UIScene
        NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIScene.willDeactivateNotification, object: nil)
        // purchase notification
        NotificationCenter.default.removeObserver(self, name: AppStore.purchaseRestoredNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AppStore.purchaseFailedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AppStore.purchasingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AppStore.purchaseSuccessfulNotification, object: nil)
                
        // products notification
        NotificationCenter.default.removeObserver(self, name: AppStore.gotProductNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        userInputEnable()
        subscriptionTextView.text = NSLocalizedString("SubscriptionPrompt-Label", comment: "")
        
        // network detect
        if (NetworkReachability.isConnectedToNetwork() == false) {
            print("Internet Connection Unavailable!")
            performSegue(withIdentifier: "IDSegueSubscribeToNetworkNotification", sender: self)
            return
        }
        
        // get product details
        if (AppStore.sharedInstance.products == nil) {
            userInputDisable()
            AppStore.sharedInstance.getProducts()
        }        
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
        
        config.title = NSLocalizedString("Subscribe-ButtonTitle", comment: "")
        subscribeButton.configuration = config
        
        config.title = NSLocalizedString("Restore-ButtonTitle", comment: "")
        restoreButton.configuration = config
        
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("Subscription-NavigationTitle", comment: "")
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func userInputDisable() {
        subscribeButton.isEnabled = false
        restoreButton.isEnabled = false
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    private func userInputEnable() {
        subscribeButton.isEnabled = true
        restoreButton.isEnabled = true
        indicator.isHidden = true
        indicator.stopAnimating()
    }
            
    @objc func gotProductsNotificationResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.subscriptionTextView.text = NSLocalizedString("SubscriptionPrompt-Label", comment: "")
            self.userInputEnable()
            self.productTableView.reloadData()
        }
    }
    
    @objc func purchaseSuccessfulResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.subscriptionTextView.text = NSLocalizedString("SubscriptionSuccessful-Label", comment: "")
            self.subscriptionTextView.textColor = UIColor.systemRed
            self.userInputEnable()
            self.productTableView.isHidden = true
            print("purchase successful")
        }
    }
    
    @objc func purchasingResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.subscriptionTextView.text = NSLocalizedString("SubcriptionPurchasing-Label", comment: "")
            self.subscriptionTextView.textColor = UIColor.systemRed
            print("purchasing")
        }
    }
    
    @objc func purchaseFailedResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.subscriptionTextView.text = NSLocalizedString("SubcriptionPurchaseFailed-Label", comment: "")
            self.subscriptionTextView.textColor = UIColor.systemRed
            self.userInputEnable()
            print("purchase failed")
        }
    }
    
    @objc func purchaseRestoredResponder(_ notification: NSNotification) {
        DispatchQueue.main.async {
            print("purchase restored")
        }
    }
    
    @IBAction func subscribe(_ sender: Any) {
        if NetworkReachability.isConnectedToNetwork() == false {
            print("Internet Connection Not available!")
            performSegue(withIdentifier: "IDSegueSubscribeToNetworkNotification", sender: self)
            return
        }
        
        if Settings.sharedInstance.isSubscriptionActive == true {
            let dialog = UIAlertController(title: nil, message: NSLocalizedString("SubscriptionIsActived-Label", comment: ""), preferredStyle: .alert)
            dialog.overrideUserInterfaceStyle = .dark
            let ok = UIAlertAction(title: NSLocalizedString("OK-DialogButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            })
            dialog.addAction(ok)
            present(dialog, animated: true, completion: nil)
        }
        else {
            if let products = AppStore.sharedInstance.products {
                subscriptionTextView.text = NSLocalizedString("SubcriptionPurchasing-Label", comment: "")
                AppStore.sharedInstance.payProduct(product: products[productSelectedIndex.row])
                self.userInputDisable()
            }
        }
    }
        
    @IBAction func restore(_ sender: Any) {
        
        if NetworkReachability.isConnectedToNetwork() == false {
            print("Internet Connection Not available!")
            performSegue(withIdentifier: "IDSegueSubscribeToNetworkNotification", sender: self)
            return
        }
        
        if Settings.sharedInstance.isSubscriptionActive == true {
            let dialog = UIAlertController(title: nil, message: NSLocalizedString("RestoreComplete-Label", comment: ""), preferredStyle: .alert)
            dialog.overrideUserInterfaceStyle = .dark
            let ok = UIAlertAction(title: NSLocalizedString("OK-DialogButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            })
            dialog.addAction(ok)
            present(dialog, animated: true, completion: nil)
        }
        else {
            let dialog = UIAlertController(title: nil, message: NSLocalizedString("RestoreFailed-Label", comment: ""), preferredStyle: .alert)
            dialog.overrideUserInterfaceStyle = .dark
            let ok = UIAlertAction(title: NSLocalizedString("OK-DialogButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            })
            dialog.addAction(ok)
            present(dialog, animated: true, completion: nil)
        }
    }
    
}

extension SubscribeViewController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppStore.sharedInstance.products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let products = AppStore.sharedInstance.products else {
            return tableView.dequeueReusableCell(withIdentifier: "IDStorePaymentProductTableViewCell", for:indexPath) as! SchemeTableViewCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IDStorePaymentProductTableViewCell", for:indexPath) as! StorePaymentProductTableViewCell
        cell.tag = indexPath.row
        
        cell.selectionStyle = .none
        cell.backgroundView = UIView()
        cell.backgroundView?.backgroundColor = UIColor(named: "color-window-background")
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor(named: "color-window-background")
        
        let product = products[indexPath.row]
        if (product.productIdentifier == AppStore.sharedInstance.subscriptionMonthlyIdentifier) {
            cell.productView.productTitle = NSLocalizedString("ProductSubscriptionMonthlyTitle", comment: "")
            cell.productView.productDescription = NSLocalizedString("ProductSubscriptionMonthlyDescription", comment: "")
            
        }
        else if (product.productIdentifier == AppStore.sharedInstance.subscriptionYearlyIdentifier) {
            cell.productView.productTitle = NSLocalizedString("ProductSubscriptionYearlyTitle", comment: "")
            cell.productView.productDescription = NSLocalizedString("ProductSubscriptionYearlyDescription", comment: "")
        }
        
        // price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        if let priceString = formatter.string(from: product.price) {
            cell.productView.productPrice = priceString
        }
        
        if indexPath.row == productSelectedIndex.row {
            cell.productView.actived = true
        }
        else {
            cell.productView.actived = false
        }
        
        cell.separatorInset = UIEdgeInsets(top: tableRowInsets.top, left: tableRowInsets.left, bottom: tableRowInsets.bottom, right: tableRowInsets.right)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = 70.0
        if UIDevice.current.userInterfaceIdiom == .phone {
            rowHeight = 70.0
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            rowHeight = 120.0
        }
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousSelectedIndex = productSelectedIndex
        productSelectedIndex = indexPath
        tableView.reloadRows(at: [previousSelectedIndex, productSelectedIndex], with: .none)
    }
    
    @objc func sceneWillDeactivateResponder() {
        
    }
    
    @objc func sceneDidActivateResponder() {
        // network detect
        if (NetworkReachability.isConnectedToNetwork() == false) {
            print("Internet Connection Unavailable!")
            performSegue(withIdentifier: "IDSegueSubscribeToNetworkNotification", sender: self)
            return
        }
        
        // get product details
        if (AppStore.sharedInstance.products == nil) {
            userInputDisable()
            AppStore.sharedInstance.getProducts()
        }
        
    }
    
}
