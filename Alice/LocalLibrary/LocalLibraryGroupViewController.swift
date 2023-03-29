//
//  LocalLibraryGroupViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/12/27.
//

import UIKit

class LocalLibraryGroupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
}
