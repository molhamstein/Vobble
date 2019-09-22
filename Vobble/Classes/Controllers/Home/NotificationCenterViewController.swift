//
//  NotificationCenterViewController.swift
//  Vobble
//
//  Created by Abdulrahman Alhayek on 9/15/19.
//  Copyright © 2019 Brain-Socket. All rights reserved.
//

import UIKit

class NotificationCenterViewController: AbstractController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")

        
        seenNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataStore.shared.notificationsCenter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        let notification =  DataStore.shared.notificationsCenter[indexPath.row]
        
        cell.configureCell(notification, tableView: tableView)
        
        return cell
    }

    
    func seenNotifications() {
        let unSeenNotifications = (DataStore.shared.notificationsCenter.map { $0.notificationId ?? ""})
        
        ApiManager.shared.seenNotifications(ids: unSeenNotifications, completionBlock: {isSuccess, error in
            let _ = DataStore.shared.notificationsCenter.map {$0.isSeen = true}
            
            print(DataStore.shared.notificationsCenter.map {$0.dictionaryRepresentation()})
            NotificationCenter.default.post(name: Notification.Name("ObserveNotificationCenter"), object: nil)
        })
    }

    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
