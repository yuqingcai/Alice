//
//  ViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/7.
//

import UIKit

class CreateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    let imagePicker = UIImagePickerController()
    var selectedImage:UIImage!
        
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .dark
//        searchTextField.layer.cornerRadius = 12
//        searchTextField.layer.masksToBounds = true
//        searchTextField.addPadding(padding: .equalSpacing(10))
//        searchTextField.addPadding(padding: .right(10))
//        searchTextField.addPadding(padding: .left(10))
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func openImage(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func openColorWheel(_ sender: Any) {
        performSegue(withIdentifier: "IDSegueColorSchemeFromColorWheel", sender: self)
    }
    
    @IBAction func openContrast(_ sender: Any) {
        performSegue(withIdentifier: "IDSegueCreateContrast", sender: self)
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
        
        if (selectedImage != nil) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.photoColorSehemeGenerator.setPhoto(selectedImage);
            performSegue(withIdentifier: "IDSegueColorSchemeFromPhoto", sender: self)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}



extension UITextField {
    
    enum PaddingSpace {
        case left(CGFloat)
        case right(CGFloat)
        case equalSpacing(CGFloat)
    }
    
    func addPadding(padding: PaddingSpace) {
        
        self.leftViewMode = .always
        self.layer.masksToBounds = true
        
        switch padding {
            
        case .left(let spacing):
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = leftPaddingView
            self.leftViewMode = .always
            
        case .right(let spacing):
            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = rightPaddingView
            self.rightViewMode = .always
            
        case .equalSpacing(let spacing):
            let equalPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = equalPaddingView
            self.leftViewMode = .always
            // right
            self.rightView = equalPaddingView
            self.rightViewMode = .always
        }
    }
}
