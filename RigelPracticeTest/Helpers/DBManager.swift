//
//  DBManager.swift
//  RigelPracticeTest
//
//  Created by Yuvraj limbani on 13/01/20.
//  Copyright © 2020 Vaib limbani. All rights reserved.
//

import Foundation
let shared = DBManager()
class DBManager {
    var database:FMDatabase? = nil
    class func getSharedInstance() -> DBManager {
        if shared.database == nil {
            shared.database = FMDatabase(path: Utils.getPath("NotificationList.db"))
        }
        return shared
    }
    func saveData(modelInfo:NotificationModel) -> Bool {
        shared.database?.open()
        guard let isSaved = shared.database?.executeUpdate("INSERT INTO NotificationTable (notif_body,notif_text,notif_badge) VALUES (?,?,?)", withArgumentsIn: [modelInfo.notifBody,modelInfo.notifTitle,modelInfo.notifBadgeCount]) else { return false }
        shared.database?.close()
        return isSaved
    }
    func LoadNotificationList() -> [NotificationModel]! {
        var infos: [NotificationModel]!
        let query = "select * from NotificationTable"
        shared.database?.open()
        do {
            let results =  try! shared.database?.executeQuery(query, values: nil)
            while (results?.next())! {
                let model = NotificationModel(notifBody: (results?.string(forColumn: "notif_body"))!, notifTitle: (results?.string(forColumn: "notif_text"))!, notifBadgeCount:  Int(results!.int(forColumn:"notif_badge")))
                if infos == nil {
                    infos = [NotificationModel]()
                }
                infos.append(model)
            }
        }
        catch let err {
            print(err.localizedDescription)
        }
        shared.database?.close()
        // let info = NotificationModel(notifBody: "test", notifTitle: "test data", notifBadgeCount: 1)
        return infos
    }
    func deleteNotification(title:String) -> Bool {
        var deleted = false
        shared.database?.open()
        let query = "delete from NotificationTable where \(title)=?"
        do {
            try! shared.database?.executeStatements(query)
            deleted = true
        } catch let err {
            print(err.localizedDescription)
        }
        shared.database?.close()
       return deleted
    }
}
