//
//  ViewController.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 9/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SceneKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var loadingView: UIView = UIView()
    
    var viewDate = Date() {
        didSet {
            self.reloadView()
        }
    }
    var currentEventLoc: Int?
    
    var numberOfRows: Int = 5
    @IBOutlet weak var eventTableView: EventTableView!
    var dFormatter = DateFormatter()
    let dateFormat = "dd-MMM-yyyy"
    let dateTimeFormat = "dd-MMM-yyyy HH:mm"
    var eventList = EventList.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        try! FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        
        self.view.isUserInteractionEnabled = false
        setupActivityView()
        loadingView.isHidden = false
        activityIndicator.startAnimating()
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode   = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.scrollToDate(Date(), animateScroll: false)
        
        eventTableView.eventList = eventList
        eventTableView.viewDate = viewDate
        eventTableView.parentViewController = self
        
        dFormatter.dateFormat = dateFormat

        self.loadData()
        self.reloadView()
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: nil) { (notification) in
            self.eventList.saveData()
        }
        
        self.view.isUserInteractionEnabled = true
        loadingView.isHidden = true
        activityIndicator.stopAnimating()
    }

    func setupActivityView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor(red: 68.0, green: 68.0, blue: 68.0, alpha: 1)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        loadingView.addSubview(activityIndicator)
        self.view.addSubview(loadingView)
        loadingView.isHidden = true
    }
    
    @objc func toggleWeekMonth () {
        if numberOfRows == 5 {
            self.constraint.constant = 150
            self.numberOfRows = 1
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }) { completed in
                self.calendarView.reloadData(withAnchor: self.viewDate)
            }
        } else {
            self.constraint.constant = 350
            self.numberOfRows = 5
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
                self.calendarView.reloadData(withAnchor: self.viewDate)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        dFormatter.dateFormat = dateFormat
        let target = segue.destination as! AddEventViewController
        target.eventList = eventList
        target.startDateTime = viewDate
        target.endDateTime = viewDate
        
        if segue.identifier == "showEventSegue" {
            if let events = eventList.events[dFormatter.string(from: viewDate)], let index = eventTableView.indexPathForSelectedRow?.row {
                currentEventLoc = index
                target.startDateTime = events[index].startTime
                target.endDateTime = events[index].endTime
                target.eventTitle = events[index].title
                target.category = events[index].category
                target.classType = events[index].classType
                target.editEvent = true
            }
        }
    }
    
    @IBAction func returned(segue:UIStoryboardSegue) {
        dFormatter.dateFormat = dateFormat
        let source = segue.source as! AddEventViewController
        if source.editEvent {
            eventList.delEvent(eventList.events[dFormatter.string(from: viewDate)]![currentEventLoc!])
            eventList.addToBeAddedEvent()
        }
        else {
            if eventList.toBeAddedEvents.count != 0 {
                eventList.addToBeAddedEvent()
            }
        }
        reloadView()
    }
    
    
    func deleteEvent(date: Date?, index: Int) {
        dFormatter.dateFormat = dateFormat
        let event = eventList.events[dFormatter.string(from: date!)]![index]
        eventList.delEvent(event)
        self.eventTableView.cellForRow(at: IndexPath(row: index, section: 0))?.isHidden = true
        self.eventTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .bottom)
    }
    
    func loadData() {
        eventList.loadData()
    }
    
    func reloadView() {
        eventTableView.viewDate = viewDate
        eventTableView.reloadData()
        calendarView.reloadData()
    }
    
    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
    }
        
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        dFormatter.dateFormat = dateFormat
        let dateString = dFormatter.string(from: cellState.date)
        var clash = false
        
        if let events = eventList.events[dateString]{
            for e in events {
                if e.clash {
                    clash = true
                    break
                }
            }
        }
        
        if (Calendar.current.isDate(cellState.date, inSameDayAs:Date())) {
            cell.dateLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            cell.dateLabel.textColor = clash ? UIColor.systemRed : UIColor.systemBlue
        }
        else if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.font = UIFont.systemFont(ofSize: 17.0)
            cell.dateLabel.textColor = clash ? UIColor.systemRed : UIColor.black
        }
        else {
            cell.dateLabel.font = UIFont.systemFont(ofSize: 17.0)
            cell.dateLabel.textColor = UIColor.gray
        }
    }
    
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.layer.cornerRadius = 21
            cell.selectedView.isHidden = false
        }
        else {
            cell.selectedView.isHidden = true
        }
    }
    
    func handleCellEvents(cell: DateCell, cellState: CellState) {
        dFormatter.dateFormat = dateFormat
        let dateString = dFormatter.string(from: cellState.date)
        var hasRoutine = false
        var hasTask = false
        
        if let events = eventList.events[dateString]{
            for e in events {
                if e.category == .routine {hasRoutine = true}
                if e.category == .task {hasTask = true}
            }
        }
        cell.routineDotView.layer.cornerRadius = 5
        cell.taskDotView.layer.cornerRadius = 5
        cell.routineDotView.isHidden = !hasRoutine
        cell.taskDotView.isHidden = !hasTask
    }
}

extension ViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        dFormatter.dateFormat = dateFormat
        let startDate = dFormatter.date(from: "01-Jan-2018")!
        let endDate = dFormatter.date(from: "31-Dec-2023")!
        if numberOfRows == 5 {
            return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: numberOfRows, generateOutDates: .tillEndOfRow)
        } else {
            return ConfigurationParameters(startDate: startDate,
                                           endDate: endDate,
                                           numberOfRows: numberOfRows,
                                           generateOutDates: .tillEndOfRow,
                                           hasStrictBoundaries: true)
        }
    }
}

extension ViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        viewDate = cellState.date
        configureCell(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        dFormatter.dateFormat = "MMM yyyy"
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthTitle.text = dFormatter.string(from: range.start)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleWeekMonth))
        header.addGestureRecognizer(tap)
        return header
    }

    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 100)
    }
}
