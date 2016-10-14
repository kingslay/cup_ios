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
        let naview = NavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44.0))
        naview.doneButton.target = self
        naview.doneButton.action = #selector(navigationDone)
        return naview
        }()
    func navigationDone() {
        self.view.endEditing(true)
        ClockModel.saveValuesToDefaults(clockArray, forKey: "clockArray")
    }
    //MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = Colors.background
        self.collectionView?.register(R.nib.clockCollectionViewCell)
        self.collectionView?.register(R.nib.clockCollectionHeaderView, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        clockArray = ClockModel.getClocks()
        let flowLayout  = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.headerReferenceSize = CGSize(width: KS.SCREEN_WIDTH, height: 204)
        let width = KS.SCREEN_WIDTH/3
        var height = (self.view.ks.height - 108 - 204)/3
        if height < 80 {
            height = 80
        }else{
            self.collectionView?.isScrollEnabled = false
        }
        flowLayout.itemSize = CGSize(width: width,height: height)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge,.sound,.alert], categories: nil))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
// MARK: UICollectionViewDataSource
extension ClockCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.clockArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.clockCollectionViewCell, for: indexPath)!
        let clockModel = clockArray[(indexPath as NSIndexPath).row]
        cell.timeTextField.text = clockModel.description
        cell.openSwitch.isOn = clockModel.open
        cell.openSwitch.rx.value.skip(1).subscribeNext { [unowned self] (on) in
            if on {
                clockModel.addUILocalNotification()
            } else {
                clockModel.removeUILocalNotification()
            }
            clockModel.open = on
            ClockModel.saveValuesToDefaults(self.clockArray, forKey: "clockArray")
        }.addDisposableTo(cell.disposeBag)
        cell.timeTextField.inputAccessoryView = navigationAccessoryView
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        cell.timeTextField.inputView = datePicker
        datePicker.rx.controlEvent(.valueChanged).subscribeNext{ [unowned cell,unowned datePicker] in
            let on = cell.openSwitch.isOn
            if on {
                clockModel.removeUILocalNotification()
            }
            clockModel.hour = datePicker.date.ks.dateComponents.hour!
            clockModel.minute = datePicker.date.ks.dateComponents.minute!
            if on {
                clockModel.addUILocalNotification()
            }
            cell.timeTextField.text = clockModel.description
        }.addDisposableTo(cell.ks.prepareForReusedisposableBag)
        datePicker.date = clockModel.date
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.nib.clockCollectionHeaderView, for: indexPath)!
        let view = UIView(frame: CGRect(x: 0,y: header.ks.height ,width: self.view.ks.width,height: self.view.ks.height))
        view.alpha = 0.5
        view.backgroundColor = UIColor.black
        self.close.asObservable().subscribeNext{ [unowned self]  in
            if $0 {
                view.ks.top(header.ks.height - collectionView.contentOffset.y)
                self.view.addSubview(view)
            }else{
                view.removeFromSuperview()
            }
            }.addDisposableTo(disposeBag)
        let tapGestureRecognizer = UITapGestureRecognizer()
        header.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event.subscribeNext{ [unowned self] _ in
          self.view.endEditing(true)
            self.close.value = !self.close.value
            ClockModel.close = self.close.value
            if  self.close.value {
                self.ks.noticeOnlyText("闹钟功能已禁用")
                UIApplication.shared.cancelAllLocalNotifications()
            }else{
                self.ks.noticeOnlyText("闹钟功能已开启")
            }
            self.clockArray.forEach{
                if $0.open && !self.close.value {
                    $0.addUILocalNotification()
                }
            }
            }.addDisposableTo(disposeBag)
        return header
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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


