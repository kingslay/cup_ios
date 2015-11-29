//
//  ClockCollectionViewController.swift
//  Cup
//
//  Created by kingslay on 15/11/2.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSSwiftExtension
import KSJSONHelp
import RxSwift
import RxCocoa

class ClockCollectionViewController: UICollectionViewController {
    let disposeBag = DisposeBag()
    
    var close = Variable(ClockModel.close)
    var clockArray: [ClockModel] = []
    
    lazy var navigationAccessoryView : NavigationAccessoryView = {
        [unowned self] in
        let naview = NavigationAccessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 44.0))
        naview.doneButton.target = self
        naview.doneButton.action = "navigationDone:"
        return naview
        }()
    func navigationDone(sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    //MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = Colors.background
        self.collectionView?.scrollEnabled = false
        self.collectionView?.registerNib(R.nib.clockCollectionViewCell)
        self.collectionView?.registerNib(R.nib.clockCollectionHeaderView, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addClock")
        //        self.navigationItem.rightBarButtonItem = rightButton;
        clockArray = ClockModel.getClocks()
        let flowLayout  = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 204)
        let width = SCREEN_WIDTH/3
        let height = (self.view.ks_height - 108 - 204)/3
        flowLayout.itemSize = CGSizeMake(width,height)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge,.Sound,.Alert], categories: nil))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
// MARK: UICollectionViewDataSource
extension ClockCollectionViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.clockArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.nib.clockCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)!
        let clockModel = self.clockArray[indexPath.row]
        cell.timeTextField.text = clockModel.description
        cell.openSwitch.on = clockModel.open
        cell.openSwitch.rx_controlEvents(.TouchUpInside).subscribeNext{ [unowned cell,unowned self] in
            let on = cell.openSwitch.on
            if on {
                clockModel.addUILocalNotification()
            } else {
                clockModel.removeUILocalNotification()
            }
            clockModel.open = true
            ClockModel.setObjectArray(self.clockArray, forKey: "clockArray")
        }
        cell.timeTextField.inputAccessoryView = navigationAccessoryView
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .Time
        cell.timeTextField.inputView = datePicker
        datePicker.rx_controlEvents(.ValueChanged).subscribeNext{ [unowned self,unowned cell,unowned datePicker] in
            let on = cell.openSwitch.on
            if on {
                clockModel.removeUILocalNotification()
            }
            clockModel.hour = datePicker.date.hour
            clockModel.minute = datePicker.date.minute
            if on {
                clockModel.addUILocalNotification()
            }
            cell.timeTextField.text = clockModel.description
            ClockModel.setObjectArray(self.clockArray, forKey: "clockArray")
        }
        datePicker.date = NSDate()
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: R.nib.clockCollectionHeaderView.reuseIdentifier, forIndexPath: indexPath)!
        let view = UIView(frame: CGRectMake(0,204,self.view.ks_width,self.view.ks_height))
        view.alpha = 0.5
        view.backgroundColor = UIColor.blackColor()
        self.close.subscribeNext{ [unowned self]  in
            if $0 {
                self.view.addSubview(view)
                header.headerImageView.image = R.image.clock_close
            }else{
                view.removeFromSuperview()
                header.headerImageView.image = R.image.clock_open
            }
            }.addDisposableTo(disposeBag)
        let tapGestureRecognizer = UITapGestureRecognizer()
        header.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx_event.subscribeNext{ [unowned self] _ in
          self.view.endEditing(true)
            self.close.value = !self.close.value
            ClockModel.close = self.close.value
            if  self.close.value {
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }
            self.clockArray.forEach{
                if $0.open && !self.close.value {
                    $0.addUILocalNotification()
                }
            }
            }.addDisposableTo(disposeBag)
        return header
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
}

//extension ClockCollectionViewController:KSArrangeCollectionViewDelegate {
//    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void
//    {
//        let model = self.clockArray.removeAtIndex(fromIndexPath.row)
//        self.clockArray.insert(model, atIndex: toIndexPath.row)
//    }
//    func deleteItemAtIndexPath(indexPath : NSIndexPath) -> Void
//    {
//        let model = clockArray[indexPath.row]
//        self.clockArray.removeAtIndex(indexPath.row)
//        ClockModel.setObjectArray(self.clockArray,forKey:"clockArray")
//        model.removeUILocalNotification()
//    }
//}


