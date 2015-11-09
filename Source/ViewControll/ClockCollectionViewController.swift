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

class ClockCollectionViewController: UICollectionViewController {

    var clockArray: [ClockModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.lightGrayColor()
        self.collectionView?.registerNib(R.nib.clockCollectionViewCell)
        let rightButton = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: "addClock")
        self.navigationItem.rightBarButtonItem = rightButton;
        if let array = ClockModel.objectArrayForKey("clockArray")  {
            clockArray = array as! [ClockModel]
        }
        
        self.collectionView?.addMoveGestureRecognizerForLongPress()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func addClock() {
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings.init(forTypes: [.Badge,.Sound,.Alert], categories: nil))
        let pickerView = KSDatePickerView()
        pickerView.datePicker.datePickerMode = .CountDownTimer
        self.view.addSubview(pickerView)
        pickerView.ks_bottom = self.view.ks_bottom
        pickerView.callBackBlock = {
            pickerView.hidden = true
            let model = ClockModel.init(hour: $0.hour, minute: $0.minute)
            self.clockArray.append(model)
            ClockModel.setObjectArray(self.clockArray,forKey:"clockArray")
            self.collectionView?.reloadData()
            model.addUILocalNotification()
        }
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.nib.clockCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
        let clockModel = self.clockArray[indexPath.row]
        cell?.timeLabel.text = clockModel.description
        cell?.openSwitch.on = clockModel.open
        return cell!
    }
//    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        if kind == UICollectionElementKindSectionHeader {
//            
//
//        }
//        return nil
//    }
}

extension ClockCollectionViewController:KSArrangeCollectionViewDelegate {
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void
    {
        let model = self.clockArray.removeAtIndex(fromIndexPath.row)
        self.clockArray.insert(model, atIndex: toIndexPath.row)
    }
    func deleteItemAtIndexPath(indexPath : NSIndexPath) -> Void
    {
        let model = clockArray[indexPath.row]
        self.clockArray.removeAtIndex(indexPath.row)
        ClockModel.setObjectArray(self.clockArray,forKey:"clockArray")
        model.removeUILocalNotification()
    }
}


