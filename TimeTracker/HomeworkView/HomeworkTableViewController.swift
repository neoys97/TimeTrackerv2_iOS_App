//
//  HomeworkTableViewController.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 14/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class HomeworkTableViewController: UITableViewController {
    
    let eventList = EventList.sharedInstance
    var homeworkList:[Event] = []
    let dFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func reloadView() {
        homeworkList.removeAll()
        for (_, events) in eventList.events {
            for event in events {
                if event.category == .task {
                    homeworkList.append(event)
                }
            }
        }
        homeworkList.sort()
        self.tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return homeworkList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dFormatter.dateFormat = "HH:mm"
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeworkCell", for: indexPath) as! HomeworkTableViewCell
        let i = indexPath.row
        
        cell.titleLabel.text = homeworkList[i].title
        if let start = homeworkList[i].startTime, let end = homeworkList[i].endTime {
            cell.startLabel.text = dFormatter.string(from: start)
            cell.endLabel.text = dFormatter.string(from: end)
            dFormatter.dateFormat = "dd-MMM-yyyy"
            cell.dateLabel.text = dFormatter.string(from: start)
        }
        dFormatter.dateFormat = "dd-MMM-yyyy"
        if let due = homeworkList[i].dueDate {
            cell.dueDateLabel.text = dFormatter.string(from: due)
        }
        cell.classTypeLabel.text = homeworkList[i].classType
        if let index = eventList.listOfClass.firstIndex(of: homeworkList[i].classType) {
            cell.colorIndicatorView.backgroundColor = eventList.classColors[index]
        }
        else {
            cell.colorIndicatorView.backgroundColor = .systemGreen
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 101.0
    }
    
}
