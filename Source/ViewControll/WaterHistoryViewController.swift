//
//  WaterHistoryViewController.swift
//  Cup
//
//  Created by king on 16/8/16.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
import Charts
import KSJSONHelp
import KSSwiftExtension

class WaterHistoryViewController: ShareViewController {
    let segmented = UISegmentedControl(items: ["日","周","月"])
    let tableView = UITableView()
    var currentDate = Date()
    var waterplan = CGFloat(staticAccount?.waterplan?.intValue ?? staticAccount!.calculateProposalWater())
    var dataSource = [WaterModel]() {
        didSet{
            var xVals = [String?]()
            var yVals = [BarChartDataEntry]()
            var water = 0
            for (index,model) in dataSource.enumerated() {
                switch segmented.selectedSegmentIndex {
                case 0:
                    xVals.append("\(model.hour.ks.format("%02d")):\(model.minute.ks.format("%02d"))")
                case 1,2:
                    xVals.append("\(model.date[5...6])月\(model.date[8...9])日")
                default:
                    break
                }
                yVals.append(BarChartDataEntry(value: Double(model.amount), xIndex: index))
                water = water + model.amount
            }
            setUpChartData(xVals,yVals: yVals)
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = Colors.white
//        segmented.frame = CGRect(x: 10, y: 10, width: self.view.ks.width-20, height: 20)
        //        self.view.addSubview(segmented)
        segmented.ks.width(self.view.ks.width)
        segmented.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        segmented.selectedSegmentIndex = 0
        self.navigationItem.titleView = segmented
        self.view.addSubview(tableView)
        tableView.register(R.nib.waterHistoryTableViewCell)
        self.tableView.rowHeight = 51
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.snp_makeConstraints { (make) in
//            make.top.equalTo(segmented.snp_bottom).offset(10)
            make.top.equalToSuperview()
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.ks.width, height: view.ks.height/3))
        tableHeaderView.addSubview(chartView)
        chartView.snp_makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-10)
        }
        tableHeaderView.ks.showBorder(.bottom, color: Colors.black)
        self.tableView.tableHeaderView = tableHeaderView
        self.tableView.tableFooterView = UIView()
        valueChanged(segmented)
    }
    func valueChanged(_ seg: UISegmentedControl) {
        switch seg.selectedSegmentIndex {
        case 0:
            dataSource = WaterModel.fetch(currentDate) ?? [WaterModel]()
        case 1,2:
            if let models = WaterModel.fetch(currentDate,type: seg.selectedSegmentIndex) {
                var map = [String:Int]()
                for model in models {
                    let key = model.date
                    if let value = map[key] {
                        map[key] = value+model.amount
                    } else {
                        map[key] = model.amount
                    }
                }
                dataSource = map.map{ (key,value) -> WaterModel in
                    let model = WaterModel()
                    model.date = key
                    model.amount = value
                    return model
                }
            } else {
                dataSource = [WaterModel]()
            }
        default:
            break
        }
    }
}
extension WaterHistoryViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.waterHistoryTableViewCell)!
        switch segmented.selectedSegmentIndex {
        case 0:
            cell.wateLabel.text = "喝了\(model.amount)ml"
            cell.timeLabel.text = "\(model.hour.ks.format("%02d")):\(model.minute.ks.format("%02d"))"
            cell.wateRateLabel.isHidden = true
        case 1,2:
            cell.wateLabel.text = "已喝了\(model.amount)ml"
            cell.timeLabel.text =
                "\(model.date[5...6])月\(model.date[8...9])日"
            cell.wateRateLabel.text = "\(Int(CGFloat(model.amount)/waterplan*100))%"
            cell.wateRateLabel.isHidden = false
        default:
            break
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = Colors.white
        let label = UILabel(frame: CGRect(x: 15, y: 10, width: 0, height: 0))
        view.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = Colors.red
        switch segmented.selectedSegmentIndex {
        case 0:
            label.text = currentDate.ks.string(fromFormat:"yyyy年MM月dd日")
        case 1,2:
            label.text = currentDate.ks.string(fromFormat:"yyyy年")
        default:
            break
        }
        label.sizeToFit()
        return view
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let model = dataSource[(indexPath as NSIndexPath).row]
        let deleteAction = UITableViewRowAction(style: .default, title: "删除") {[unowned self]
            (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            if self.segmented.selectedSegmentIndex == 1 {
                model.delete()
            } else {
                WaterModel.delete(dic: ["date":model.date])
            }
            self.dataSource.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = Colors.red
        return [deleteAction]
    }
    
}
