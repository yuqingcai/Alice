//
//  PrivacyPolicyViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/3/14.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
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
        
        if let URL = Settings.sharedInstance.privacyPolicyURL {
            let request = URLRequest(url: URL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            webView.load(request)
        }
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("PrivacyPolicy-NavigationTitle", comment: "")
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension PrivacyPolicyViewController: WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if (scrollView == webView.scrollView) {
            scrollView.pinchGestureRecognizer?.isEnabled = false
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        indicator.isHidden = false
        indicator.startAnimating()
    }
        
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
        indicator.isHidden = true
    }
}
