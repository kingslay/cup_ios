//
//  AccountViewController.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import AVFoundation
import KSJSONHelp
import KSSwiftExtension
import SwiftDate
class AccountViewController: UITableViewController {
    var datas :[[(String,String,String?)]]!
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        self.tableView.registerNib(R.nib.accountTableViewCell)
        self.view.backgroundColor = UIColor.lightGrayColor()
        self.tableView.tableFooterView = UIView()
    }
    func initData(){
        datas = [[("我的头像","未添加",staticAccount?.headImageURL),
            ("我的昵称","未添加",staticAccount?.nickname)],
            [("生日","生日是什么时候",staticAccount?.brithday),
                ("身高","身高是多少呢",staticAccount?.height != nil ? "\(staticAccount!.height!)CM" : nil),
                ("城市","请选择城市",staticAccount?.city)]]
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AccountModel.sharedAccount = staticAccount
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func reloadData(){
        initData()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return datas.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.accountTableViewCell.reuseIdentifier, forIndexPath: indexPath)!
        cell.valueTextField.hidden = false
        cell.headerImageView.hidden = true
        cell.selectionStyle = .None
        let (title,placeholder,value) = datas[indexPath.section][indexPath.row]
        cell.titleLabel.text = title
        if let value = value {
            cell.valueTextField.text = value
        }else{
            cell.valueTextField.placeholder = placeholder
        }
        cell.valueTextField.userInteractionEnabled = false
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            if let value = value {
                cell.valueTextField.hidden = true
                cell.headerImageView.hidden = false
//                cell.headerImageView.image
            }
            break
        case (1,0):
            cell.valueTextField.userInteractionEnabled = true
            let pickerView = KSDatePickerView()
            pickerView.datePicker.datePickerMode = .Date
            pickerView.datePicker.maximumDate = NSDate()
            cell.valueTextField.inputView = pickerView
            pickerView.callBackBlock = { [unowned self] in
                staticAccount?.brithday = $0.toString(format: .Custom("yyyy年MM月dd日"))
                self.view.endEditing(true)
                cell.valueTextField.text = staticAccount?.brithday
            }
            break
        case (1,1):
            cell.valueTextField.userInteractionEnabled = true
            let pickerView = KSPickerView.init(frame: CGRectMake(0, 0, SCREEN_WIDTH, 200))
            pickerView.pickerData = [Array(60...250).map{"\($0)"},Array(0...9).map{".\($0)CM"}]
            cell.valueTextField.inputView = pickerView
            pickerView.callBackBlock = { [unowned self] in
                staticAccount?.height = Double($0[0]+60) + Double($0[1])/10
                self.view.endEditing(true)
                cell.valueTextField.text = "\(staticAccount!.height!)CM"
            }
            break
        default:
            break
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AccountTableViewCell
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
            let albumAction = UIAlertAction(title: "从相册选择", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .SavedPhotosAlbum
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }
            let pictureAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                    imagePickerController.sourceType = .Camera
                    switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
                    case .NotDetermined:
                        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
                        break
                    case .Denied:
                        self.noticeInfo("请在iPhone的“设置-隐私-相机”选项中，允许访问你的相机",autoClear: true)
                        break
                    default:
                        break
                    }
                }else{
                    self.noticeInfo("您的设备没有摄像头!", autoClear: true)
                    imagePickerController.sourceType = .PhotoLibrary
                }
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(albumAction)
            alertController.addAction(pictureAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            break
        case (0,1):
            let alertController = UIAlertController.init(title: nil, message: "请输入昵称", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler(nil)
            let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                staticAccount?.nickname = alertController.textFields?.first?.text
                cell.valueTextField.text = staticAccount?.nickname
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            break
        case (1,2):
            let cityVC = CFCityPickerVC()
            //设置热门城市
            cityVC.hotCities = ["北京","上海","广州","成都","杭州","重庆"]
            let navVC = UINavigationController(rootViewController: cityVC)
            navVC.navigationBar.barStyle = UIBarStyle.BlackTranslucent
            self.presentViewController(navVC, animated: true, completion: nil)
            let plistUrl = NSBundle.mainBundle().URLForResource("City", withExtension: "plist")!
            let cityArray = NSArray(contentsOfURL: plistUrl) as! [NSDictionary]
            //解析字典数据
            cityVC.cityModels = CityModel.toModels(cityArray) as! [CityModel]
            //选中了城市
            cityVC.selectedCityModel = { (cityModel: CityModel) in
                staticAccount?.city = cityModel.name
                cell.valueTextField.text = staticAccount?.city
            }
            break
        default:
            break
        }
        
    }
}
extension AccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = image.normalizedImage()
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0)) as! AccountTableViewCell
            cell.valueTextField.hidden = true
            cell.headerImageView.image = image
        }
    }
}
