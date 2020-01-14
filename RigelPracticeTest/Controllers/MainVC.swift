//
//  MainVC.swift
//  RigelPracticeTest
//
//  Created by Yuvraj limbani on 11/01/20.
//  Copyright © 2020 Vaib limbani. All rights reserved.
//

import UIKit
let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

class MainVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didMapButtonClick(_ sender:UIButton){
        let mapVC = storyBoard.instantiateViewController(withIdentifier: "MapFunctionsVC") as! MapFunctionsVC
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    @IBAction func didNotificationButtonClick(_ sender:UIButton){
        let mapVC = storyBoard.instantiateViewController(withIdentifier: "NotificationsListVC") as! NotificationsListVC
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    @IBAction func didListingButtonClick(_ sender:UIButton){
        let mapVC = storyBoard.instantiateViewController(withIdentifier: "ListingVC") as! ListingVC
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    
}
