//
//  SampleScaleOperationViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/19.
//

import UIKit

class SampleScaleOperationViewController: UIViewController {
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
        
        let proportionalHorizonal = Float(sampleWidth / photoWidth)
        let proportionalVertical = Float(sampleHeight / photoHeight)
        
        horizonalSlider.minimumValue = 0.1
        horizonalSlider.maximumValue = 1.0
        horizonalSlider.value = proportionalHorizonal
        
        verticalSlider.minimumValue = 0.1
        verticalSlider.maximumValue = 1.0
        verticalSlider.value = proportionalVertical
        
        titleLabel.text = NSLocalizedString("Scale-Label", comment: "")
        horizontalLabel.text = NSLocalizedString("Horizontal-Label", comment: "")
        verticalLabel.text = NSLocalizedString("Vertical-Label", comment: "")
        
    }
    
    @IBAction func tapView(_ sender:UIPinchGestureRecognizer) {
        close(sender)
    }
        
    @IBAction func horizonalChanged(_ sender: Any) {
        guard let generator = appDelegate.colorSchemeGenerator, let photo = generator.getPhoto(), let activedSchemeIndex = generator.getActivedSchemeIndex(), let schemes = generator.getSchemes(), let slider = sender as? UISlider else {
            return
        }
                
        let scheme = schemes[activedSchemeIndex]
        let photoWidth = photo.size.width
        let sampleWidth = photoWidth * CGFloat(slider.value)
        
        var frame = scheme.frame
        frame.size.width = sampleWidth
        
        if frame.origin.x + frame.size.width > photoWidth {
            frame.origin.x -= frame.origin.x + frame.size.width - photoWidth
        }
        
        generator.setScheme(frame: frame, index: activedSchemeIndex)
    }
    
    @IBAction func verticalChanged(_ sender: Any) {
        guard let generator = appDelegate.colorSchemeGenerator, let photo = generator.getPhoto(), let activedSchemeIndex = generator.getActivedSchemeIndex(), let schemes = generator.getSchemes(), let slider = sender as? UISlider else {
            return
        }
        
        let scheme = schemes[activedSchemeIndex]
        let photoHeight = photo.size.height
        let sampleHeight = photoHeight * CGFloat(slider.value)
        
        var frame = scheme.frame
        frame.size.height = sampleHeight
        
        if frame.origin.y + frame.size.height > photoHeight {
            frame.origin.y -= frame.origin.y + frame.size.height - photoHeight
        }
        
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
