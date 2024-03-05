//
//  CreationViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/7.
//

import UIKit

class CreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let imagePicker = UIImagePickerController()
    var maxItemsInLibraryView = 10
    var libraryItemEffectView: UIVisualEffectView?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var colorWheelButton: UIButton!
    @IBOutlet weak var libraryView: UICollectionView!
    @IBOutlet weak var libraryButton: UIButton!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupButtons()
        configureNavigationbar()
        configureTabbar()
        overrideUserInterfaceStyle = .dark
        
        libraryView.backgroundColor = UIColor.clear
        libraryView.overrideUserInterfaceStyle = .dark
        imagePicker.overrideUserInterfaceStyle = .dark
        if UIDevice.current.userInterfaceIdiom == .phone {
            maxItemsInLibraryView = 10
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            maxItemsInLibraryView = 40
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLibraryNoticationResponder), name: LocalLibrary.updateItemsNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkDisabledNoticationResponder), name: NetworkReachability.unreachableNotification, object: nil)
        
        // reload collection with animation
        UIView.transition(with: libraryView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.libraryView.reloadData()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NetworkReachability.unreachableNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: LocalLibrary.updateItemsNotification, object: nil)
    }
    
    func setupButtons() {
        
        func subtitleFontSize() -> CGFloat {
            let language = languageString(NSLocale.preferredLanguages[0])
            if (language.caseInsensitiveCompare("ChineseSimplified") == .orderedSame ||
                language.caseInsensitiveCompare("ChineseTraditional") == .orderedSame ||
                language.caseInsensitiveCompare("Japanese") == .orderedSame ||
                language.caseInsensitiveCompare("Korean") == .orderedSame) {
                return 16.0
            }
            return 14.0
        }
        
        let titleTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = UIColor(named: "color-title")
            outgoing.font = UIFont.boldSystemFont(ofSize: 18)
            return outgoing
        }
        let subTitleTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = UIColor(named: "color-subtitle")
            outgoing.font = UIFont.systemFont(ofSize: subtitleFontSize())
            return outgoing
        }
        var config = UIButton.Configuration.plain()
        config.titleTextAttributesTransformer = titleTransformer
        config.subtitleTextAttributesTransformer = subTitleTransformer
        config.baseBackgroundColor = UIColor.clear
        config.imagePadding = 12
        config.titleAlignment = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
        
        config.title = NSLocalizedString("Photo-ButtonTitle", comment: "")
        config.subtitle = NSLocalizedString("Photo-ButtonSubtitle", comment: "")
        photoButton.setImage(UIImage(named: "icon-photo"), for: .normal)
        photoButton.configuration = config
        photoButton.tintColor = UIColor(named: "color-title")
        
        config.title = NSLocalizedString("ColorWheel-ButtonTitle", comment: "")
        config.subtitle = NSLocalizedString("ColorWheel-ButtonSubtitle", comment: "")
        colorWheelButton.setImage(UIImage(named: "icon-color-ring"), for: .normal)
        colorWheelButton.configuration = config
        colorWheelButton.tintColor = UIColor(named: "color-title")
                
        config.title = NSLocalizedString("Library-ButtonTitle", comment: "")
        config.subtitle = ""
        libraryButton.setImage(UIImage(named: "icon-library"), for: .normal)
        libraryButton.configuration = config
        libraryButton.tintColor = UIColor(named: "color-title")
    }
    
    @IBAction func openImage(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func openColorWheel(_ sender: Any) {
        appDelegate.colorSchemeGenerator = appDelegate.colorComposer
        performSegue(withIdentifier: "IDSegueColorComposer", sender: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage? = nil
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = pickedImage.flattened(isOpaque: true)
        }
        dismiss(animated: true, completion: nil)
        
        if let colorSampler = appDelegate.colorSampler, let selectedImage = selectedImage {
            colorSampler.set(photo: selectedImage)
            appDelegate.colorSchemeGenerator = colorSampler
            performSegue(withIdentifier: "IDSegueColorSample", sender: self)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let localLibrary = appDelegate.localLibrary else {
            return 0
        }
        
        var numberOfSnapshoot = localLibrary.numberOfSnapshootOrderByModifiedDateDescending()
        if numberOfSnapshoot > 20 {
            numberOfSnapshoot = 20
        }
        return numberOfSnapshoot
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IDLocalLibraryItemViewCell", for: indexPath) as! LocalLibraryItemViewCell
        cell.layer.cornerRadius = 20.0
        cell.layer.cornerCurve = .continuous
        cell.clipsToBounds = true
        
        if let localLibrary = appDelegate.localLibrary, let snapshoot = localLibrary.snapshoot(at: indexPath.item) {
            cell.image = localLibrary.thumbnail(by: snapshoot)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: {
            suggestedActions in
            
            guard let colorSampler = self.appDelegate.colorSampler, let colorComposer = self.appDelegate.colorComposer, let localLibrary = self.appDelegate.localLibrary, let snapshoot = localLibrary.snapshoot(at: indexPath.item) else {
                return UIMenu(title: "", children: [])
            }
            
            let open = UIAction(title: NSLocalizedString("Open-MenuItem", comment: ""), image: UIImage(systemName: "eye")) { action in
                
                if (snapshoot.type == .colorSample) {
                    colorSampler.restore(by: snapshoot);
                    self.appDelegate.colorSchemeGenerator = colorSampler
                    self.performSegue(withIdentifier: "IDSegueColorSample", sender: self)
                }
                else if (snapshoot.type == .colorCompose) {
                    colorComposer.restore(by: snapshoot);
                    self.appDelegate.colorSchemeGenerator = colorComposer
                    self.performSegue(withIdentifier: "IDSegueColorComposer", sender: self)
                }
            }
                        
            let delete = UIAction(title: NSLocalizedString("Delete-MenuItem", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                
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
        
        guard let colorSampler = self.appDelegate.colorSampler, let colorComposer = self.appDelegate.colorComposer, let localLibrary = self.appDelegate.localLibrary, let snapshoot = localLibrary.snapshoot(at: indexPath.item) else {
            return
        }
        
        if (snapshoot.type == .colorSample) {
            colorSampler.restore(by: snapshoot);
            appDelegate.colorSchemeGenerator = colorSampler
            performSegue(withIdentifier: "IDSegueColorSample", sender: self)
        }
        else if (snapshoot.type == .colorCompose) {
            colorComposer.restore(by: snapshoot);
            appDelegate.colorSchemeGenerator = colorComposer
            performSegue(withIdentifier: "IDSegueColorComposer", sender: self)
        }
    }
    
    @IBAction func updateLibraryNoticationResponder (_ notification:NSNotification) {
        // reload tableview with animation
        UIView.transition(with: libraryView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.libraryView.reloadData()
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == libraryView {
        }
    }
    
    func configureNavigationbar() {
        navigationBar.clipsToBounds = true
        navigationBar.topItem?.title = NSLocalizedString("Creation-NavigationTitle", comment: "")
    }
    
    func configureTabbar() {
        tabBarItem.title = NSLocalizedString("Creation-TabbarTitle", comment: "")
    }
    
    @IBAction func networkDisabledNoticationResponder (_ notification:NSNotification) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "IDSegueCreationToNetworkNotification", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "IDSegueCreationToNetworkNotification" && segue.destination is NetworkNotificationViewController) {
            print("Navigate to NetworkNotification ViewController")
        }
    }
    
}
