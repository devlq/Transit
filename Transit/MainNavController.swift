//
//  MainNavController.swift
//  Transit
//
//  Created by Pat on 06/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MainNavController: UINavigationController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var reminderShown = false
//    var mapView: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location Management
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            if let topVC = topViewController {
                if topVC.isKind(of: MapViewController.self) {
                    if let mapView = (topVC as! MapViewController).mapView {
                        mapView.showsUserLocation = true
                    }
                }
            }
        default:
            locationManager.stopUpdatingLocation()
            if let topVC = topViewController {
                if topVC.isKind(of: MapViewController.self) {
                    if let mapView = (topVC as! MapViewController).mapView {
                        mapView.showsUserLocation = false
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let errorType = error.localizedDescription
        let alertController = UIAlertController(title: "Location Manager Error", message: errorType, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {action in})
        alertController.addAction(okAction)
        topViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let newLocation = locations[locations.count-1]
        appDelegate.lastLocation = newLocation
        
        if newLocation.horizontalAccuracy > appDelegate.remindDistance {
            return
        }
        var nearInterchange = false
        for ic in appDelegate.interchanges {
            let icLocation = CLLocation(latitude: ic.latitude!, longitude: ic.longitude!)
            let distance = newLocation.distance(from: icLocation)
            if distance <= appDelegate.remindDistance { // near an interchange
                nearInterchange = true
                if !reminderShown {     // the reminder has not been shown to the user
                    reminderShown = true
                    let alertController = UIAlertController(title: "Arrived at Interchange", message: "You have arrived at \(ic.name!) interchange. Please transit here.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {action in})
                    alertController.addAction(okAction)
                    topViewController?.present(alertController, animated: true, completion: nil)
                    //show alert
                }
            }
            if !nearInterchange { // not near any interchange, or just left a interchange. reset reminderShown
                reminderShown = false
            }
        }
        if let topVC = topViewController {
            if topVC.isKind(of: InterchangeTableViewController.self) {
                    if let table = (topVC as! InterchangeTableViewController).tableView {
                        table.reloadData()
                }
            }
            else if topVC.isKind(of: MapViewController.self) {
                let mapVC = topVC as! MapViewController
                mapVC.currentLocation = newLocation
//                mapVC.updateMap()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
