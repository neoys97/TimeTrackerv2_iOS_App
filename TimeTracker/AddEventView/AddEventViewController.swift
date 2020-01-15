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
    @IBOutlet weak var classTypeLabel: UILabel!
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
    var isDueEvent = false
    
    var eventTitle: String?
    var startDateTime: Date?
    var endDateTime: Date?
    var dueDate: Date?
    var classType: String = ""
    var hourDuration: Int = 0
    var minDuration: Int = 0
    var category: Event.Category = .task
    var suggestedTime: [Date?] = [nil, nil]
    var selectedClassIndex: Int? = nil

//    var listOfEvents: [Event] = []
    var eventList = EventList.sharedInstance
    
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
        isDueEvent = true
        dueDate = dueDatePicker.date
        dFormatter.dateFormat = "HH"
        let hour = dFormatter.string(from: durationPicker.date)
        hourDuration = Int(hour)!
        dFormatter.dateFormat = "mm"
        let min = dFormatter.string(from: durationPicker.date)
        minDuration = Int(min)!
//        var today = Date()
//        while today <= dueDate! {
//            suggestedTime = eventList.suggestTimeSlot(on: today, for: durationPicker.date)
//            if let suggestStart = suggestedTime[0], let suggestEnd = suggestedTime[1] {
//                datePicker.setDate(suggestStart, animated: false)
//                changeDateLabel(dateLabel, datePicker as Any, "dd-MMM-yyyy")
//                startDateTimePicker.setDate(suggestStart, animated: false)
//                changeDateLabel(startDateTimeLabel, startDateTimePicker as Any, "HH:mm")
//                endDateTimePicker.setDate(suggestEnd, animated: false)
//                changeDateLabel(endDateTimeLabel, endDateTimePicker as Any, "HH:mm")
//                let alert = UIAlertController(title: "Found", message: "Found suggested time for the task!", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true)
//                return
//            }
//            today = Calendar.current.date(byAdding: .day, value: 1, to: today)!
//        }
        suggestedTime = eventList.triggerSuggestion(due: dueDate, for: durationPicker.date)
        if let suggestStart = suggestedTime[0], let suggestEnd = suggestedTime[1] {
            datePicker.setDate(suggestStart, animated: false)
            changeDateLabel(dateLabel, datePicker as Any, "dd-MMM-yyyy")
            startDateTimePicker.setDate(suggestStart, animated: false)
            changeDateLabel(startDateTimeLabel, startDateTimePicker as Any, "HH:mm")
            endDateTimePicker.setDate(suggestEnd, animated: false)
            changeDateLabel(endDateTimeLabel, endDateTimePicker as Any, "HH:mm")
//            eventList.debug()
            if eventList.toBeAddedEvents.count != 0 {
                let alert = UIAlertController(title: "Found", message: "Found suggested time for the task with some tasks rescheduled!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            let alert = UIAlertController(title: "Found", message: "Found suggested time for the task!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
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
        
        if classType != "" {
            classTypeLabel.text = classType
        }
        
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
                if let index = selectedClassIndex {
                    classType = eventList.listOfClass[index]
                }
                if repeatSegmentedControl.selectedSegmentIndex == 0 {
                    if isDueEvent {
                        eventList.toBeAddedEvents.append(Event(title, from: startDateTime, to: endDateTime, category, classType, due: dueDate, hour: hourDuration, min: minDuration))
                    }
                    else {
                        eventList.toBeAddedEvents.append(Event(title, from: startDateTime, to: endDateTime, category, classType))
                    }
                }
                else if repeatSegmentedControl.selectedSegmentIndex == 1 {
                    while startDateTime! < oneMonthFromNow! {
                        if isDueEvent {
                            eventList.toBeAddedEvents.append(Event(title, from: startDateTime, to: endDateTime, category, classType, due: dueDate, hour: hourDuration, min: minDuration))
                        }
                        else {
                            eventList.toBeAddedEvents.append(Event(title, from: startDateTime, to: endDateTime, category, classType))
                        }
                        startDateTime = Calendar.current.date(byAdding: .day, value: 1, to: startDateTime!)
                        endDateTime = Calendar.current.date(byAdding: .day, value: 1, to: endDateTime!)
                    }
                }
                else if repeatSegmentedControl.selectedSegmentIndex == 2 {
                    while startDateTime! < oneMonthFromNow! {
                        if isDueEvent {
                            eventList.toBeAddedEvents.append(Event(title, from: startDateTime, to: endDateTime, category, classType, due: dueDate, hour: hourDuration, min: minDuration))
                        }
                        else {
                            eventList.toBeAddedEvents.append(Event(title, from: startDateTime, to: endDateTime, category, classType))
                        }
                        startDateTime = Calendar.current.date(byAdding: .day, value: 7, to: startDateTime!)
                        endDateTime = Calendar.current.date(byAdding: .day, value: 7, to: endDateTime!)
                    }
                }
            }
        }
        else if segue.identifier == "selectClassSegue" {
            let destination = segue.destination as! ClassTableViewController
            destination.listOfClass = eventList.listOfClass
        }
        else {
            editEvent = false
        }
    }
    
    @IBAction func returned(segue:UIStoryboardSegue) {
        let source = segue.source as! ClassTableViewController
        eventList.listOfClass = source.listOfClass
        if segue.identifier == "doneSelectClass" {
            selectedClassIndex = source.selectedClassIndex
            if let index = selectedClassIndex {
                classTypeLabel.text = eventList.listOfClass[index]
            }
        }
        self.tableView.reloadData()
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
        else if (indexPath.section == 3) {
            if indexPath.row != 0 {
                return (showSuggestionControl ? tableView.rowHeight : 0.0)
            }
        }
        
        return tableView.rowHeight
    }
}
