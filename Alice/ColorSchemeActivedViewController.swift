//
//  ColorSchemeActivedViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/12/28.
//

import UIKit

class ColorSchemeActivedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
