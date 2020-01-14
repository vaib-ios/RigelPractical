//
//  NotificationsListVC.swift
//  RigelPracticeTest
//
//  Created by Yuvraj limbani on 11/01/20.
//  Copyright © 2020 Vaib limbani. All rights reserved.
//

import UIKit

class NotificationsListVC: UIViewController {
    @IBOutlet weak var tblNotifList:UITableView!
    var notifListArray = [NotificationModel]()
    let nc = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notification"
        if DBManager.getSharedInstance().LoadNotificationList() != nil {
        notifListArray = DBManager.getSharedInstance().LoadNotificationList()
            tblNotifList.reloadData()
        }
         nc.addObserver(self, selector: #selector(reloadNotificationList), name: Notification.Name("UpdateTable"), object: nil)
       
        // Do any additional setup after loading the view.
    }
    
   @objc func reloadNotificationList(){
            notifListArray = DBManager.getSharedInstance().LoadNotificationList()
               if notifListArray.count > 0 {
                   tblNotifList.reloadData()
               }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension NotificationsListVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationcell", for: indexPath)
        let info = notifListArray[indexPath.row]
        cell.textLabel?.text = info.notifBody
        cell.detailTextLabel?.text = info.notifTitle
        return cell
    }
    
    
}
