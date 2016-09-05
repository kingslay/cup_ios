//
//  CalendarView.swift
//  Cup
//
//  Created by king on 16/9/4.
//  Copyright © 2016年 king. All rights reserved.
//

import Foundation
import CVCalendar
import KSSwiftExtension

class CalendarView: UIView {
    var update: ((date: CVDate)->Void)?
    private var nextButton = UIButton()
    private var preButton = UIButton()
    private var calendarView = CVCalendarView()
    private var menuView = CVCalendarMenuView()
    private var dateButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        let topView = UIView(frame: CGRect(x: 0, y: frame.height-400, width: frame.width, height: 60))
        addSubview(topView)
        topView.backgroundColor = Colors.white
        preButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        preButton.setImage(R.image.icon_calendarL(), forState: .Normal)
        topView.addSubview(preButton)
        nextButton.frame = CGRect(x:dateButton.ks.right, y: 0, width: 60, height: 60)
        nextButton.setImage(R.image.icon_calendarR(), forState: .Normal)
        topView.addSubview(nextButton)
        nextButton.ks.right(frame.width)
        dateButton.frame = CGRect(x: preButton.ks.right, y: 0, width: frame.width-preButton.frame.width - nextButton.frame.width, height: 60)
        dateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        dateButton.titleLabel?.textAlignment = .Center
        dateButton.setImage(R.image.icon_calendar(), forState: .Normal)
        dateButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        dateButton.setTitleColor(Colors.pink, forState: .Normal)
        dateButton.setTitle(NSDate().ks.stringFromFormat(" yyyy年MM月dd日"), forState: .Normal)
        topView.addSubview(dateButton)
        menuView.frame = CGRect(x: 0, y: topView.ks.bottom, width: frame.width, height: 24)
        addSubview(menuView)
        menuView.backgroundColor = Swifty<UIColor>.colorFrom("#f5e1de")
        calendarView.frame = CGRect(x: 0, y: menuView.ks.bottom, width: frame.width, height: frame.height-menuView.ks.bottom)
        addSubview(calendarView)
        calendarView.delegate = self
        menuView.delegate = self
        calendarView.calendarAppearanceDelegate = self
        calendarView.backgroundColor = Colors.white
        preButton.rx_tap.subscribeNext { [unowned self] in
            self.calendarView.loadPreviousView()
        }.addDisposableTo(ks.disposableBag)
        nextButton.rx_tap.subscribeNext { [unowned self] in
            self.calendarView.loadNextView()
        }.addDisposableTo(ks.disposableBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func commitCalendarViewUpdate() {
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
}
extension CalendarView: CVCalendarViewDelegate {

    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }

    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }

    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    func shouldScrollOnOutDayViewSelection() -> Bool {
        return false
    }
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return true
    }
    func presentedDateUpdated(date: CVDate) {
        dateButton.setTitle(date.convertedDate()?.ks.stringFromFormat("yyyy年MM月dd日"), forState: .Normal)
        update?(date: date)
    }
}
extension CalendarView: CVCalendarMenuViewDelegate {

}

extension CalendarView: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }

    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont { return UIFont.systemFontOfSize(14) }

    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .Selected, _), (_, .Highlighted, _): return Colors.white
        case (_, .Out, _),(.Sunday, _, _),(.Saturday, _, _): return Colors.black
        default: return Colors.pink
        }
    }

    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .Selected, _), (_, .Highlighted, _): return Colors.red
        default: return nil
        }
    }
}