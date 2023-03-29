//
//  SampleSchemeOperationViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/19.
//

import UIKit

class SampleSchemeOperationViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var colorSchemeSizeSlider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    private var values: Array<Int>?
    var update = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
        baseView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        baseView.layer.cornerRadius = 25
        baseView.layer.masksToBounds = true
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            values = [5, 10, 15, 20]
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            values = [5, 10, 20, 30, 40]
        }
        
        guard let generator = appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex(), let schemes = generator.getSchemes() else {
            return
        }
        
        let scheme = schemes[activedSchemeIndex]
        colorSchemeSizeSlider.minimumValue = 0
        colorSchemeSizeSlider.maximumValue = Float((values?.count ?? 1) - 1)
        
        for i in 0 ..< values!.count {
            if values![i] == scheme.items.count {
                colorSchemeSizeSlider.value = Float(i)
            }
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapView)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = NSLocalizedString("ColorsLevel-Label", comment: "")
        valueLabel.text = NSLocalizedString("ColorNumber-Label", comment: "")
    }
    
    @IBAction func colorSchemeSizeChanged(_ sender: UISlider) {
        guard let generator = self.appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex() else {
            return
        }
        
        colorSchemeSizeSlider.value = roundf(colorSchemeSizeSlider.value)
        generator.setScheme(colorCount: Int(colorSchemeSizeSlider.value), index: activedSchemeIndex)
        update = true
    }
    
    @IBAction func tapView(_ sender:UIPinchGestureRecognizer) {
        close(sender)
    }
    
    func close(_ sender: Any) {
        dismiss(animated: true) {
            if self.update == true {
                guard let generator = self.appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex(), let schemes = generator.getSchemes() else {
                    return
                }
                let colorCount = self.values![Int(self.colorSchemeSizeSlider.value)]
                let scheme = schemes[activedSchemeIndex]
                generator.updateScheme(colorCount: colorCount, frame: scheme.frame, index: activedSchemeIndex)
            }
        }
    }
}
