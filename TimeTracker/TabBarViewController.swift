//
//  TabBarViewController.swift
//  TimeTracker
//
//  Created by Neo Yi Siang on 15/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = tabBarController.selectedIndex
        if index == 1 {
            let nvc = viewController as! UINavigationController
            let hvc = nvc.topViewController as! HomeworkTableViewController
            hvc.reloadView()
        }
    }
    

}
