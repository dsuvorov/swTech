//
//  ViewController.swift
//  swissTechTest
//
//  Created by Dmitry Suvorov on 13/05/17.
//  Copyright © 2017 ip-suvorov. All rights reserved.
//

import UIKit

class SWViewController: UINavigationController, SWFileListTableViewControllerDelegate {

    fileprivate var monitor: FolderMonitor! // монитор директории
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newVC = SWFileListTableViewController(nibName: "SWFileListTableViewController", bundle: nil)
        newVC.delegate = self
        self.pushViewController(newVC, animated: true);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func didChoose(path: URL) {
        self.startMonitor(path: path)
    }
    
    func startMonitor(path: URL) {
        let workItem = DispatchWorkItem {
            // создаем уведомление и отображаем пользователю
            let localNotification = UILocalNotification()
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 1) as Date
            localNotification.alertBody = "File has been added (updated) to directory: " + path.lastPathComponent
            localNotification.timeZone = NSTimeZone.default
            localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
        monitor = nil
        monitor = FolderMonitor(url: path, handler: workItem)
        print("Monitoring '\(path)'")
    }
}

