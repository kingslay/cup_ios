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
import RxCocoa

class AccountViewController: UITableViewController {
    var datas :[[(UIImage?,String,String,String?)]]!
    lazy var navigationAccessoryView : NavigationAccessoryView = {
        [unowned self] in
        let naview = NavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44.0))
        naview.doneButton.target = self
        naview.doneButton.action = #selector(navigationDone(_:))
        return naview
        }()
    func navigationDone(_ sender: UIBarButtonItem) {
        tableView?.endEditing(true)
    }
    //MARK: UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView?.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        self.tableView.register(R.nib.mineTableViewCell)
        self.tableView.rowHeight = 51
        self.tableView.backgroundColor = Colors.background
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "个人信息"
    }
    func initData(){
        datas = [[(R.image.icon_Head(),"我的头像","未添加",staticAccount?.avatar),
            (R.image.icon_nickname(),"昵称","未添加",staticAccount?.nickname),
            (R.image.icon_gender(),"性别","男",staticAccount?.sex),
            (R.image.icon_height(),"身高(cm)","身高是多少呢",staticAccount?.height != nil ? "\(staticAccount!.height!)" : nil),
            (R.image.icon_weight(),"体重","体重是多少呢",staticAccount?.weight != nil ? "\(staticAccount!.weight!)kg" : nil),
            (R.image.icon_age(),"生日","生日是什么时候",staticAccount?.birthday)]]
    }
    override func viewWillDisappear(_ animated: Bool) {
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
}
extension AccountViewController {

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.mineTableViewCell, for: indexPath)!
        cell.valueTextField.isHidden = false
        cell.headerImageView.isHidden = true
        cell.selectionStyle = .none
        let (image,title,placeholder,value) = datas[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.iconImageView.image = image
        cell.titleLabel.text = title
        cell.valueTextField.textColor = Colors.red
        if let value = value {
            cell.valueTextField.text = value
        }else{
            cell.valueTextField.placeholder = placeholder
        }
        cell.valueTextField.isUserInteractionEnabled = false
        switch ((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row) {
        case (0,0):
            cell.valueTextField.isHidden = true
            cell.headerImageView.isHidden = false
            if let url = value {
                cell.headerImageView.af_setImage(withURL:URL(string: url)!,placeholderImage: R.image.默认头像(),filter: AspectScaledToFillSizeCircleFilter(size: CGSize(width: 62, height: 62)))
            }else{
                 cell.headerImageView.image = R.image.默认头像()
            }
        case (0,3):
            cell.valueTextField.isUserInteractionEnabled = true
            cell.valueTextField.inputAccessoryView = navigationAccessoryView
            let pickerView = KSPickerView()
            pickerView.pickerData = [Array(60...250).map{"\($0)"},Array(0...9).map{".\($0)cm"}]
            pickerView.selectRow(100, inComponent: 0, animated: false)
            cell.valueTextField.inputView = pickerView
            pickerView.callBackBlock = {
                [unowned cell] in
                staticAccount?.height = NSNumber(value: Double($0[0]+60) + Double($0[1])/10)
                cell.valueTextField.text = "\(staticAccount!.height!)cm"
            }
        case (0,4):
            cell.valueTextField.isUserInteractionEnabled = true
            cell.valueTextField.inputAccessoryView = navigationAccessoryView
            let pickerView = KSPickerView()
            pickerView.pickerData = [Array(30...150).map{"\($0)"},Array(0...9).map{".\($0)kg"}]
            pickerView.selectRow(20, inComponent: 0, animated: false)
            cell.valueTextField.inputView = pickerView
            pickerView.callBackBlock = {
                [unowned cell] in
                staticAccount?.weight =  NSNumber(value: Double($0[0]+30) + Double($0[1])/10)
                cell.valueTextField.text = "\(staticAccount!.weight!)kg"
            }

        case (0,5):
            cell.valueTextField.isUserInteractionEnabled = true
            cell.valueTextField.inputAccessoryView = navigationAccessoryView
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.maximumDate = Date()
            cell.valueTextField.inputView = datePicker
            datePicker.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned cell,unowned datePicker] in
                staticAccount?.birthday = datePicker.date.ks.string(fromFormat:"yyyy年MM月dd日")
                cell.valueTextField.text = staticAccount?.birthday
            }).addDisposableTo(ks.disposableBag)
            datePicker.date = Date()
        default:
            break
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MineTableViewCell
        switch ((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row) {
        case (0,0):
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let albumAction = UIAlertAction(title: "从相册选择", style: UIAlertActionStyle.default) {
                (action: UIAlertAction!) -> Void in
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .savedPhotosAlbum
                self.present(imagePickerController, animated: true, completion: nil)
            }
            let pictureAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.default) {
                (action: UIAlertAction!) -> Void in
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePickerController.sourceType = .camera
                    switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
                    case .notDetermined:
                        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: nil)
                        break
                    case .denied:
                        self.ks.noticeInfo("请在iPhone的“设置-隐私-相机”选项中，允许访问你的相机",autoClear: true)
                        break
                    default:
                        break
                    }
                }else{
                    self.ks.noticeInfo("您的设备没有摄像头!", autoClear: true)
                    imagePickerController.sourceType = .photoLibrary
                }
                self.present(imagePickerController, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(albumAction)
            alertController.addAction(pictureAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)

        case (0,1):
            let alertController = UIAlertController(title: nil, message: "请输入昵称", preferredStyle: .alert)
            alertController.addTextField(configurationHandler: nil)
            let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) {
                (action: UIAlertAction!) -> Void in
                staticAccount?.nickname = alertController.textFields?.first?.text
                cell.valueTextField.text = staticAccount?.nickname
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        case (0,2):
            let alertController = UIAlertController(title: nil, message: "您的性别", preferredStyle: .alert)
            let menAction = UIAlertAction(title: "男", style: UIAlertActionStyle.default) {
                (action: UIAlertAction!) -> Void in
                staticAccount?.sex = action.title
                cell.valueTextField.text = staticAccount?.sex
            }
            alertController.addAction(menAction)
            let womenAction = UIAlertAction(title: "女", style: UIAlertActionStyle.default) {
                (action: UIAlertAction!) -> Void in
                staticAccount?.sex = action.title
                cell.valueTextField.text = staticAccount?.sex
            }
            alertController.addAction(womenAction)

            self.present(alertController, animated: true, completion: nil)
        case (1,3):
            let alertController = UIAlertController(title: nil, message: "请输入手机号码", preferredStyle: .alert)
            alertController.addTextField(){
              $0.keyboardType = .numberPad
            }
            
            let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) {
                (action: UIAlertAction!) -> Void in
                if let phone = alertController.textFields?.first?.text , phone.checkMobileNumble() {
                    staticAccount?.phone = phone
                    cell.valueTextField.text = staticAccount?.phone
                }else{
                    self.ks.noticeInfo("手机号码错误")
                }
            }
            alertController.addAction(okAction)
