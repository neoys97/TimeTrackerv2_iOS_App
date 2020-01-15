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
    var copyOfEvents: [String:Array<Event>] = [:]
    var toBeDeletedEvents: [Event] = []
    var toBeAddedEvents: [Event] = []
    var listOfClass: [String] = []
    let dFormatter = DateFormatter()
    var wakeTime: String
    var sleepTime: String
    
    var classColors:[UIColor] = [UIColor(red: 255/255.0, green: 160/255.0, blue: 122/255.0, alpha: 1),
                            UIColor(red: 255/255.0, green: 192/255.0, blue: 203/255.0, alpha: 1),
                            UIColor(red: 173/255.0, green: 255/255.0, blue: 47/255.0, alpha: 1),
                            UIColor(red: 0/255.0, green: 255/255.0, blue: 127/255.0, alpha: 1),
                            UIColor(red: 255/255.0, green: 228/255.0, blue: 181/255.0, alpha: 1),
                            UIColor(red: 255/255.0, green: 235/255.0, blue: 205/255.0, alpha: 1),
                            UIColor(red: 176/255.0, green: 224/255.0, blue: 230/255.0, alpha: 1),
                            UIColor(red: 123/255.0, green: 104/255.0, blue: 238/255.0, alpha: 1),
                            UIColor(red: 0/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1),
                            UIColor(red: 100/255.0, green: 149/255.0, blue: 237/255.0, alpha: 1)]
    
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
    
    func addEvent (_ event: Event, toCopyOfEvents copy: Bool = false) {
        
        dFormatter.dateFormat="dd-MMM-yyyy"
        if !copy {
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
        else {
            if !listOfClass.contains(event.classType) && event.classType != "" {
                listOfClass.append(event.classType)
            }
            if let date = event.startTime {
                let dateString = dFormatter.string(from: date)
                if copyOfEvents[dateString] != nil {
                    copyOfEvents[dateString]!.append(event)
                    copyOfEvents[dateString]!.sort()
                    clashCheck(copyOfEvents[dateString]!)
                }
                else {
                    copyOfEvents[dateString] = [event]
                }
            }
        }
        dFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
    }
    
    func delToBeDeletedEvents () {
        for event in toBeDeletedEvents {
            delEvent(event)
        }
        toBeDeletedEvents.removeAll()
    }
    
    func delEvent (_ event: Event, fromCopyOfEvents copy: Bool = false) {
        dFormatter.dateFormat="dd-MMM-yyyy"
        if !copy {
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
        else {
            if let date = event.startTime {
                let dateString = dFormatter.string(from: date)
                if copyOfEvents[dateString] != nil {
                    if let index = copyOfEvents[dateString]?.firstIndex(of: event) {
                        copyOfEvents[dateString]?.remove(at: index)
                        copyOfEvents[dateString]!.sort()
                        clashCheck(copyOfEvents[dateString]!)
                    }
                    if copyOfEvents[dateString]?.count == 0 {
                        copyOfEvents[dateString] = nil
                    }
                }
            }
        }
        
        dFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
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
    
    func triggerSuggestion (due dueDate: Date?, for duration: Date?) -> [Date?]{
        copyOfEvents.removeAll()
        for (key, value) in events {
            copyOfEvents[key] = []
            for e in value {
                copyOfEvents[key]!.append(e.copy() as! Event)
            }
        }
        
        toBeAddedEvents.removeAll()
        toBeDeletedEvents.removeAll()
        var clashedEvents: [Event] = []
        dFormatter.dateFormat = "HH"
        let hour = Int(dFormatter.string(from: duration!))!
        dFormatter.dateFormat = "mm"
        let min = Int(dFormatter.string(from: duration!))!
        let suggestedTime: [Date?] = iterateSuggestTimeSlot(due: dueDate!, hour: hour, min: min)
        if let start = suggestedTime[0], let end = suggestedTime[1] {
            let tempEvent = Event("Temporary", from: start, to: end, .task, "", due: dueDate, hour: hour, min: min)
            dFormatter.dateFormat = "dd-MMM-yyyy"
            let dateString = dFormatter.string(from: start)
            if copyOfEvents[dateString] != nil {
                if copyOfEvents[dateString]!.count > 0 {
                    for e in copyOfEvents[dateString]! {
                        if e.category == .task {
                            if e.startTime! < tempEvent.endTime! && e.endTime! > tempEvent.startTime! {
                                clashedEvents.append(e)
                                delEvent(e, fromCopyOfEvents: true)
                            }
                        }
                    }
                }
            }
            addEvent(tempEvent, toCopyOfEvents: true)
        }
        else {
            return [nil, nil]
        }
        
        if clashedEvents.count == 0 {
            return suggestedTime
        }
        
        
        while clashedEvents.count != 0 {
            clashedEvents = clashedEvents.sorted { (lhs, rhs) -> Bool in
                lhs.dueDate! < rhs.dueDate!
            }
            var clashEvent = clashedEvents[0]
            toBeDeletedEvents.append(clashEvent.copy() as! Event)
            clashedEvents.removeFirst()
            let clashSuggestedTime = iterateSuggestTimeSlot(due: clashEvent.dueDate!, hour: clashEvent.hourDuration, min: clashEvent.minDuration)
            if let start = clashSuggestedTime[0], let end = clashSuggestedTime[1] {
                if start > Calendar.current.date(byAdding: .day, value: 7, to: Date())! {
                    toBeDeletedEvents.removeAll()
                    toBeAddedEvents.removeAll()
                    return [nil, nil]
                }
                clashEvent = Event(clashEvent.title, from: start, to: end, clashEvent.category, clashEvent.classType, due: clashEvent.dueDate, hour: clashEvent.hourDuration, min: clashEvent.minDuration)
                dFormatter.dateFormat = "dd-MMM-yyyy"
                let dateString = dFormatter.string(from: start)
                if copyOfEvents[dateString] != nil {
                    if copyOfEvents[dateString]!.count > 0 {
                        for e in copyOfEvents[dateString]! {
                            if e.category == .task {
                                if e.dueDate != nil {
                                    if e.startTime! < clashEvent.endTime! && e.endTime! > clashEvent.startTime! {
                                        clashedEvents.append(e)
                                        delEvent(e, fromCopyOfEvents: true)
                                    }
                                }
                            }
                        }
                    }
                }
                addEvent(clashEvent, toCopyOfEvents: true)
                toBeAddedEvents.append(clashEvent)
            }
            else {
                toBeDeletedEvents.removeAll()
                toBeAddedEvents.removeAll()
                return [nil, nil]
            }
        }
        return suggestedTime
    }
    
    func iterateSuggestTimeSlot (due dueDate: Date, hour hourDuration: Int, min minuteDuration: Int) -> [Date?]{
        var suggestedTime: [Date?] = [nil, nil]
        var today = Date()
        
        while today <= dueDate {
            suggestedTime = suggestTimeSlot(on: today, due: dueDate, hour: hourDuration, min: minuteDuration)
            if let _ = suggestedTime[0], let _ = suggestedTime[1] {
                return suggestedTime
            }
            today = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        }
        return suggestedTime
    }
    
    func suggestTimeSlot (on date: Date?, from wake: Date? = nil, to sleep: Date? = nil, due dueDate: Date, hour hourDuration: Int, min minuteDuration: Int) -> [Date?]{
        dFormatter.dateFormat = "HH:mm"
        
        if let w = wake, let s = sleep {
            wakeTime = dFormatter.string(from: w)
            sleepTime = dFormatter.string(from: s)
        }
        dFormatter.dateFormat = "dd-MMM-yyyy"
        let dateString = dFormatter.string(from: date!)
        
        dFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
        let temp = dFormatter.date(from: dateString + " " + wakeTime)
        var start: Date? = temp
        if Calendar.current.isDateInToday(date!) {
            start = Date() < temp! ? temp : Date()
        }
        
        let end = dFormatter.date(from: dateString + " " + sleepTime)
//        dFormatter.dateFormat = "HH"
        let hour = hourDuration
//        dFormatter.dateFormat = "mm"
        let min = minuteDuration
        
        var suggestedTime: [Date?] = [start, end]
        
        if copyOfEvents[dateString] == nil {
            suggestedTime[1] = Calendar.current.date(byAdding: .hour, value: hour, to: start!)
            suggestedTime[1] = Calendar.current.date(byAdding: .minute, value: min, to: suggestedTime[1]!)
        }
        else {
            var targetEvents: [Event] = []
            for e in copyOfEvents[dateString]! {
                if let due = e.dueDate {
                    if due >= dueDate {
                        continue
                    }
                }
                targetEvents.append(e)
            }
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
    
    func devLoadData() {
        dFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
        addEvent(Event("Photosynthesis", from: dFormatter.date(from: "15-Jan-2020 15:30"), to: dFormatter.date(from: "15-Jan-2020 17:30"), .task, "Biology", due: dFormatter.date(from: "24-Jan-2020 00:00"), hour: 2, min: 0))
        addEvent(Event("Hydrogen", from: dFormatter.date(from: "15-Jan-2020 21:00"), to: dFormatter.date(from: "15-Jan-2020 22:00"), .task, "Chemistry", due: dFormatter.date(from: "22-Jan-2020 00:00"), hour: 1, min: 0))
        addEvent(Event("Momentum", from: dFormatter.date(from: "16-Jan-2020 16:00"), to: dFormatter.date(from: "16-Jan-2020 17:30"), .task, "Physics", due: dFormatter.date(from: "26-Jan-2020 00:00"), hour: 1, min: 30))
        addEvent(Event("Calculus", from: dFormatter.date(from: "16-Jan-2020 21:00"), to: dFormatter.date(from: "16-Jan-2020 22:00"), .task, "Mathematics", due: dFormatter.date(from: "28-Jan-2020 00:00"), hour: 1, min: 0))
        
        addEvent(Event("Routine 1", from: dFormatter.date(from: "15-Jan-2020 07:30"), to: dFormatter.date(from: "15-Jan-2020 15:30"), .routine, ""))
        addEvent(Event("Routine 2", from: dFormatter.date(from: "15-Jan-2020 17:30"), to: dFormatter.date(from: "15-Jan-2020 20:30"), .routine, ""))
        addEvent(Event("Routine 3", from: dFormatter.date(from: "15-Jan-2020 22:30"), to: dFormatter.date(from: "15-Jan-2020 23:00"), .routine, ""))
        addEvent(Event("Routine 4", from: dFormatter.date(from: "16-Jan-2020 07:30"), to: dFormatter.date(from: "16-Jan-2020 15:30"), .routine, ""))
        addEvent(Event("Routine 5", from: dFormatter.date(from: "16-Jan-2020 17:30"), to: dFormatter.date(from: "16-Jan-2020 20:00"), .routine, ""))
        addEvent(Event("Routine 6", from: dFormatter.date(from: "16-Jan-2020 22:30"), to: dFormatter.date(from: "16-Jan-2020 23:00"), .routine, ""))
    }
    
    func debug() {
        dFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
        for e in toBeAddedEvents {
            print ("title \(e.title)")
            print ("start \(dFormatter.string(from: e.startTime!))")
            print ("start \(dFormatter.string(from: e.endTime!))")
            print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        }
        print ("####################################")
        for e in toBeDeletedEvents {
            print ("title \(e.title)")
            print ("start \(dFormatter.string(from: e.startTime!))")
            print ("start \(dFormatter.string(from: e.endTime!))")
            print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        }
    }
}
