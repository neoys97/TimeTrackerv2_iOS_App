//
//  ClassTableViewController.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 14/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class ClassTableViewController: UITableViewController {

    var listOfClass: [String]!
    var selectedClassIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneSelectClass" {
            if let index = tableView.indexPathForSelectedRow?.row {
                selectedClassIndex = index
            }
        }
    }
    
    @IBAction func returned(segue:UIStoryboardSegue) {
        if segue.identifier == "doneAddCustomClass" {
            let source = segue.source as! CustomClassTableViewController
            if let newClass = source.customClass {
                if !listOfClass.contains(newClass) {
                    listOfClass.append(newClass)
                    listOfClass.sort()
                }
            }
        }
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 { return listOfClass.count }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 9.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 9.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customClassIdentifier", for: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "classIdentifier", for: indexPath) as! ClassTableViewCell
            cell.classLabel.text = listOfClass[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") {
            (action, view, completionHandler) in
            self.deleteClass(at: indexPath.row)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func deleteClass (at index: Int) {
        listOfClass.remove(at: index)
        self.tableView.cellForRow(at: IndexPath(row: index, section: 0))?.isHidden = true
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .bottom)
    }
    
}