//            self.presentViewController(alertController, animated: true, completion: nil)

        case (1,0):
            let sheetController = UIAlertController(title: nil, message: "水杯场景", preferredStyle: .actionSheet)
            sheetController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            ["办公室","家里","户外","车载"].forEach {
                sheetController.addAction(UIAlertAction(title: $0, style: UIAlertActionStyle.default) {
                    (action: UIAlertAction!) in
                    staticAccount?.scene = action.title
                    cell.valueTextField.text = action.title
                    })
            }
            sheetController.addAction(UIAlertAction(title: "其他", style: UIAlertActionStyle.default) { [unowned self] (action: UIAlertAction!) in
                 let alertController = UIAlertController(title: nil, message: "水杯场景", preferredStyle: .alert)
                alertController.addTextField(configurationHandler: nil)
                let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) {
                    (action: UIAlertAction!) -> Void in
                    if let text = alertController.textFields?.first?.text , text.characters.count > 0 {
                        staticAccount?.scene = text
                        cell.valueTextField.text = text
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                })
            self.present(sheetController, animated: true, completion: nil)
        case (1,1):
            let sheetController = UIAlertController(title: nil, message: "体质", preferredStyle: .actionSheet)
            sheetController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            ["易出汗","少出汗","正常"].forEach {
                sheetController.addAction(UIAlertAction(title: $0, style: UIAlertActionStyle.default) {
                    (action: UIAlertAction!) in
                    staticAccount?.scene = action.title
                    cell.valueTextField.text = action.title
                    })
            }
            sheetController.addAction(UIAlertAction(title: "其他", style: UIAlertActionStyle.default) { [unowned self] (action: UIAlertAction!) in
                let alertController = UIAlertController(title: nil, message: "体质", preferredStyle: .alert)
                alertController.addTextField(configurationHandler: nil)
                let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) {
                    (action: UIAlertAction!) -> Void in
                    if let text = alertController.textFields?.first?.text , text.characters.count > 0 {
                        staticAccount?.constitution = text
                        cell.valueTextField.text = text
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                })
            self.present(sheetController, animated: true, completion: nil)
        default:
            break
        }
        
    }
}
extension AccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = image.af_imageAspectScaled(toFill:CGSize(width: 320/KS.SCREEN_SCALE, height: 320/KS.SCREEN_SCALE))
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! MineTableViewCell
            cell.valueTextField.isHidden = true
            cell.headerImageView.isHidden = false
            cell.headerImageView.image = image.af_imageAspectScaled(toFill:CGSize(width: 62, height: 62)).af_imageRoundedIntoCircle()
            saveImage(image, imageName: "\(staticAccount!.accountid).jpg")
            self.parent?.dismiss(animated: true, completion: nil)
        }
    }
    func saveImage(_ currentImage: UIImage,imageName: String){
        let imageData: Data = UIImageJPEGRepresentation(currentImage, 1)!
        let fullPath = ((NSHomeDirectory() as NSString).appendingPathComponent("Documents") as NSString)
            .appendingPathComponent(imageName)
        try? imageData.write(to: URL(fileURLWithPath: fullPath), options: [])
        staticAccount?.avatar = "file:"+fullPath
        CupMoya.upload(imagePath:URL(fileURLWithPath: fullPath))
    }
}
