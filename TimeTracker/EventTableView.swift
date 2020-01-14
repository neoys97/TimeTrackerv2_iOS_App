//
//  EventTableViewDelegate.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 10/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class EventTableView: UITableView, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Table view data source
    var eventList: EventList!
    let dFormatter = DateFormatter()
    let dtFormatter = DateFormatter()
    var viewDate: Date?
    weak var parentViewController: ViewController?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        dFormatter.dateFormat = "dd-MMM-yyyy"
        dtFormatter.dateFormat = "HH:mm"
        self.dataSource = self
        self.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard eventList.events[dFormatter.string(from: viewDate!)] != nil else {return 0}
        return eventList.events[dFormatter.string(from: viewDate!)]!.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
        guard eventList.events[dFormatter.string(from: viewDate!)] != nil else {return cell}
        let data = eventList.events[dFormatter.string(from: viewDate!)]![indexPath.row]
        cell.eventTitleLabel.text = data.title
        if let date = data.startTime {
            cell.startTimeLabel.text = dtFormatter.string(from: date)
        }
        if let date = data.endTime {
            cell.endTimeLabel.text = dtFormatter.string(from: date)
        }
        switch data.category {
            case .routine:
                cell.colorIndicatorView.backgroundColor = .systemIndigo
            case .task:
                cell.colorIndicatorView.backgroundColor = .systemGreen
        }
        if data.clash {
            cell.colorIndicatorView.backgroundColor = .systemRed
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") {
            (action, view, completionHandler) in
            if let pvc = self.parentViewController {
                pvc.deleteEvent(date: self.viewDate, index: indexPath.row)
            }
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let pvc = self.parentViewController {
            pvc.reloadView()
        }
    }
}
