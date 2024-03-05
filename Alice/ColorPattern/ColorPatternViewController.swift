//
//  ColorPatternViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2023/4/10.
//

import UIKit
import WebKit

class ColorPatternViewController: UIViewController {
        
    var articles: Array<(String, String, URL?)> = [
        (NSLocalizedString("ArticleExample-MenuItem", comment: ""), "article", nil),
        (NSLocalizedString("DiagramExample-MenuItem", comment: ""), "diagram", nil),
        (NSLocalizedString("UIExample-MenuItem", comment: ""), "ui", nil),
    ]
    
    @IBOutlet weak var patternView: WKWebView!
    @IBOutlet weak var schemeView: ColorSchemeView!
    @IBOutlet weak var actionNavigationbarItem: UIBarButtonItem!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var patternSelectionToolbarItem: UIBarButtonItem!
    @IBOutlet weak var patternTitle: UILabel!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let pattern = WebViewBasePattern.sharedInstance
    
    var activedArticle: (String, String, URL?)?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        
        createPatterns()
        activedArticle = articles[0]
        
        configureNavigationbar()
        configureToolbar()
        configurePatternView()
        configureSchemeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let generator = appDelegate.colorPatternGenerator, let scheme = generator.getScheme() else {
            return
        }
        
        schemeView.items = scheme.items
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let activedArticle = activedArticle {
            presentArticle(name: activedArticle.0)
        }
    }
    
    func createPatterns() {
        for i in 0 ..< articles.count {
            
            var styleURLs: Array<URL> = []
            
            var articleName = articles[i].1
            var styleName = articleName
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                articleName += "-compact"
                styleName += "-compact"
                
                if let url = pattern.style(name: styleName, items: [
                    "body-font-size" : "15px",
                    "body-line-height" : "1.5",
                    "page-text-color" : "#FFFFFF",
                    "page-background-color" : "#3B0E1E",
                    "selection-text-color": "#FFFFFF",
                    "selection-background-color": "#FF535F",
                    "underline-text-color": "#FFFFFF",
                    "underline-background-color": "#3B0E1E",
                    "underline-color": "#FF535F",
                ]) {
                    styleURLs.append(url)
                }
            }
            else if UIDevice.current.userInterfaceIdiom == .pad {
                if let url = pattern.style(name: styleName, items: [
                    "body-font-size" : "20px",
                    "body-line-height" : "1.5",
                    "page-text-color" : "#FFFFFF",
                    "page-background-color" : "#3B0E1E",
                    "selection-text-color": "#FFFFFF",
                    "selection-background-color": "#FF535F",
                    "underline-text-color": "#FFFFFF",
                    "underline-background-color": "#3B0E1E",
                    "underline-color": "#FF535F",
                ]) {
                    styleURLs.append(url)
                }
            }
            articles[i].2 = pattern.generate(name: articleName, styleURLs: styleURLs)
        }
    }
    
    func presentArticle(name: String) {
        for activedArticle in articles {
            if activedArticle.0 == name {
                if let url = activedArticle.2 {
//                    patternView.loadFileRequest(URLRequest(url: url), allowingReadAccessTo: pattern.getResourceDirectory())
//                    patternView.reload()
                    
                    patternView.load(URLRequest(url: url))
                    
                }
                break
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func configureSchemeView() {
        schemeView.animate = false
        schemeView.layer.cornerRadius = 10.0
        schemeView.layer.cornerCurve = .continuous
        schemeView.clipsToBounds = true
        
        schemeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigateToColorTable)))
    }
    
    func configurePatternView() {
        //patternView.layer.cornerRadius = 10;
        //patternView.layer.cornerCurve = .continuous
        patternView.clipsToBounds = true;
        patternView.uiDelegate = self
        patternView.navigationDelegate = self
        patternView.scrollView.delegate = self
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString("ColorPattern-NavigationTitle", comment: "")
                
        let items = [
            UIAction(title: NSLocalizedString("SchemeList-MenuItem", comment: ""), image: UIImage(named: "icon-list"), handler: { (_) in
            }),
            
            UIAction(title: NSLocalizedString("Portrait-MenuItem", comment: ""), image: UIImage(named: "icon-portrait"), handler: { (_) in
            }),
        ]
        actionNavigationbarItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: items)
        
    }
    
    func configureToolbar() {
        patternSelectionToolbarItem.menu = createPatternSelectionMenu()
    }
    
    func createPatternSelectionMenu() -> UIMenu {
        // filter item
        var actions: Array<UIAction> = []
        for i in 0 ..< articles.count {
            if let activedArticle = self.activedArticle {
                let action = UIAction(title: NSLocalizedString(articles[i].0, comment: ""), image: nil, state: activedArticle.0 == articles[i].0 ? .on : .off, handler: { (_) in
                    self.activedArticle = self.articles[i]
                    self.patternTitle.text = self.articles[i].0
                    self.patternSelectionToolbarItem.menu = self.createPatternSelectionMenu()
                    DispatchQueue.main.async {
                        self.presentArticle(name: self.articles[i].0)
                    }
                })
                actions.append(action)
            }
        }
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: actions)
    }
        
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func showAllFont() {
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })
    }
    
    @IBAction func navigateToColorTable(_ sender: Any) {
        performSegue(withIdentifier: "IDSegueColorPatternSchemeTable", sender: self)
    }
    
}

extension ColorPatternViewController: WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if (scrollView == patternView.scrollView) {
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
