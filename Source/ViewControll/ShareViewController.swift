//
//  ShareViewController.swift
//  Cup
//
//  Created by king on 16/8/13.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.logo(), style: .Plain, target: self, action: #selector(showShareSheet(_:)))
    }

    func showShareSheet(view: UIView) {
        let sheet = R.nib.shareSheet.firstView(owner: nil)
        sheet?.showIn(self.view)
    }
}
