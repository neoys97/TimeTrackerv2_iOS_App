//
//  EventModel.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 13/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation
import RealmSwift

class EventModel: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var startTime: Date? = nil
    @objc dynamic var endTime: Date? = nil
    @objc dynamic var clash = false
    
    var category: Event.Category {
        get {
            if categoryIndex == 0 {
                return (.routine)
            }
            else {
                return (.task)
            }
        }
        set {
            if newValue == .routine {
                categoryIndex = 0
            }
            else if newValue == .task {
                categoryIndex = 1
            }
        }
    }
    @objc dynamic var categoryIndex: Int = 1

    convenience init(_ title: String, from startTime: Date?, to endTime: Date?, _ cat: Event.Category) {
        self.init()
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.category = cat
    }
}
