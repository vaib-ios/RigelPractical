//
//  LocationUpdater.swift
//  TestLocationService
//
//  Created by Yuvraj limbani on 30/09/19.
//  Copyright © 2019 Vaib limbani. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
protocol LocationUpdaterDelegate {
    func didCatchLocationData(location:CLLocation)
    func didCatchErrorOfLocationData(error:Error)
    func changedPermissionOptions()
    func didGetAddressString(address:String)
}
class LocationUpdater: NSObject {
    
    static let shared = LocationUpdater()
    
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var Locationdelegate: LocationUpdaterDelegate?
    let status =  CLLocationManager.authorizationStatus()
    
    private override init() {
        super.init()
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
       
        switch status {
        // 1
        case .notDetermined:
           
            if CLLocationManager.authorizationStatus() == .notDetermined {
                // you have 2 choice
                // 1. requestAlwaysAuthorization
                // 2. requestWhenInUseAuthorization
                locationManager.requestAlwaysAuthorization()
            }
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
            locationManager.distanceFilter = 200
            locationManager.startUpdatingLocation()
            
            return
            
        // 2
        case .denied, .restricted:
             locationManager.delegate = self
            print("restricted by user")
            guard let delegate = self.Locationdelegate else {
                return
            }
             delegate.changedPermissionOptions()
            return
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            break
            
        @unknown default:
            print("something unknow happned!")
        }
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
}
extension LocationUpdater:CLLocationManagerDelegate {
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last location
        self.lastLocation = location
        
        // use for real time update location
        updateLocation(currentLocation: location)
        let gecocoder = CLGeocoder()
        gecocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            if let placemark = placemarks as? [CLPlacemark] {
            if placemark.count>0{
                let placemark = placemarks![0]
                print(placemark.locality!)
                print(placemark.administrativeArea!)
                print(placemark.country!)
            
                let address = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
                self.Locationdelegate?.didGetAddressString(address: address)
            }
        }
        if locations.count != 0 {
            self.stopUpdatingLocation()
            }
            
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            // showLocationDisabledPopUp()
            // to show popup to re-redirect user to settings page
            /* */
            guard let delegate = self.Locationdelegate else {
                return
            }
            stopUpdatingLocation()
            delegate.changedPermissionOptions()
            
        }
        if (status == CLAuthorizationStatus.notDetermined || status == CLAuthorizationStatus.authorizedWhenInUse) {
            if Locationdelegate != nil {
                locationManager!.delegate = self
            }
            startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // do on error
        stopUpdatingLocation()
        updateLocationDidFailWithError(error: error as NSError)
        
    }
    
    // Private function
    private func updateLocation(currentLocation: CLLocation){
        
        guard let delegate = self.Locationdelegate else {
            return
        }
        
        delegate.didCatchLocationData(location:currentLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.Locationdelegate else {
            return
        }
        
        delegate.didCatchErrorOfLocationData(error:error)
    }
}
