//
//  PhotoViewController.swift
//  Cacher
//
//  Created by Prajwal Lobo on 20/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIScrollViewDelegate {

    //MARK:- IBOutlet
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Property
    var pin : Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScrollView()
    }
    
    //MARK:-
    func setupScrollView(){
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
    }
    //MARK:-
    func setupUI(){
        if let userPin = pin{
            if let urlString = userPin.link{
                activityIndicator.startAnimating()
                previewImageView.setImage(with: URL(string : urlString), completionHandler: {[weak self] (object, error, cacheType, url) in
                    guard let ref = self else {return}
                    ref.activityIndicator.stopAnimating()
                })
                
                let transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
                scrollView.contentSize = previewImageView.frame.size
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.view.transform = transform
                }, completion: nil)
            }
        }
    }
    
    //MARK:-
    //The view that should get zoomed
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return previewImageView
    }
    
    //MARK:-
    @IBAction func doubleTapGestureRecognizerAction(_ sender: Any) {
        if scrollView.zoomScale == 1{
            scrollView.zoom(to: zoomRectFor(scale: self.scrollView.maximumZoomScale, center: (sender as AnyObject).location(in: (sender as AnyObject).view)), animated: true)
        } else {
           scrollView.setZoomScale(1, animated: true)
        }
    }
    
    //Preview view scrollview's zoom calculation
    func zoomRectFor(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = previewImageView.frame.size.height / scale
        zoomRect.size.width  = previewImageView.frame.size.width  / scale
        let newCenter = previewImageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.transform = CGAffineTransform.identity
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
