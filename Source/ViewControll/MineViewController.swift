//
//  MineViewController.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage
import KSSwiftExtension
class MineViewController: UITableViewController {
    var datas :[[(UIImage?,String,String?)]]!
    lazy var navigationAccessoryView : NavigationAccessoryView = {
        let naview = NavigationAccessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 44.0))
        naview.doneButton.target = self
        naview.doneButton.action = #selector(navigationDone)
        return naview
        }()
    func navigationDone() {
        tableView?.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.background
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_exit(), style: .Plain, target: self, action: #selector(exitAccount))
        self.tableView.backgroundColor = Colors.background
        self.tableView.registerNib(R.nib.mineTableViewCell)
        initData()
        self.tableView.rowHeight = 51
        self.tableView.reloadData()
    }
    func exitAccount() {
        let alertController = UIAlertController(title: nil, message: "确认要退出当前账号吗", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "继续", style: UIAlertActionStyle.Default,handler: nil)
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "退出", style: UIAlertActionStyle.Default) {
            [unowned self] (action: UIAlertAction!) -> Void in
            NSUserDefaults.standardUserDefaults().removeObjectForKey("sharedAccount")
            staticIdentifier = nil
            if let vcs = self.tabBarController?.viewControllers where vcs.count > 1, let navigationController = vcs[1] as? UINavigationController, let cupViewController = navigationController.topViewController as? CupViewController, let peripheral = cupViewController.peripheral  {
                cupViewController.central.cancelPeripheralConnection(peripheral)
            }
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            NSUserDefaults.standardUserDefaults().removeObjectForKey("ClockModelClose")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("clockArray")
            TemperatureModel.delete(dic: [:])
            UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.sMS.initialViewController()
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    //    override func viewWillAppear(animated: Bool) {
    //    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initData(){
        datas = [[(R.image.icon_Head(),"我的头像",staticAccount?.avatar),
            (R.image.icon_nickname(),"昵称",staticAccount?.nickname),
            (R.image.icon_gender(),"性别",staticAccount?.sex),
            (R.image.icon_height(),"身高(cm)",staticAccount?.height != nil ? "\(staticAccount!.height!)" : nil),
            (R.image.icon_plan(),"饮水计划(ml)",staticAccount?.waterplan != nil ? "\(staticAccount!.waterplan!)" : nil)],
                 [(R.image.icon_account(),"帐号绑定",nil),
                    (R.image.icon_warn(),"提醒设置",nil),
                    (R.image.icon_pairing(),"配对信息",nil),
                    (R.image.icon_nickname(),"固件升级",nil),
                    (R.image.icon_about(),"关于",nil)]]
    }

}
extension MineViewController {
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return datas.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.mineTableViewCell)!
        let (image,title,value) = datas[indexPath.section][indexPath.row]
        cell.iconImageView.image = image
        cell.titleLabel.text = title
        cell.headerImageView.hidden = true
        cell.valueTextField.hidden = true;
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.headerImageView.hidden = false
                if let str = value,url = NSURL(string: str) {
                    cell.headerImageView!.af_setImageWithURL(url, placeholderImage: R.image.label_icon_Personal_initial(),filter: AspectScaledToFillSizeCircleFilter(size: CGSizeMake(41, 41)))
                }
            case 1,3,4:
                cell.valueTextField.hidden = false
                cell.valueTextField.userInteractionEnabled = false
                cell.valueTextField.text = value
                if indexPath.row == 1 {
                    cell.valueTextField.placeholder = "未添加"
                } else if indexPath.row == 3 {
                    cell.valueTextField.placeholder = "身高是多少呢"
                    cell.valueTextField.userInteractionEnabled = true
                    cell.valueTextField.inputAccessoryView = navigationAccessoryView
                    let pickerView = KSPickerView()
                    pickerView.pickerData = [Array(60...250).map{"\($0)"},Array(0...9).map{".\($0)cm"}]
                    pickerView.selectRow(100, inComponent: 0, animated: false)
                    cell.valueTextField.inputView = pickerView
                    pickerView.callBackBlock = {
                        [unowned cell] in
                        staticAccount?.height = Double($0[0]+60) + Double($0[1])/10
                        cell.valueTextField.text = "\(staticAccount!.height!)"
                    }

                }else if indexPath.row == 4 {
                    cell.valueTextField.placeholder = ""
                    cell.accessoryType = .DisclosureIndicator
                }
            default:
                break
            }
        } else {
            cell.accessoryType = .DisclosureIndicator
        }
        return cell
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else{
            return 25
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MineTableViewCell
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
                        self.ks.noticeInfo("请在iPhone的“设置-隐私-相机”选项中，允许访问你的相机",autoClear: true)
                        break
                    default:
                        break
                    }
                }else{
                    self.ks.noticeInfo("您的设备没有摄像头!", autoClear: true)
                    imagePickerController.sourceType = .PhotoLibrary
                }
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel) { _ in
                cell.selected = false
            }
            alertController.addAction(albumAction)
            alertController.addAction(pictureAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        case(0,1):
            let alertController = UIAlertController(title: nil, message: "请输入昵称", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler(nil)
            let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction!) -> Void in
                staticAccount?.nickname = alertController.textFields?.first?.text
                cell.valueTextField.text = staticAccount?.nickname
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        case(1,0):
            let vc = R.nib.accoutBindViewController.firstView(owner: nil, options: nil)!
            vc.phoneLabel.text = staticAccount?.phone
            self.navigationController?.ks.pushViewController(vc)
        case(1,1):
            let vc = R.nib.pushSettingViewController.firstView(owner: nil, options: nil)!
            self.navigationController?.ks.pushViewController(vc)
        case(1,2):
            let vc = R.nib.firmwareViewController.firstView(owner: nil, options: nil)!
            vc.serialLabel.text = "序列号: " + (staticIdentifier ?? "")
            self.navigationController?.ks.pushViewController(vc)
        case(1,3):
            let vc = R.nib.firmwareViewController.firstView(owner: nil, options: nil)!
            vc.serialLabel.text = "序列号: " + (staticIdentifier ?? "")
            vc.updateButton.hidden = false
            self.navigationController?.ks.pushViewController(vc)
        case(1,4):
            self.navigationController?.ks.pushViewController(R.nib.aboutUsViewController.firstView(owner: nil, options: nil)!)
        default:
            break;
        }
    }

}
extension MineViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = image.af_imageAspectScaledToFillSize(CGSizeMake(320/KS.SCREEN_SCALE, 320/KS.SCREEN_SCALE))
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! MineTableViewCell
            cell.headerImageView.hidden = false
            cell.headerImageView.image = image.af_imageAspectScaledToFillSize(CGSizeMake(62, 62)).af_imageRoundedIntoCircle()
            saveImage(image, imageName: "\(staticAccount!.accountid).jpg")
            self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func saveImage(currentImage: UIImage,imageName: String){
        let imageData: NSData = UIImageJPEGRepresentation(currentImage, 1)!
        let fullPath = ((NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString)
            .stringByAppendingPathComponent(imageName)
        imageData.writeToFile(fullPath, atomically: false)
        staticAccount?.avatar = "file:"+fullPath
        uploadImage(NSURL(fileURLWithPath: fullPath))
    }
}
