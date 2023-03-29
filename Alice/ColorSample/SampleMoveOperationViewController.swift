//
//  SampleMoveOperationViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/19.
//

import UIKit

class SampleMoveOperationViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var horizonalSlider: UISlider!
    @IBOutlet weak var verticalSlider: UISlider!
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var horizontalLabel: UILabel!
    @IBOutlet weak var verticalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        baseView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        baseView.layer.cornerRadius = 25
        baseView.layer.masksToBounds = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapView)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let generator = appDelegate.colorSchemeGenerator, let photo = generator.getPhoto(), let activedSchemeIndex = generator.getActivedSchemeIndex(), let schemes = generator.getSchemes() else {
            return
        }
                
        let scheme = schemes[activedSchemeIndex]
        let photoWidth = photo.size.width
        let photoHeight = photo.size.height
        let sampleWidth = scheme.frame.size.width
        let sampleHeight = scheme.frame.size.height
        
        horizonalSlider.minimumValue = 0.0
        horizonalSlider.maximumValue = Float(photoWidth - sampleWidth)
        horizonalSlider.value = Float(scheme.frame.origin.x)
        
        verticalSlider.minimumValue = 0.0
        verticalSlider.maximumValue = Float(photoHeight - sampleHeight)
        verticalSlider.value = Float(scheme.frame.origin.y)
        
        titleLabel.text = NSLocalizedString("Movement-Label", comment: "")
        horizontalLabel.text = NSLocalizedString("Horizontal-Label", comment: "")
        verticalLabel.text = NSLocalizedString("Vertical-Label", comment: "")
    }
        
    @IBAction func tapView(_ sender:UIPinchGestureRecognizer) {
        close(sender)
    }
    
    @IBAction func horizonalChanged(_ sender: Any) {
        guard let generator = appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex(), let schemes = generator.getSchemes(), let slider = sender as? UISlider else {
            return
        }
        
        let scheme = schemes[activedSchemeIndex]
        var frame = scheme.frame
        frame.origin.x = CGFloat(slider.value)
        generator.setScheme(frame: frame, index: activedSchemeIndex)
    }
    
    @IBAction func verticalChanged(_ sender: Any) {
        guard let generator = appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex(), let schemes = generator.getSchemes(), let slider = sender as? UISlider else {
            return
        }
        
        let scheme = schemes[activedSchemeIndex]
        var frame = scheme.frame
        frame.origin.y = CGFloat(slider.value)
        generator.setScheme(frame: frame, index: activedSchemeIndex)
    }
        
    func close(_ sender: Any) {
        
        dismiss(animated: true) {
            guard let generator = self.appDelegate.colorSchemeGenerator, let activedSchemeIndex = generator.getActivedSchemeIndex(), let schemes = generator.getSchemes() else {
                return
            }
            
            DispatchQueue.global(qos: .userInteractive).async {
                let scheme = schemes[activedSchemeIndex]
                generator.updateScheme(colorCount: scheme.items.count, frame: scheme.frame, index: activedSchemeIndex)
            }
        }
        
    }

}
