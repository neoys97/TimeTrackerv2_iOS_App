//
//  AddEventViewController.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 10/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class AddEventViewController: UITableViewController {
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var startDateTimeLabel: UILabel!
    @IBOutlet weak var startDateTimePicker: UIDatePicker!
    @IBOutlet weak var endDateTimeLabel: UILabel!
    @IBOutlet weak var endDateTimePicker: UIDatePicker!
    @IBOutlet weak var repeatSegmentedControl: UISegmentedControl!
    @IBOutlet weak var repeatTableViewCell: UITableViewCell!
    @IBOutlet weak var timeSuggestionTableViewCell: UITableViewCell!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationPicker: UIDatePicker!
    
    var showDate = false
    var showStartTime = false
    var showEndTime = false
    var showSuggestionControl = false
    var editEvent = false
    
    var eventTitle: String?
    var startDateTime: Date?
    var endDateTime: Date?
    var dueDate: Date?
    var category: Event.Category = .task
    var suggestedTime: [Date?] = [nil, nil]

    var listOfEvents: [Event] = []
    var eventList: EventList!
    
    let dFormatter = DateFormatter()
    
    @IBAction func toggleSuggestion(_ sender: Any) {
        let toggleButton = sender as! UISwitch
        tableView.beginUpdates()
        showSuggestionControl = toggleButton.isOn
        tableView.endUpdates()
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        changeDateLabel (dateLabel, sender, "dd-MMM-yyyy")
    }
    
    @IBAction func startDateTimePickerChanged(_ sender: Any) {
        changeDateLabel (startDateTimeLabel, sender, "HH:mm")
    }
    
    @IBAction func endDateTimePickerChanged(_ sender: Any) {
        changeDateLabel (endDateTimeLabel, sender, "HH:mm")
    }
    
    @IBAction func dueDatePickerChanged(_ sender: Any) {
        changeDateLabel (dueDateLabel, sender, "dd-MMM-yyyy")
    }
    
    @IBAction func durationPickerChanged(_ sender: Any) {
        let datePicker = sender as! UIDatePicker
        dFormatter.dateFormat = "HH"
        let hour = dFormatter.string(from: datePicker.date)
//        durationHour = Int(hour)!
        dFormatter.dateFormat = "mm"
        let min = dFormatter.string(from: datePicker.date)
//        durationMin = Int(min)!
        durationLabel.text = hour + " hour " + min + " min"
    }
    
    func changeDateLabel (_ dateLabel: UILabel, _ sender: Any, _ format: String) {
        dFormatter.dateFormat = format
        let datePicker = sender as! UIDatePicker
        dateLabel.text = dFormatter.string(from: datePicker.date)
    }
    
    @IBAction func suggestionButtonTapped(_ sender: Any) {
        dueDate = dueDatePicker.date
        var today = Date()
        while today <= dueDate! {
            suggestedTime = eventList.suggestTimeSlot(on: today, for: durationPicker.date)
            if let suggestStart = suggestedTime[0], let suggestEnd = suggestedTime[1] {
                datePicker.setDate(suggestStart, animated: false)
                changeDateLabel(dateLabel, datePicker as Any, "dd-MMM-yyyy")
                startDateTimePicker.setDate(suggestStart, animated: false)
                changeDateLabel(startDateTimeLabel, startDateTimePicker as Any, "HH:mm")
                endDateTimePicker.setDate(suggestEnd, animated: false)
                changeDateLabel(endDateTimeLabel, endDateTimePicker as Any, "HH:mm")
                let alert = UIAlertController(title: "Found", message: "Found suggested time for the task!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            today = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        }
        let alert = UIAlertController(title: "Not Found", message: "Could not find a time slot for the task", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        dFormatter.dateFormat = "dd-MMM-yyyy"
        datePicker.date = startDateTime!
        dateLabel.text = dFormatter.string(from: startDateTime!)
        
        dueDate = endDateTime!
        dueDatePicker.date = dueDate!
        dueDateLabel.text = dFormatter.string(from: dueDate!)
        
        dFormatter.dateFormat = "HH:mm"
        startDateTimePicker.date = startDateTime!
        endDateTimePicker.date = endDateTime!
        startDateTimeLabel.text = dFormatter.string(from: startDateTime!)
        endDateTimeLabel.text = dFormatter.string(from: endDateTime!)
        
        if let title = eventTitle {
            eventTitleTextField.text = title
        }
        if editEvent {
            repeatTableViewCell.isHidden = true
            timeSuggestionTableViewCell.isHidden = true
        }
    }
    
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneAddEventSegue" {
            if let title = eventTitleTextField.text {
                let oneMonthFromNow = Calendar.current.date(byAdding: .day, value: 30, to: endDateTime!)
                eventTitle = eventTitleTextField.text
                if repeatSegmentedControl.selectedSegmentIndex == 0 {
                    listOfEvents.append(Event(title, from: startDateTime, to: endDateTime, category))
                }
                else if repeatSegmentedControl.selectedSegmentIndex == 1 {
                    while startDateTime! < oneMonthFromNow! {
                        listOfEvents.append(Event(title, from: startDateTime, to: endDateTime, .routine))
                        startDateTime = Calendar.current.date(byAdding: .day, value: 1, to: startDateTime!)
                        endDateTime = Calendar.current.date(byAdding: .day, value: 1, to: endDateTime!)
                    }
                }
                else if repeatSegmentedControl.selectedSegmentIndex == 2 {
                    while startDateTime! < oneMonthFromNow! {
                        listOfEvents.append(Event(title, from: startDateTime, to: endDateTime, .routine))
                        startDateTime = Calendar.current.date(byAdding: .day, value: 7, to: startDateTime!)
                        endDateTime = Calendar.current.date(byAdding: .day, value: 7, to: endDateTime!)
                    }
                }
            }
        }
        else {
            editEvent = false
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        dFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
        startDateTime = dFormatter.date(from: dateLabel.text! + " " + startDateTimeLabel.text!)
        endDateTime = dFormatter.date(from: dateLabel.text! + " " + endDateTimeLabel.text!)
        if identifier == "doneAddEventSegue" {
            if startDateTime! > endDateTime! {
                let alert = UIAlertController(title: "Error", message: "Start time must be smaller than end time", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default))
                self.present(alert, animated: true)
                return false
            }
            else if let text = eventTitleTextField.text, text.isEmpty {
                let alert = UIAlertController(title: "Error", message: "Title cannot be empty", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default))
                self.present(alert, animated: true)
                return false
            }
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                showDate = !showDate
                datePicker.isHidden = !showDate
            }
            else if (indexPath.row == 2) {
                showStartTime = !showStartTime
                startDateTimePicker.isHidden = !showStartTime
            }
            else if (indexPath.row == 4) {
                showEndTime = !showEndTime
                endDateTimePicker.isHidden = !showEndTime
            }
        }
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.section == 1) {
            if indexPath.row == 1 {
                return (showDate ? tableView.rowHeight : 0.0)
            }
            if indexPath.row == 3 {
                return (showStartTime ? tableView.rowHeight : 0.0)
            }
            else if indexPath.row == 5 {
                return (showEndTime ? tableView.rowHeight : 0.0)
            }
        }
        else if (indexPath.section == 2) {
            if indexPath.row != 0 {
                return (showSuggestionControl ? tableView.rowHeight : 0.0)
            }
        }
        
        return tableView.rowHeight
    }
}
