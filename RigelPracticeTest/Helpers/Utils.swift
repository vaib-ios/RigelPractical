//
//  Utils.swift
//  RigelPracticeTest
//
//  Created by Yuvraj limbani on 12/01/20.
//  Copyright © 2020 Vaib limbani. All rights reserved.
//

import Foundation
class Utils:NSObject{
    class func getPath(_ filename:String) -> String {
        let docDirect = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = docDirect.appendingPathComponent(filename)
        print("My Db Path is : - \(fileUrl.path)")
        return fileUrl.path
    }
    class func copyDataBase(_ filename:String){
        let dbPath = getPath("NotificationList.db")
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: dbPath){
            let bundle = Bundle.main.resourceURL
            let file = bundle?.appendingPathComponent(filename)
            var error :NSError?
        
            
            do {
                try! fileManager.copyItem(atPath: file!.path, toPath: dbPath)
            }
            catch let err as NSError {
                print(err)
                error = err
            }
            
            if error != nil {
                print("Found error in db")
            }
            else{
                print("Good to go!")
            }
        }
    }
}
