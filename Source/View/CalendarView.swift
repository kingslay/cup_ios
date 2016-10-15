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
    var update: ((_ date: CVDate)->Void)?
    fileprivate var nextButton = UIButton()
    fileprivate var preButton = UIButton()
    fileprivate var calendarView = CVCalendarView()
    fileprivate var menuView = CVCalendarMenuView()
    fileprivate var dateButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let topView = UIView(frame: CGRect(x: 0, y: frame.height-400, width: frame.width, height: 60))
        addSubview(topView)
        topView.backgroundColor = Colors.white
        preButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        preButton.setImage(R.image.icon_calendarL(), for: .normal)
        topView.addSubview(preButton)
        nextButton.frame = CGRect(x:dateButton.ks.right, y: 0, width: 60, height: 60)
        nextButton.setImage(R.image.icon_calendarR(), for: .normal)
        topView.addSubview(nextButton)
        nextButton.ks.right(frame.width)
        dateButton.frame = CGRect(x: preButton.ks.right, y: 0, width: frame.width-preButton.frame.width - nextButton.frame.width, height: 60)
        dateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        dateButton.titleLabel?.textAlignment = .center
        dateButton.setImage(R.image.icon_calendar(), for: .normal)
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        dateButton.setTitleColor(Colors.pink, for: UIControlState())
        dateButton.setTitle(Foundation.Date().ks.string(fromFormat:" yyyy年MM月dd日"), for: UIControlState())
        topView.addSubview(dateButton)
        menuView.frame = CGRect(x: 0, y: topView.ks.bottom, width: frame.width, height: 24)
        addSubview(menuView)
        menuView.backgroundColor = UIColor.ks.colorFrom("#f5e1de")
        calendarView.frame = CGRect(x: 0, y: menuView.ks.bottom, width: frame.width, height: frame.height-menuView.ks.bottom)
        addSubview(calendarView)
        calendarView.delegate = self
        menuView.delegate = self
        calendarView.calendarAppearanceDelegate = self
        calendarView.backgroundColor = Colors.white
        preButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.calendarView.loadPreviousView()
        }).addDisposableTo(ks.disposableBag)
        nextButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.calendarView.loadNextView()
        }).addDisposableTo(ks.disposableBag)
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
        return .monthView
    }

    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .sunday
    }
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.circle)
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
    func presentedDateUpdated(_ date: CVDate) {
        dateButton.setTitle(date.convertedDate()?.ks.string(fromFormat:"yyyy年MM月dd日"), for: UIControlState())
        update?(date)
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
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont { return UIFont.systemFont(ofSize: 14) }

    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .selected, _), (_, .highlighted, _): return Colors.white
        case (_, .out, _),(.sunday, _, _),(.saturday, _, _): return Colors.black
        default: return Colors.pink
        }
    }

    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .selected, _), (_, .highlighted, _): return Colors.red
        default: return nil
        }
    }
}
