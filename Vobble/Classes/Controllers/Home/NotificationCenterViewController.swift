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

    }
    
    override func viewDidAppear(_ animated: Bool) {
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        //let notification =  DataStore.shared.notificationsCenter[indexPath.row]
        
        cell.selectionStyle = .none
        cell.lblDescription.text = "notification.text ?? notification.text ?? notification.text ?? notification.text ?? "
        cell.lblTitle.text = "notification.title ?? "
        cell.mainView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        if indexPath.row == 2 {
            cell.notificationImage.image = #imageLiteral(resourceName: "coins")
        }
        cell.backgroundColor = UIColor.clear
        
        return cell
    }

    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
