//
//  ListingVC.swift
//  RigelPracticeTest
//
//  Created by Yuvraj limbani on 11/01/20.
//  Copyright © 2020 Vaib limbani. All rights reserved.
//

import UIKit
import SDWebImage
import ImageViewer_swift
import ImageSlideshow
import AlamofireImage
import Photos


class ListingVC: UIViewController {
    var listArray = [[String:Any]]()
    var booksArray = [BooksModel]()
    @IBOutlet weak var tblBookList:UITableView!
    let listbook = UINib(nibName: "ListBookTblCell", bundle: nil)
    
    var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate? = nil
    
    var alamofireSource = [AlamofireSource]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Listing"
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        setupTable()
       
        
    }
    func setupTable(){
        tblBookList.register(listbook, forCellReuseIdentifier: "ListBookTblCell")
        tblBookList.rowHeight = UITableView.automaticDimension
        tblBookList.estimatedRowHeight = 600
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadArrays()
        toLoadListing()
    }
    func reloadArrays(){
        alamofireSource = [AlamofireSource]()
        booksArray = [BooksModel]()
    }
    func toLoadListing(){
        if let path = Bundle.main.path(forResource: "Listing", ofType: "json")
        {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String:Any] {
                    // do stuff
                    print(jsonResult)
                    if let jsonArr = jsonResult["Data"] as? [[String:Any]]  {
                        // jsonArray = jsonArr
                        print(jsonArr)
                        listArray = jsonArr
                        for inf in listArray {
                            //fill json model
                            let model = BooksModel.init(id: inf["id"] as! Int, title: inf["title"] as! String, description: inf["description"] as! String, smallThumbnail: inf["smallThumbnail"] as! String, thumbnail: inf["thumbnail"] as! String)
                            booksArray.append(model)
                            
                        }
                        print(listArray)
                        //load image array
                        for info in listArray {
                            if let bookThumbnailUrl = info["thumbnail"] as? String {
                                let src = AlamofireSource(urlString: bookThumbnailUrl)
                                alamofireSource.append(src!)
                            }
                        }
                        tblBookList.reloadData()
                    }
                }
            } catch let err  {
                // handle error
                print(err.localizedDescription)
            }
        }
    }
    

    func checkPhotoLibraryPermissionWith(img :UIImage) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //handle authorized status
            self.downloadAction(image: img)
            
        case .denied, .restricted :
            self.presentCameraSettings()
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    self.downloadAction(image: img)
                case .denied, .restricted:
                    self.presentCameraSettings()
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization({ (newStatus) in
                        
                        if (newStatus == PHAuthorizationStatus.authorized) {
                            self.downloadAction(image: img)
                        }
                            
                        else {
                            self.presentCameraSettings()
                        }
                    })
                    // won't happen but still
                @unknown default:
                    fatalError()
                }
            }
        @unknown default:
            fatalError()
        }
    }
    
    func presentCameraSettings() {
        
        
        let alert = UIAlertController(title: "RigelTest", message: "Photo library permission is denied, Couldn't save photo.", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Open Settings", style: .destructive) { (action) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            
        }
        
        let canAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(okAction)
        alert.addAction(canAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)}
    }
    
}
extension ListingVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListBookTblCell", for: indexPath) as! ListBookTblCell
        let obj = booksArray[indexPath.row]
        cell.lblBookName?.text = obj.title
        
        cell.lblBookDescription?.text = obj.description
        cell.bookImgView!.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
        cell.bookImgView?.sd_setImage(with: URL(string:obj.smallThumbnail), placeholderImage: nil)
        
        cell.cellDelegate = self
        cell.btnDownload?.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let fullScreenController = FullScreenSlideshowViewController()
        fullScreenController.inputs = alamofireSource
        fullScreenController.initialPage = indexPath.row
        if let cell = tableView.cellForRow(at: indexPath), let imageView = cell.imageView {
            slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(imageView: imageView, slideshowController: fullScreenController)
            fullScreenController.transitioningDelegate = slideshowTransitioningDelegate
        }
        
        fullScreenController.slideshow.currentPageChanged = { [weak self] page in
            if let cell = tableView.cellForRow(at: IndexPath(row: page, section: 0)), let imageView = cell.imageView {
                self?.slideshowTransitioningDelegate?.referenceImageView = imageView
            }
        }
        
        present(fullScreenController, animated: true, completion: nil)
        
    }
    
    
    //MARK: Download photo to Photo Library
    func downloadAction(image:UIImage){
        DispatchQueue.main.async {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
       
        
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "There was an error downloading your image", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Photo Saved!", message: "This book image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
extension ListingVC:DownloadImageDelegate {
    
    
    func didInitiateDownloading(_ tag: Int, _ image: UIImage) {
        
        
        //download/ save image to image gallery operation
        //fetch object here
        checkPhotoLibraryPermissionWith(img: image)
        
    }
    
    func didFailWithError(_ err: Error) {
        print(err.localizedDescription)
    }
    
    
}

