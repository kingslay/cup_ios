//
//  KSGuidanceViewController.swift
//  iOSAppTemplate
//
//  Created by king on 15/10/1.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

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
        
        scrollView.contentSize = CGSizeMake(frame.size.width * CGFloat(numOfPages), frame.size.height)
        
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        
        for i in 0..<numOfPages {
            let imageView = UIImageView(image: UIImage(named: "Guidance\(i + 1)"))
            
            imageView.frame = CGRectMake(frame.size.width * CGFloat(i), 0, frame.size.width, frame.size.height)
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentOffset = CGPointZero
        
        self.view.addSubview(scrollView)
        
        startButton.alpha = 0.0
        
        // 将这两个控件拿到视图的最上面
        self.view.bringSubviewToFront(pageControl)
        self.view.bringSubviewToFront(startButton)
        self.startButton.rx_tap.subscribeNext{
            let vc = R.storyboard.sMS.initialViewController
            UIApplication.sharedApplication().keyWindow?.rootViewController = vc
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UIScrollViewDelegate
extension KSGuidanceViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        // 随着滑动改变pageControl的状态
        pageControl.currentPage = Int(offset.x / view.bounds.width)
        // 因为currentPage是从0开始，所以numOfPages减1
        if pageControl.currentPage == numOfPages - 1 {
            
            UIView.animateWithDuration(0.5) {
                self.startButton.alpha = 1.0
            }
            
        } else {
            
            UIView.animateWithDuration(0.5) {
                self.startButton.alpha = 0.0
            }
        }
    }
}