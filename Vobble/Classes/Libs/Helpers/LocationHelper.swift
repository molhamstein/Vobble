//
//  LocationHelper.swift
//  BrainSocket Code base
//
//  Created by BrainSocket on 6/11/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import CoreLocation

// MARK: Default location >> UAE Capital Coordinates
enum DefaultLocation {
    static let latitude = 24.4539
    static let longitude = 54.3773
}

//MARK: Current location stuff
class LocationHelper : NSObject,CLLocationManagerDelegate
{
    // singelton
    public static let shared:LocationHelper = LocationHelper()
    
    private override init() {
        super.init()
    }
    
    // MARK: location stuff
    var locationManager = CLLocationManager()
    var myLocation = Location(lat:DefaultLocation.latitude, long:DefaultLocation.longitude) {
        didSet {
            NotificationCenter.default.post(name: .notificationLocationChanged, object: nil)
        }
    }
    
    func startUpdateLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 500
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let lat : Double = Double(userLocation.coordinate.latitude)
        let long : Double = Double(userLocation.coordinate.longitude)
        myLocation = Location(lat:lat, long:long)
        manager.stopUpdatingLocation()
        stopUpdateLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //myLocation = Location()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
