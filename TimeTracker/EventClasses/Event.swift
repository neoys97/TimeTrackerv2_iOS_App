//
//  Event.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 9/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation
import RealmSwift

class Event: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var startTime: Date? = nil
    @objc dynamic var endTime: Date? = nil
    @objc dynamic var clash = false
    enum Category {
        case routine
        case task
    }
    var category: Category = .task
    
    convenience init(_ title: String, from startTime: Date?, to endTime: Date?, _ cat: Category) {
        self.init()
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.category = cat
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
