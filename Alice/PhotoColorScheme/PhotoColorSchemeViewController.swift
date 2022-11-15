//
//  SubjectViewController.swift
//  Alice
//
//  Created by Yu Qing Cai on 2022/11/7.
//

import UIKit

class PhotoColorSchemeViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.photoColorSehemeGenerator.schemes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let cellView:PhotoColorSchemeCellView = tableView.dequeueReusableCell(withIdentifier: "IDPhotoColorSchemeCellView", for: indexPath) as! PhotoColorSchemeCellView
        
        cellView.colorSchemeView.scheme = appDelegate.photoColorSehemeGenerator.schemes?[indexPath.row]
        cellView.colorSchemeView.setNeedsDisplay()
        
        cellView.selectionStyle = .none
        
        return cellView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var addRegionButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var schemeTableView: UITableView!
    var imageView: UIImageView!
    var regionView: PickerRegionView!
    var panGesture: UIPanGestureRecognizer?
    var pinchGesture: UIPinchGestureRecognizer?
    var tapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        overrideUserInterfaceStyle = .dark
        indicator.hidesWhenStopped = true
        scrollView.delegate = self
        schemeTableView.separatorStyle = .none
        
        let x = (contentView.frame.size.width - indicator.frame.size.width) / 2.0
        let y = (contentView.frame.size.height - indicator.frame.size.height)/2.0
        indicator.frame.origin = CGPoint(x: x, y: y)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func draggedView(_ sender:UIPanGestureRecognizer) {
        let translation = sender.translation(in: imageView)
        regionView.center = CGPoint(x: regionView.center.x + translation.x, y: regionView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: imageView)
        
        //print(String(format: "%.2f %.2f %.2f %.2f", regionView.frame.origin.x, regionView.frame.origin.y, regionView.frame.size.width, regionView.frame.size.height))
        
        if (sender.state == .ended) {
            
            indicator.startAnimating()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let frame = self.regionView.frame
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                let generator = appDelegate.photoColorSehemeGenerator
                let scheme = generator.generate(UInt32(Int.random(in: 5...16)), frame)
                //generator.replaceScheme(at: 0, to: scheme)
                generator.appendScheme(scheme)
                
                DispatchQueue.main.async {
                    // Run UI Updates
                    guard let count = generator.schemes?.count else {
                        return
                    }
                    self.schemeTableView.beginUpdates()
                    self.schemeTableView.insertRows(at: [IndexPath(row: count - 1, section: 0)], with: .bottom)
                    self.schemeTableView.endUpdates()
                    self.indicator.stopAnimating();
                                        
                    guard let count = generator.schemes?.count else {
                        return
                    }
                    let indexPath = IndexPath(row: count - 1, section: 0)
                    self.schemeTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
            
        }
    }
    
    @IBAction func pinchedView(_ sender:UIPinchGestureRecognizer) {
        if let scale = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)) {
            guard scale.a > 1.0 else {
                return
            }
            guard scale.d > 1.0 else {
                return
            }
            sender.view?.transform = scale
            sender.scale = 1.0
         }
    }
    
    @IBAction func tapView(_ sender:UIPinchGestureRecognizer) {
        sender.view
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
            
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        indicator.startAnimating()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            guard let image = appDelegate.photoColorSehemeGenerator.source else {
                return
            }
            
            let generator = appDelegate.photoColorSehemeGenerator
            let scheme = generator.generate(5, CGRect(x:0.0, y:0.0, width:image.size.width, height:image.size.height))
            generator.appendScheme(scheme)
            
//            scheme = generator.generate(4, CGRect(x:0.0, y:0.0, width:image.size.width, height:image.size.height))
//            generator.replaceScheme(at: 0, to: scheme)
            
            DispatchQueue.main.async {
                // Run UI Updates
                let image = appDelegate.photoColorSehemeGenerator.source
                self.schemeTableView.reloadData()
                self.indicator.stopAnimating();
                self.imageView = UIImageView(image: image)

                self.regionView = PickerRegionView(frame: CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: 200, height: 200)))
                self.regionView.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
                self.regionView.isUserInteractionEnabled = true
                self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView))
                self.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchedView))
                self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
                
                if let panGesture = self.panGesture {
                    self.regionView.addGestureRecognizer(panGesture)
                }
                
                if let pinchGesture = self.pinchGesture {
                    self.regionView.addGestureRecognizer(pinchGesture)
                }
                
                if let tapGesture = self.tapGesture {
                    self.regionView.addGestureRecognizer(tapGesture)
                }
                                
                self.imageView.addSubview(self.regionView)
                self.imageView.isUserInteractionEnabled = true
                self.scrollView.addSubview(self.imageView)
                
                var minimumZoomScale = 1.0
                
                if (image!.size.width >= image!.size.height) {
                    minimumZoomScale = self.scrollView.frame.size.height / image!.size.height
                }
                else if (image!.size.width < image!.size.height) {
                    minimumZoomScale = self.scrollView.frame.size.width / image!.size.width
                }
                
                if (image!.size.width >= self.scrollView.frame.size.width ||
                    image!.size.height >= self.scrollView.frame.size.height) {
                    self.scrollView.minimumZoomScale = minimumZoomScale
                    self.scrollView.maximumZoomScale = 1
                }
                else if (image!.size.width < self.scrollView.frame.size.width ||
                      image!.size.height < self.scrollView.frame.size.height) {
                    self.scrollView.minimumZoomScale = minimumZoomScale
                    self.scrollView.maximumZoomScale = minimumZoomScale
                }
                
                self.scrollView.zoomScale = minimumZoomScale
                
            }
        }
    }
    
    @IBAction func addRegion(_ sender: Any) {
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        //print(String(format: "end zooming scale: %.2f, regionWidth:%.2f regionHeight:%.2f", scale, regionView0.frame.size.width, regionView0.frame.size.height))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print("end dragging");
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //print(String(format: "will begin dragging offsetX: %.2f, offsetY: %.2f", scrollView.contentOffset.x, scrollView.contentOffset.y))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(String(format: "did scroll offsetX: %.2f, offsetY: %.2f", scrollView.contentOffset.x, scrollView.contentOffset.y))
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
}
