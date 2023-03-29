//
//  LocalLibraryViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/12/23.
//

import UIKit

class LocalLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var libraryView: UICollectionView!
    @IBOutlet weak var actionNavigationbarItem: UIBarButtonItem!
    @IBOutlet weak var deleteToolbarItem: UIBarButtonItem!
    @IBOutlet weak var cancelToolbarItem: UIBarButtonItem!
    
    var libraryViewOrderType: LocalLibraryOrderType = .createDateDescending
    var libraryViewSelections: Array<IndexPath>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationbar()
        configureToolbar()
        
        overrideUserInterfaceStyle = .dark
        libraryView.backgroundColor = UIColor.clear
        libraryView.overrideUserInterfaceStyle = .dark
    }
    
    func configureToolbar() {
        navigationController?.setToolbarHidden(true, animated: false)
        deleteToolbarItem.isEnabled = false
        cancelToolbarItem.title = NSLocalizedString("Cancel-ToolbarItem", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        libraryView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLibraryNoticationResponder), name: LocalLibrary.updateItemsNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: LocalLibrary.updateItemsNotification, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let localLibrary = appDelegate.localLibrary else {
            return 0
        }
        
        switch (libraryViewOrderType) {
        case .createDateAscending:
            return localLibrary.numberOfSnapshootOrderByCreateDateAscending()
        case .createDateDescending:
            return localLibrary.numberOfSnapshootOrderByCreateDateDescending()
        case .modifyDateAscending:
            return localLibrary.numberOfSnapshootOrderByModifiedDateAscending()
        case .modifyDateDescending:
            return localLibrary.numberOfSnapshootOrderByModifiedDateDescending()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemsPerRow = 2
        if UIDevice.current.userInterfaceIdiom == .phone {
            itemsPerRow = 2
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            itemsPerRow = 4
        }
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = (collectionView.frame.width - (layout.minimumInteritemSpacing * CGFloat(itemsPerRow - 1)) - layout.sectionInset.left - layout.sectionInset.right) / CGFloat(itemsPerRow)
        let height = width
        return CGSize(width:width, height:height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IDLocalLibraryItemDetailViewCell", for: indexPath) as! LocalLibraryItemDetailViewCell
        
        cell.layer.cornerRadius = 20.0
        cell.layer.cornerCurve = .continuous
        cell.clipsToBounds = true
        
        if let localLibrary = appDelegate.localLibrary, let snapshoot = localLibrary.snapshoot(at: indexPath.item) {
            cell.image = localLibrary.thumbnail(by: snapshoot)
            if (collectionView.allowsMultipleSelection == true) {
                cell.isMarkable = true
            }
            else {
                cell.isMarkable = false
            }
            
            if let libraryViewSelections = libraryViewSelections {
                if (libraryViewSelections.contains(indexPath)) {
                    cell.isMarked = true
                }
                else {
                    cell.isMarked = false
                }
            }
            else {
                cell.isMarked = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        if (libraryView.allowsMultipleSelection == true) {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: {
            suggestedActions in
            
            let open = UIAction(title: NSLocalizedString("Open-MenuItem", comment: ""), image: UIImage(systemName: "eye")) { action in
                guard let colorSampler = self.appDelegate.colorSampler, let colorComposer = self.appDelegate.colorComposer, let localLibrary = self.appDelegate.localLibrary, let snapshoot = localLibrary.snapshoot(at: indexPath.item) else {
                    return
                }
                if (snapshoot.type == .colorSample) {
                    colorSampler.restore(by: snapshoot);
                    self.appDelegate.colorSchemeGenerator = colorSampler
                    self.performSegue(withIdentifier: "IDSegueColorSchemeFromPhoto", sender: self)
                }
                else if (snapshoot.type == .colorCompose) {
                    colorComposer.restore(by: snapshoot);
                    self.appDelegate.colorSchemeGenerator = colorComposer
                    self.performSegue(withIdentifier: "IDSegueColorSchemeFromColorWheel", sender: self)
                }
            }
            
            let delete = UIAction(title: NSLocalizedString("Delete-MenuItem", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                
                guard let localLibrary = self.appDelegate.localLibrary else {
                    return
                }
                
                let dialogMessage = UIAlertController(title: nil, message: NSLocalizedString("DeleteItem?-DialogMessage", comment: ""), preferredStyle: .alert)
                dialogMessage.overrideUserInterfaceStyle = .dark
                
                // Create OK button with action handler
                let ok = UIAlertAction(title: NSLocalizedString("OK-DialogButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
                    if localLibrary.delete(at: indexPath) {
                        collectionView.deleteItems(at: [indexPath])
                    }
                })
                // Create Cancel button with action handlder
                let cancel = UIAlertAction(title: NSLocalizedString("NO-DialogButtonTitle", comment: ""), style: .cancel) { (action) -> Void in
                    print("Cancel button tapped")
                }
                //Add OK and Cancel button to an Alert object
                dialogMessage.addAction(ok)
                dialogMessage.addAction(cancel)
                // Present alert message to user
                self.present(dialogMessage, animated: true, completion: nil)
            }
            
            return UIMenu(title: "", children: [open, delete])
        })
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if libraryView.allowsMultipleSelection == true {
            if libraryViewSelections == nil {
                libraryViewSelections = [ indexPath ]
            }
            else {
                if (libraryViewSelections!.contains(indexPath)) {
                    if let index = libraryViewSelections!.firstIndex(of: indexPath) {
                        libraryViewSelections!.remove(at: index)
                    }
                }
                else {
                    libraryViewSelections!.append(indexPath)
                }
                
            }
            
            libraryView.reloadItems(at: [indexPath])
            
            if let libraryViewSelections = libraryViewSelections {
                if libraryViewSelections.count != 0 {
                    deleteToolbarItem.isEnabled = true
                }
                else {
                    deleteToolbarItem.isEnabled = false
                }
            }
                        
            return
        }
        else {
            guard let colorSampler = appDelegate.colorSampler, let colorComposer = appDelegate.colorComposer, let localLibrary = appDelegate.localLibrary, let snapshoot = localLibrary.snapshoot(at: indexPath.item) else {
                return
            }
            if (snapshoot.type == .colorSample) {
                colorSampler.restore(by: snapshoot);
                appDelegate.colorSchemeGenerator = colorSampler
                performSegue(withIdentifier: "IDSegueColorSchemeFromPhoto", sender: self)
            }
            else if (snapshoot.type == .colorCompose) {
                colorComposer.restore(by: snapshoot);
                appDelegate.colorSchemeGenerator = colorComposer
                performSegue(withIdentifier: "IDSegueColorSchemeFromColorWheel", sender: self)
            }
        }
    }
    
    @IBAction func updateLibraryNoticationResponder (_ notification:NSNotification) {
        libraryView.reloadData()
    }
        
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
    func configureNavigationbar() {
        navigationItem.title = NSLocalizedString(NSLocalizedString("Library-NavigationTitle", comment: ""), comment: "")
                    
        let selection = UIAction(title: NSLocalizedString("Selection-MenuItem", comment: ""), image: UIImage(named: "icon-selection"), handler: { (_) in
                if (self.libraryView.allowsMultipleSelection == false) {
                    self.libraryView.allowsMultipleSelection = true
                    self.navigationController?.setToolbarHidden(false, animated: true)
                    self.libraryView.reloadData()
                }
        })
            
        let createDateDesc = UIAction(title: NSLocalizedString("OrderByCreateDateDescending-MenuItem", comment: ""), image: UIImage(named: "icon-selection"), handler: { (_) in
                self.exitSelectionMode()
                self.libraryViewOrderType = .createDateDescending
                UIView.transition(with: self.libraryView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.libraryView.reloadData()
                })
        })

        let createDateAsc = UIAction(title: NSLocalizedString("OrderByCreateDateAscending-MenuItem", comment: ""), image: UIImage(named: "icon-selection"), handler: { (_) in
                self.exitSelectionMode()
                self.libraryViewOrderType = .createDateAscending
                UIView.transition(with: self.libraryView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.libraryView.reloadData()
                })
        })

        let modifyDateDesc = UIAction(title: NSLocalizedString("OrderByModifyDateDescending-MenuItem", comment: ""), image: UIImage(named: "icon-selection"), handler: { (_) in
                self.exitSelectionMode()
                self.libraryViewOrderType = .modifyDateDescending
                UIView.transition(with: self.libraryView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.libraryView.reloadData()
                })
        })
        
        let modifyDateAsc = UIAction(title: NSLocalizedString("OrderByModifyDateAscending-MenuItem", comment: ""), image: UIImage(named: "icon-selection"), handler: { (_) in
                self.exitSelectionMode()
                self.libraryViewOrderType = .modifyDateAscending
                UIView.transition(with: self.libraryView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.libraryView.reloadData()
                })
        })
        
        
        let group0 = UIMenu(title: "", options: .displayInline, children: [selection])
        let group1 = UIMenu(title: NSLocalizedString("Order-MenuItem", comment: ""), options: .displayInline, children: [createDateDesc, createDateAsc, modifyDateDesc, modifyDateAsc])
        
        actionNavigationbarItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [group0, group1])
    }
        
    @IBAction func deleteItems(_ sender: Any) {
        
        guard let localLibrary = appDelegate.localLibrary, let indexPaths = libraryViewSelections else {
            return
        }
        
        let dialog = UIAlertController(title: nil, message: NSLocalizedString("DeleteItem?-DialogMessage", comment: ""), preferredStyle: .alert)
        dialog.overrideUserInterfaceStyle = .dark
        
        let ok = UIAlertAction(title: NSLocalizedString("YES-DialogButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
                        
            if localLibrary.deleteItems(at: indexPaths) {
                self.libraryView.deleteItems(at: indexPaths)
            }
            
            self.libraryViewSelections = nil
            self.deleteToolbarItem.isEnabled = false
            
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("NO-DialogButtonTitle", comment: ""), style: .cancel, handler: { (action) -> Void in
        })
        dialog.addAction(ok)
        dialog.addAction(cancel)
        
        present(dialog, animated: true, completion: nil)
        
    }
    
    private func exitSelectionMode() {
        if (libraryView.allowsMultipleSelection == true) {
            libraryView.allowsMultipleSelection = false
            libraryViewSelections = nil
            
            libraryViewSelections = nil
            libraryView.reloadData()
            
            if (deleteToolbarItem.isEnabled == true) {
                deleteToolbarItem.isEnabled = false
                
            }
        }
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @IBAction func cancelToolbarItemAction(_ sender: Any) {
        exitSelectionMode()
    }
    
}
