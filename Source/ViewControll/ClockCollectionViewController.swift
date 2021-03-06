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
import SwiftDate
class ClockCollectionViewController: UICollectionViewController {
    let disposeBag = DisposeBag()
    
    var close = Variable(ClockModel.close)
    dynamic var clockArray: [ClockModel] = []
    
    lazy var navigationAccessoryView : NavigationAccessoryView = {
        [unowned self] in
        let naview = NavigationAccessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 44.0))
        naview.doneButton.target = self
        naview.doneButton.action = #selector(navigationDone(_:))
        return naview
        }()
    func navigationDone(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        ClockModel.setObjectArray(clockArray, forKey: "clockArray")
    }
    //MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = Colors.background
        self.collectionView?.registerNib(R.nib.clockCollectionViewCell)
        self.collectionView?.registerNib(R.nib.clockCollectionHeaderView, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        clockArray = ClockModel.getClocks()
        let flowLayout  = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 204)
        let width = SCREEN_WIDTH/3
        var height = (self.view.ks_height - 108 - 204)/3
        if height < 80 {
            height = 80
        }else{
            self.collectionView?.scrollEnabled = false
        }
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.nib.clockCollectionViewCell, forIndexPath: indexPath)!
        let clockModel = clockArray[indexPath.row]
        cell.timeTextField.text = clockModel.description
        cell.openSwitch.on = clockModel.open
        cell.openSwitch.rx_value.skip(1).subscribeNext { [unowned self] (on) in
            if on {
                clockModel.addUILocalNotification()
            } else {
                clockModel.removeUILocalNotification()
            }
            clockModel.open = on
            ClockModel.setObjectArray(self.clockArray, forKey: "clockArray")
        }.addDisposableTo(cell.disposeBag)
        cell.timeTextField.inputAccessoryView = navigationAccessoryView
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .Time
        cell.timeTextField.inputView = datePicker
        datePicker.rx_controlEvent(.ValueChanged).subscribeNext{ [unowned cell,unowned datePicker] in
            let on = cell.openSwitch.on
            if on {
                clockModel.removeUILocalNotification()
            }
            let components = datePicker.date.components(inRegion: Region())
            clockModel.hour = components.hour
            clockModel.minute = components.minute
            if on {
                clockModel.addUILocalNotification()
            }
            cell.timeTextField.text = clockModel.description
        }.addDisposableTo(cell.disposeBag)
        let components = NSDate().components
        components.timeZone = NSTimeZone.localTimeZone()
        components.hour = clockModel.hour
        components.minute = clockModel.minute
        datePicker.date = components.date!
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: R.nib.clockCollectionHeaderView, forIndexPath: indexPath)!
        let view = UIView(frame: CGRectMake(0,header.ks_height ,self.view.ks_width,self.view.ks_height))
        view.alpha = 0.5
        view.backgroundColor = UIColor.blackColor()
        self.close.asObservable().subscribeNext{ [unowned self]  in
            if $0 {
                view.ks_top = (header.ks_height - collectionView.contentOffset.y)
                self.view.addSubview(view)
                header.headerImageView.image = R.image.clock_close()
            }else{
                view.removeFromSuperview()
                header.headerImageView.image = R.image.clock_open()
            }
            }.addDisposableTo(disposeBag)
        let tapGestureRecognizer = UITapGestureRecognizer()
        header.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx_event.subscribeNext{ [unowned self] _ in
          self.view.endEditing(true)
            self.close.value = !self.close.value
            ClockModel.close = self.close.value
            if  self.close.value {
                self.noticeOnlyText("闹钟功能已禁用")
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }else{
                self.noticeOnlyText("闹钟功能已开启")
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


