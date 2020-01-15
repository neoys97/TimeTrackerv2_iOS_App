//
//  Event.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 9/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation

class Event {
    var title: String = ""
    var startTime: Date? = nil
    var endTime: Date? = nil
    var clash = false
    var dueDate: Date? = nil
    var hourDuration: Int = 0
    var minDuration: Int = 0
    enum Category {
        case routine
        case task
    }
    var category: Category = .task
    var classType: String = ""
    
    convenience init(_ title: String, from startTime: Date?, to endTime: Date?, _ cat: Category, _ classType: String) {
        self.init()
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.classType = classType
        self.category = cat
    }
    
    convenience init(_ title: String, from startTime: Date?, to endTime: Date?, _ cat: Category, _ classType: String, due dueDate: Date?, hour hourDuration: Int, min minDuration: Int) {
        self.init()
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.classType = classType
        self.category = cat
        self.dueDate = dueDate
        self.hourDuration = hourDuration
        self.minDuration = minDuration
    }
}

extension Event: Comparable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return (lhs.title == rhs.title &&
            lhs.startTime == rhs.startTime &&
            lhs.endTime == rhs.endTime &&
            lhs.category == rhs.category)
    }
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        if Calendar.current.isDate(lhs.startTime!, equalTo: rhs.startTime!, toGranularity: .minute) {
            return (lhs.endTime! < rhs.endTime!)
        }
        else {
            return (lhs.startTime! < rhs.startTime!)
        }
    }
}

extension Event: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Event(title, from: startTime, to: endTime, category, classType, due: dueDate, hour: hourDuration, min: minDuration)
        return copy
    }
}
