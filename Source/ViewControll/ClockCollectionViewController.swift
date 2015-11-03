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
        self.view.backgroundColor = UIColor.whiteColor()
        self.collectionView?.registerNib(R.nib.clockCollectionViewCell)
        let rightButton = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: "addClock")
        self.navigationItem.rightBarButtonItem = rightButton
        // Do any additional setup after loading the view.
        if let array = ClockModel.objectArrayForKey("clockArray")  {
            clockArray = array as! [ClockModel]
        }
        
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
        let pickerView = KSPickerView.init(frame: CGRectMake(0, SCREEN_HEIGHT-250,SCREEN_WIDTH, 250))
        pickerView.pickerData = [Array(0..<24).map{ String(format: "%02d", $0)},Array(0..<60).map{String(format:"%02d", $0)}]
        self.view.addSubview(pickerView)
        pickerView.callBackBlock = {[unowned self] in
            self.clockArray.append(ClockModel.init(hour: $0[0], minute: $0[1]))
            ClockModel.setObjectArray(self.clockArray,forKey:"clockArray")
            self.collectionView?.reloadData()
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
}

extension ClockCollectionViewController {
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}


