//
//  MapFunctionsVC.swift
//  RigelPracticeTest
//
//  Created by Yuvraj limbani on 11/01/20.
//  Copyright © 2020 Vaib limbani. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SVProgressHUD

class MapFunctionsVC: UIViewController {
    @IBOutlet var mapView: GMSMapView!
    var latt = String()
    var long = String()
    var userCurrentLocation = CLLocationCoordinate2D()
    var userDestinationLoction = CLLocationCoordinate2D()
    @IBOutlet weak var txtLocation:UITextField!
    var locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startGettingLocations()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        placesClient = GMSPlacesClient.shared()
        txtLocation.addTarget(self, action: #selector(autocompleteClicked), for: .editingDidBegin)
    }
    @objc func autocompleteClicked(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    func startGettingLocations(){
        LocationUpdater.shared.Locationdelegate = self
        if LocationUpdater.shared.status != .denied   {
            LocationUpdater.shared.startUpdatingLocation()
        }
    }
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        
        let session = URLSession.shared
        
        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) else { print("error in JSONSerialization")
                return
            }
            guard let jsonResponse = jsonResult as? [String:Any] else{return}
            
            guard let routes = jsonResponse["routes"] as? [Any] else {
                return
            }
            
            guard let route = routes[0] as? [String: Any] else {
                return
            }
            
            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }
            
            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }
            //Call this method to draw path on map
            self.drawPath(from: polyLineString)
        })
        task.resume()
    }
    func drawPath(from polyStr: String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.map = nil;
        polyline.strokeWidth = 3.0
        polyline.map = mapView // Google MapView
    }
}
extension MapFunctionsVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //print("Place name: \(place.name!)")
        // print("Place ID: \(place.placeID!)")
        //  print("Place attributions: \(place.attributions!)")
        latt = "\(place.coordinate.latitude)"
        long = "\(place.coordinate.longitude)"
        guard let address = place.formattedAddress else {return}
        userDestinationLoction = place.coordinate
        txtLocation.text = address
        
        
        dismiss(animated: true, completion: {
            //self.toCallApiTogetListOfPrayerRequestByLocation(radius: kSelectedMiles, lat: self.latt, long: self.long)
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            marker.title = place.name
            marker.snippet = address
            marker.map = self.mapView
            self.todrawARoutebetweenTwoLocations(from: self.userCurrentLocation, to: self.userDestinationLoction)
        })
    }
    func todrawARoutebetweenTwoLocations(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        let session = URLSession.shared
        //AIzaSyDN-Zk_6Mzt-EaSOSXGWITqXwFKIDqLRqY
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=AIzaSyDN-Zk_6Mzt-EaSOSXGWITqXwFKIDqLRqY")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) else { print("error in JSONSerialization")
                return
            }
            guard let jsonResponse = jsonResult as? [String:Any] else{return}
            
            guard let routes = jsonResponse["routes"] as? [Any] else {
                return
            }
            
            guard let route = routes[0] as? [String: Any] else {
                return
            }
            
            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }
            
            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }
            
            //Call this method to draw path on map
            DispatchQueue.main.async {
                self.drawPath(from: polyLineString)
                
            }
        })
        task.resume()
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
extension MapFunctionsVC:LocationUpdaterDelegate {
    func changedPermissionOptions() {
        let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            
        }
        
        let canAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(okAction)
        alert.addAction(canAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func didCatchErrorOfLocationData(error: Error) {
        print(error.localizedDescription)
    }
    
    func didCatchLocationData(location: CLLocation) {
        print(location.coordinate.latitude)
        print(location.coordinate.longitude)
        //latt = "\(location.coordinate.latitude)"
        //long = "\(location.coordinate.longitude)"
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 15.0)
        userCurrentLocation = location.coordinate
        // mapView = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        //  view.addSubview(mapView)
        mapView.isHidden = true
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.title = "My Location"
        // marker.icon = #imageLiteral(resourceName: "currentlocation")
        marker.map = mapView
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        latt = "\(location.coordinate.latitude)"
        long = "\(location.coordinate.longitude)"
        LocationUpdater.shared.stopUpdatingLocation()
    }

    func didGetAddressString(address: String) {
        print(address)
    }
    
    
}
