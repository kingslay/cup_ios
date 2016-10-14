//
//  NavigationAccessoryView.swift
//  Cup
//
//  Created by king on 15/11/13.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

open class NavigationAccessoryView: UIToolbar {

    open var previousButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 105)!, target: nil, action: nil)
    open var nextButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 106)!, target: nil, action: nil)
    open var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    fileprivate var fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    fileprivate var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44.0))
        autoresizingMask = .flexibleWidth
        fixedSpace.width = 22.0
        doneButton.tintColor = Colors.red
        setItems([fixedSpace, flexibleSpace, doneButton], animated: false)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}

}
