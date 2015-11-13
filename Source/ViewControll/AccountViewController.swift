//
//  AccountViewController.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import AVFoundation
import KSSwiftExtension
import AlamofireImage

class AccountViewController: UITableViewController {
    var datas :[[(String,String,String?)]]!
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        self.tableView.registerNib(R.nib.accountTableViewCell)
        self.tableView.backgroundColor = Colors.tableBackground
        self.tableView.tableFooterView = UIView()
    }
    func initData(){
        datas = [[("我的头像","未添加",staticAccount?.avatar),
            ("我的昵称","未添加",staticAccount?.nickname),
            ("性别","男",staticAccount?.sex),
            ("帐号安全","",staticAccount?.phone)],
            [("场境","",staticAccount?.scene),
                ("体质","",staticAccount?.constitution),
                ("身高","身高是多少呢",staticAccount?.height != nil ? "\(staticAccount!.height!)cm" : nil),
                ("体重","体重是多少呢",staticAccount?.weight != nil ? "\(staticAccount!.weight!)kg" : nil),
                ("生日","生日是什么时候",staticAccount?.birthday)]]
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AccountModel.remoteSave()
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
        cell.accessoryType = .DisclosureIndicator
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
            if let url = value {
                cell.valueTextField.hidden = true
                cell.headerImageView.hidden = false
                cell.headerImageView.af_setImageWithURL(NSURL.init(string: url)!,placeholderImage: R.image.mine_photo,filter: AspectScaledToFillSizeCircleFilter(size: CGSizeMake(62, 62)))
            }
        case (0,2):
            cell.valueTextField.userInteractionEnabled = true
            let pickerView = KSPickerView.init(frame: CGRectMake(0, 0, SCREEN_WIDTH, 200))
            pickerView.pickerData = [["男","女"]]
            cell.valueTextField.inputView = pickerView
            pickerView.callBackBlock = {
                [weak self] in
                staticAccount?.sex = $0[0] == 0 ? "男":"女"
                self?.view.endEditing(true)
                cell.valueTextField.text = staticAccount?.sex
            }
        case (1,2):
            cell.valueTextField.userInteractionEnabled = true
            let pickerView = KSPickerView.init(frame: CGRectMake(0, 0, SCREEN_WIDTH, 200))
            pickerView.pickerData = [Array(60...250).map{"\($0)"},Array(0...9).map{".\($0)cm"}]
            pickerView.pickerView.selectRow(100, inComponent: 0, animated: false)
            cell.valueTextField.inputView = pickerView
            pickerView.callBackBlock = {
                [weak self] in
                staticAccount?.height = Double($0[0]+60) + Double($0[1])/10
                self?.view.endEditing(true)
                cell.valueTextField.text = "\(staticAccount!.height!)kg"
            }
        case (1,3):
            cell.valueTextField.userInteractionEnabled = true
            let pickerView = KSPickerView.init(frame: CGRectMake(0, 0, SCREEN_WIDTH, 200))
            pickerView.pickerData = [Array(30...150).map{"\($0)"},Array(0...9).map{".\($0)kg"}]
            pickerView.pickerView.selectRow(20, inComponent: 0, animated: false)
            cell.valueTextField.inputView = pickerView
            pickerView.callBackBlock = {
                [weak self] in
                staticAccount?.weight = Double($0[0]+30) + Double($0[1])/10
                self?.view.endEditing(true)
                cell.valueTextField.text = "\(staticAccount!.weight!)kg"
            }

        case (1,4):
            cell.valueTextField.userInteractionEnabled = true
            let pickerView = KSDatePickerView()
            pickerView.datePicker.datePickerMode = .Date
            pickerView.datePicker.maximumDate = NSDate()
            cell.valueTextField.inputView = pickerView
            pickerView.callBackBlock = {
                [weak self] in
                staticAccount?.birthday = $0.toString(format: .Custom("yyyy年MM月dd日"))
                self?.view.endEditing(true)
                cell.valueTextField.text = staticAccount?.birthday
            }
       
        default:
            break
        }
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 && indexPath.section == 0 {
            return 80
        } else {
            return 45
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AccountTableViewCell
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
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
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(albumAction)
            alertController.addAction(pictureAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)

        case (0,1):
            let alertController = UIAlertController(title: nil, message: "请输入昵称", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler(nil)
            let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                staticAccount?.nickname = alertController.textFields?.first?.text
                cell.valueTextField.text = staticAccount?.nickname
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        case (0,3):
            let alertController = UIAlertController(title: nil, message: "请输入手机号码", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler(nil)
            let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                if let phone = alertController.textFields?.first?.text where phone.checkMobileNumble() {
                    staticAccount?.phone = phone
                    cell.valueTextField.text = staticAccount?.phone
                }else{
                    self.noticeInfo("手机号码错误")
                }
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)

        case (1,0):
            let alertController = UIAlertController(title: nil, message: "场景", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler({
                $0.keyboardType = .NumberPad
            })
            
            let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                if let text = alertController.textFields?.first?.text {
                    staticAccount?.scene = text
                    cell.valueTextField.text = text
                }
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        case (1,1):
            let alertController = UIAlertController(title: nil, message: "体质", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler({
                $0.keyboardType = .NumberPad
            })
            
            let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                if let text = alertController.textFields?.first?.text {
                    staticAccount?.constitution = text
                    cell.valueTextField.text = text
                }
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        default:
            break
        }
        
    }
}
extension AccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = image.af_imageAspectScaledToFillSize(CGSizeMake(320/SCREEN_SCALE, 320/SCREEN_SCALE))
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0)) as! AccountTableViewCell
            cell.valueTextField.hidden = true
            cell.headerImageView.hidden = false
            cell.headerImageView.image = image.af_imageRoundedIntoCircle()
            saveImage(image, imageName: "\(staticAccount!.accountid).jpg")
            self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func saveImage(currentImage: UIImage,imageName: String){
        let imageData: NSData = UIImageJPEGRepresentation(currentImage, 1)!
        let fullPath = ((NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString)
            .stringByAppendingPathComponent(imageName)
        imageData.writeToFile(fullPath, atomically: false)
        staticAccount?.avatar = fullPath
        uploadImage(NSURL(fileURLWithPath: fullPath))
    }
}
