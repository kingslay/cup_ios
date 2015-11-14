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
import RxCocoa
class ClockCollectionViewController: UICollectionViewController {
    
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
        self.collectionView?.backgroundColor = Colors.tableBackground
        self.collectionView?.registerNib(R.nib.clockCollectionViewCell)
        self.collectionView?.registerNib(R.nib.clockCollectionHeaderView, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addClock")
//        self.navigationItem.rightBarButtonItem = rightButton;
        clockArray = ClockModel.getClocks()
        //        self.collectionView?.addMoveGestureRecognizerForLongPress()
        let flowLayout  = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 100)
        let width = self.view.ks_width/3
        flowLayout.itemSize = CGSizeMake(width-10,width-10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addClock() {
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings.init(forTypes: [.Badge,.Sound,.Alert], categories: nil))
        //        let pickerView = KSDatePickerView()
        //        pickerView.datePicker.datePickerMode = .CountDownTimer
        //        self.view.addSubview(pickerView)
        //        pickerView.ks_bottom = self.view.ks_bottom
        //        pickerView.callBackBlock = {
        //            pickerView.hidden = true
        //            let model = ClockModel.init(hour: $0.hour, minute: $0.minute)
        //            self.clockArray.append(model)
        //            ClockModel.addClock(model)
        //            self.collectionView?.reloadData()
        //        }
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
        }
        let datePicker = UIDatePicker()
        cell.timeTextField.inputAccessoryView = navigationAccessoryView
        cell.timeTextField.inputView = datePicker
        datePicker.datePickerMode = .CountDownTimer
        datePicker.rx_controlEvents(.ValueChanged).subscribeNext{ [unowned self,unowned cell,unowned datePicker] in
            clockModel.hour = datePicker.date.hour
            clockModel.minute = datePicker.date.minute
            cell.timeTextField.text = clockModel.description
            ClockModel.setObjectArray(self.clockArray, forKey: "clockArray")
        }
        datePicker.date = NSDate()
        return cell
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: R.nib.clockCollectionHeaderView.reuseIdentifier, forIndexPath: indexPath)
        //        header.addGestureRecognizer()
        return header!
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


