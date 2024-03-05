//
//  ColorCardLibraryViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/7.
//

import UIKit

class ColorCardLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    enum ColorCardStyle {
        case all
        case national
        case hightContrast
        case analogous
        case light
        case dark
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var libraryView: UICollectionView!
    @IBOutlet weak var actionNavigationbarItem: UIBarButtonItem!
    @IBOutlet weak var filterNavigationbarItem: UIBarButtonItem!
    
    var cellSizeRatio = 0.5 // height : width
    var cardStyle: ColorCardStyle = .all {
        didSet {
            print("card style changed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationbar()
        configureTabbar()
        
        overrideUserInterfaceStyle = .dark
        
        libraryView.backgroundColor = UIColor.clear
        libraryView.overrideUserInterfaceStyle = .dark
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // reload collection with animation
        UIView.transition(with: libraryView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.libraryView.reloadData()
        })
    }
    
    func configureNavigationbar() {
        navigationBar.clipsToBounds = true
        navigationBar.topItem?.title = NSLocalizedString("ColorCard-NavigationTitle", comment: "")
        
        // create item
        let createFromLibrary = UIAction(title: NSLocalizedString("CreateColorCardFromLibrary-MenuItem", comment: ""), image: UIImage(named: "icon-library"), handler: { (_) in
        })
        
        let createFromPhoto = UIAction(title: NSLocalizedString("CreateColorCardFromPhoto-MenuItem", comment: ""), image: UIImage(named: "icon-photo"), handler: { (_) in
        })
        
        let colorCardGenerate = UIAction(title: NSLocalizedString("CreateColorCardCustom-MenuItem", comment: ""), image: UIImage(named: "icon-color-ring"), handler: { (_) in
            self.appDelegate.colorSchemeGenerator = self.appDelegate.colorCardGenerator
            self.performSegue(withIdentifier: "IDSegueColorCardGenerate", sender: self)
        })
            
        let group0 = UIMenu(title: "", options: .displayInline, children: [createFromLibrary, createFromPhoto])
        
        let group1 = UIMenu(title: "", options: .displayInline, children: [colorCardGenerate])
        
        actionNavigationbarItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [group0, group1])
        
        
        filterNavigationbarItem.menu = createStyleFilterMenu()
    }
    
    func createStyleFilterMenu() -> UIMenu {
        // filter item
        let all = UIAction(title: NSLocalizedString("ColorCardFromAll-MenuItem", comment: ""), image: nil, state: self.cardStyle == .all ? .on : .off, handler: { (_) in
            self.cardStyle = .all
            self.filterNavigationbarItem.menu = self.createStyleFilterMenu()
        })
        
        let nation = UIAction(title: NSLocalizedString("ColorCardFromNationStyle-MenuItem", comment: ""), image: nil, state: self.cardStyle == .national ? .on : .off, handler: {  (_) in
            self.cardStyle = .national
            self.filterNavigationbarItem.menu = self.createStyleFilterMenu()
        })
        
        let highContrast = UIAction(title: NSLocalizedString("ColorCardFromHighContrast-MenuItem", comment: ""), image: nil,  state: self.cardStyle == .hightContrast ? .on : .off, handler: {  (_) in
            self.cardStyle = .hightContrast
            self.filterNavigationbarItem.menu = self.createStyleFilterMenu()
        })
        
        let analogous = UIAction(title: NSLocalizedString("ColorCardFromAnalogous-MenuItem", comment: ""), image: nil, state: self.cardStyle == .analogous ? .on : .off, handler: { (_) in
            self.cardStyle = .analogous
            self.filterNavigationbarItem.menu = self.createStyleFilterMenu()
        })
                
        let light = UIAction(title: NSLocalizedString("ColorCardFromLight-MenuItem", comment: ""), image: nil, state: self.cardStyle == .light ? .on : .off, handler: {  (_) in
            self.cardStyle = .light
            self.filterNavigationbarItem.menu = self.createStyleFilterMenu()
        })
        
        let dark = UIAction(title: NSLocalizedString("ColorCardFromDark-MenuItem", comment: ""), image: nil, state: self.cardStyle == .dark ? .on : .off, handler: {  (_) in
            self.cardStyle = .dark
            self.filterNavigationbarItem.menu = self.createStyleFilterMenu()
        })
        
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [ all, nation, highContrast, analogous, light, dark ])
        
    }
    
    func configureTabbar() {
        tabBarItem.title = NSLocalizedString("ColorCard-TabbarTitle", comment: "")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let colorCardlibrary = appDelegate.colorCardLibrary {
            return colorCardlibrary.numberOfColorCards()
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IDColorCardLibraryItemViewCell", for: indexPath) as! ColorCardLibraryItemViewCell
        cell.layer.cornerRadius = 20.0
        cell.layer.cornerCurve = .continuous
        cell.clipsToBounds = true
        
        if let colorCardlibrary = appDelegate.colorCardLibrary, let card = colorCardlibrary.colorCard(at: indexPath.item) {
            // card thumbnial size: 1024 x 512 (width x height)
            cell.image = card.getThumbnail()
        }
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let colorPatternGenerator = self.appDelegate.colorPatternGenerator, let colorCardlibrary = self.appDelegate.colorCardLibrary, let card = colorCardlibrary.colorCard(at: indexPath.item) else {
            return
        }
        
        colorPatternGenerator.generate(by: card);
        appDelegate.colorSchemeGenerator = card
        performSegue(withIdentifier: "IDSegueColorPattern", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemsPerRow = 1
        if UIDevice.current.userInterfaceIdiom == .phone {
            itemsPerRow = 1
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            itemsPerRow = 2
        }
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = (collectionView.frame.width - (layout.minimumInteritemSpacing * CGFloat(itemsPerRow - 1)) - layout.sectionInset.left - layout.sectionInset.right) / CGFloat(itemsPerRow)
        let height = width * cellSizeRatio
        return CGSize(width:width, height:height)
    }
}
