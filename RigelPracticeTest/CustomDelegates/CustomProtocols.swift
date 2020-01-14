//
//  CustomProtocols.swift
//  RigelPracticeTest
//
//  Created by Yuvraj limbani on 12/01/20.
//  Copyright © 2020 Vaib limbani. All rights reserved.
//

import Foundation
import UIKit
protocol DownloadImageDelegate {
    func didInitiateDownloading(_ tag:Int,_ image: UIImage)
    func didFailWithError(_ err:Error)
}
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
