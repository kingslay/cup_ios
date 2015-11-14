//
//  NavigationAccessoryView.swift
//  Cup
//
//  Created by king on 15/11/13.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

public class NavigationAccessoryView: UIToolbar {

    public var previousButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 105)!, target: nil, action: nil)
    public var nextButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 106)!, target: nil, action: nil)
    public var doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
    private var fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
    private var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    
    public override init(frame: CGRect) {
        super.init(frame: CGRectMake(0, 0, frame.size.width, 44.0))
        autoresizingMask = .FlexibleWidth
        fixedSpace.width = 22.0
        setItems([fixedSpace, flexibleSpace, doneButton], animated: false)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {}

}