//
//  UINavigationController.swift
//  Cup
//
//  Created by kingslay on 15/11/5.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
extension UINavigationController {
    public func ks_pushViewController(viewController: UIViewController,animated: Bool = true,hideBottomBar: Bool = true) {
        viewController.hidesBottomBarWhenPushed = hideBottomBar
        pushViewController(viewController, animated: animated)
    }
}