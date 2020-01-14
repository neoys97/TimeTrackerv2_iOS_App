//
//  EventList.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 13/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation
import RealmSwift

class EventList {
    static let sharedInstance = EventList()
    
    var events: [String:Array<Event>] = [:]
    var toBeDeletedEvents: [Event] = []
    var toBeAddedEvents: [Event] = []
    var listOfClass: [String] = []
    let dFormatter = DateFormatter()
    var wakeTime: String
    var sleepTime: String
    
    init() {
        wakeTime = "07:00"
        sleepTime = "23:00"
    }
    
    func addToBeAddedEvent () {
        for event in toBeAddedEvents {
            addEvent(event)
        }
        toBeAddedEvents.removeAll()
    }
    
    func addEvent (_ event: Event) {
        dFormatter.dateFormat="dd-MMM-yyyy"
        if !listOfClass.contains(event.classType) && event.classType != "" {
            listOfClass.append(event.classType)
        }
        if let date = event.startTime {
            let dateString = dFormatter.string(from: date)
            if events[dateString] != nil {
                events[dateString]!.append(event)
                events[dateString]!.sort()
                clashCheck(events[dateString]!)
            }
            else {
                events[dateString] = [event]
            }
        }
    }
    
    func delToBeDeletedEvents () {
        for event in toBeDeletedEvents {
            delEvent(event)
        }
        toBeDeletedEvents.removeAll()
    }
    
    func delEvent (_ event: Event) {
        dFormatter.dateFormat="dd-MMM-yyyy"
        if let date = event.startTime {
            let dateString = dFormatter.string(from: date)
            if events[dateString] != nil {
                if let index = events[dateString]?.firstIndex(of: event) {
                    events[dateString]?.remove(at: index)
                    events[dateString]!.sort()
                    clashCheck(events[dateString]!)
                }
                if events[dateString]?.count == 0 {
                    events[dateString] = nil
                }
            }
        }
    }
    
    func clashCheck (_ events: [Event]) {
        dFormatter.dateFormat="dd-MMM-yyyy"
        if events.count == 0 {
            return
        }
        if events.count == 1 {
            events[0].clash = false
            return
        }
        events[0].clash = false
        var endDateTime = events[0].endTime!
        
        for i in 1..<events.count {
            if events[i].startTime! < endDateTime {
                events[i-1].clash = true
                events[i].clash = true
            }
            else {
                events[i].clash = false
            }
            endDateTime = endDateTime < events[i].endTime! ? events[i].endTime! : endDateTime
        }
    }
    
    func suggestTimeSlot (on date: Date?, from wake: Date? = nil, to sleep: Date? = nil, for duration: Date?) -> [Date?]{
        dFormatter.dateFormat = "HH:mm"
        
        if let w = wake, let s = sleep {
            wakeTime = dFormatter.string(from: w)
            sleepTime = dFormatter.string(from: s)
        }
        dFormatter.dateFormat = "dd-MMM-yyyy"
        let dateString = dFormatter.string(from: date!)
        
        print (dateString)
        
        dFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
        let temp = dFormatter.date(from: dateString + " " + wakeTime)
        var start: Date? = temp
        if Calendar.current.isDateInToday(date!) {
            start = Date() < temp! ? temp : Date()
        }
        
        let end = dFormatter.date(from: dateString + " " + sleepTime)
        dFormatter.dateFormat = "HH"
        let hour = Int(dFormatter.string(from: duration!))!
        dFormatter.dateFormat = "mm"
        let min = Int(dFormatter.string(from: duration!))!
        
        var suggestedTime: [Date?] = [start, end]
        
        if events[dateString] == nil {
            suggestedTime[1] = Calendar.current.date(byAdding: .hour, value: hour, to: start!)
            suggestedTime[1] = Calendar.current.date(byAdding: .minute, value: min, to: suggestedTime[1]!)
        }
        else {
            var targetEvents = events[dateString]!
            targetEvents.sort()
            suggestedTime = findTime(start: start!, end: targetEvents[0].startTime!, hour: hour, min: min)
            var temp: Date?
            if suggestedTime[0] == nil {
                for i in 1..<targetEvents.count {
                    temp = targetEvents[i - 1].endTime! > start! ? targetEvents[i - 1].endTime! : start!
                    suggestedTime = findTime(start: temp!, end: targetEvents[i].startTime!, hour: hour, min: min)
                    if suggestedTime[0] != nil {
                        break
                    }
                }
            }
            if suggestedTime[0] == nil {
                temp = targetEvents[targetEvents.count - 1].endTime! > start! ? targetEvents[targetEvents.count - 1].endTime! : start!
                dFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
                print (dFormatter.string(from: temp!))
                print (dFormatter.string(from: end!))
                suggestedTime = findTime(start: temp!, end: end!, hour: hour, min: min)
            }
        }

        return (suggestedTime)
    }
    
    func findTime (start: Date, end: Date, hour: Int, min: Int) -> [Date?] {
        var suggestedEndTime = end
        if end > start {
            suggestedEndTime = Calendar.current.date(byAdding: .hour, value: hour, to: start)!
            suggestedEndTime = Calendar.current.date(byAdding: .minute, value: min, to: suggestedEndTime)!
            if suggestedEndTime <= end {
                return [start, suggestedEndTime]
            }
        }
        return [nil, nil]
    }
    
    func loadData () {
        dFormatter.dateFormat="dd-MMM-yyyy"
        
        let realm = try! Realm()
        let tempEvents = realm.objects(EventModel.self)
        for eventModel in tempEvents {
            let event = Event(eventModel.title, from: eventModel.startTime, to: eventModel.endTime, eventModel.category, eventModel.classType, due: eventModel.dueDate, hour: eventModel.hourDuration, min: eventModel.minDuration)
            if !listOfClass.contains(event.classType) && event.classType != "" {
                       listOfClass.append(event.classType)
                   }
            if let date = event.startTime {
                let dateString = dFormatter.string(from: date)
                if events[dateString] != nil {
                    events[dateString]!.append(event)
                }
                else {
                    events[dateString] = [event]
                }
            }
        }

        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func saveData () {
        let realm = try! Realm()
        realm.beginWrite()
        
        for (_, listOfEvents) in self.events {
            for e in listOfEvents {
                realm.add(EventModel(e.title, from: e.startTime, to: e.endTime, e.category, e.classType, due: e.dueDate, hour: e.hourDuration, min: e.minDuration))
            }
        }
        try! realm.commitWrite()
    }
}
