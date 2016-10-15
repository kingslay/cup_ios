//
//  KSGuidanceViewController.swift
//  iOSAppTemplate
//
//  Created by king on 15/10/1.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import Gifu

class KSGuidanceViewController: UIViewController {
    
    var scrollView:  UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startButton: UIButton!
    //引导图个数
    var numOfPages = 4
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = self.view.bounds
        
        scrollView = UIScrollView()
        scrollView.frame = self.view.bounds
        scrollView.delegate = self
        
        scrollView.contentSize = CGSize(width: frame.size.width * CGFloat(numOfPages), height: frame.size.height)
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        var count = 1
        if frame.size.height > 480 {
            count = 5
        }
        for i in 0..<numOfPages {
            let imageView = GIFImageView(frame: CGRect(x: frame.size.width * CGFloat(i), y: 0, width: frame.size.width, height: frame.size.height))
            imageView.animate(withGIFNamed: "\(i + count).gif")
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentOffset = CGPoint.zero
        
        self.view.addSubview(scrollView)
        
        startButton.alpha = 0.0
        
        // 将这两个控件拿到视图的最上面
        self.view.bringSubview(toFront: pageControl)
        self.view.bringSubview(toFront: startButton)
        self.startButton.rx.tap.subscribeNext{
            UIApplication.shared.keyWindow?.rootViewController =  R.storyboard.sMS.instantiateInitialViewController()
        }.addDisposableTo(self.ks.disposableBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UIScrollViewDelegate
extension KSGuidanceViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        // 随着滑动改变pageControl的状态
        pageControl.currentPage = Int(offset.x / view.bounds.width)
        // 因为currentPage是从0开始，所以numOfPages减1
        if pageControl.currentPage == numOfPages - 1 {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.startButton.alpha = 1.0
            }) 
            
        } else {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.startButton.alpha = 0.0
            }) 
        }
    }
}
