//
//  DateCell.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 9/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar

class DateCell: JTACDayCell {
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var routineDotView: UIView!
    @IBOutlet weak var taskDotView: UIView!
}
