//
//  ListBookTblCell.swift
//  RigelPracticeTest
//
//  Created by Yuvraj limbani on 12/01/20.
//  Copyright © 2020 Vaib limbani. All rights reserved.
//

import UIKit

class ListBookTblCell: UITableViewCell {
    var cellDelegate: DownloadImageDelegate?

    @IBOutlet weak var bookImgView: UIImageView?
    @IBOutlet weak var lblBookName: UILabel?
    @IBOutlet weak var lblBookDescription: UILabel?
    @IBOutlet weak var btnDownload:UIButton?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func didDownloadButtonClick(_ sender:UIButton){
        if let img = bookImgView?.image {
        cellDelegate?.didInitiateDownloading(sender.tag, img)
        }
        else {
            print("Image downloading is in progress")
        }
    }
    
    
}
