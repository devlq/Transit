//
//  MapViewController.swift
//  Transit
//
//  Created by Pat on 08/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var starButton: UIButton!
    private var guideStarted = false
    
    var selectedPath: [String:Any]!
    var currentLocation: CLLocation?
    
    @IBAction func startGuide () {
        let navVC = self.navigationController as! MainNavController
        let locationManager = navVC.locationManager
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if guideStarted {
            guideStarted = false
            starButton.titleLabel?.text="Start"
            locationManager.distanceFilter = CLLocationDistance(appDelegate.locationUpdateDistanceInterchange)
        }
        else {
            guideStarted = true
            starButton.titleLabel?.text="End"
            locationManager.distanceFilter = CLLocationDistance(appDelegate.locationUpdateDistanceFootpath)
        }
        displayMap()
    }
    
    func displayMap () {
        let start_lat = selectedPath["start_lat"] as! Double
        let end_lat = selectedPath["end_lat"] as! Double
        let start_lng = selectedPath["start_lng"] as! Double
        let end_lng = selectedPath ["end_lng"] as! Double
        let start_address = selectedPath ["start_address"] as! String
        let end_address = selectedPath ["end_address"] as! String
        let region: MKCoordinateRegion!
        if guideStarted && currentLocation !== nil {
            region = MKCoordinateRegionMakeWithDistance((currentLocation?.coordinate)!, 10, 10)
        }
        else {
            let startLocation = CLLocation(latitude: start_lat, longitude: start_lng)
            let endLocation = CLLocation(latitude: end_lat, longitude: end_lng)
            let midLocation = CLLocationCoordinate2D(latitude: (start_lat+end_lat)/2, longitude: (start_lng+end_lng)/2)
            let distance = startLocation.distance(from: endLocation)
            region = MKCoordinateRegionMakeWithDistance(midLocation, distance * 1.2, distance * 1.2)
            
            let startPlace = Place (title: "Start", subtitle: start_address, coordinate: startLocation.coordinate)
            let endPlace = Place(title: "End", subtitle: end_address, coordinate: endLocation.coordinate)
            mapView.addAnnotation(startPlace)
            mapView.addAnnotation(endPlace)
        }
        mapView.setRegion(region, animated: true)
        
    }
    
    func updateMap() {
        let start_lat = selectedPath["start_lat"] as! Double
        let end_lat = selectedPath["end_lat"] as! Double
        let start_lng = selectedPath["start_lng"] as! Double
        let end_lng = selectedPath ["end_lng"] as! Double
        let start_address = selectedPath ["start_address"] as! String
        let end_address = selectedPath ["end_address"] as! String
        let region: MKCoordinateRegion!
        if guideStarted && currentLocation !== nil {
             region = MKCoordinateRegionMakeWithDistance((currentLocation?.coordinate)!, 10, 10)
        }
        else {
            let startLocation = CLLocation(latitude: start_lat, longitude: start_lng)
            let endLocation = CLLocation(latitude: end_lat, longitude: end_lng)
            let midLocation = CLLocationCoordinate2D(latitude: (start_lat+end_lat)/2, longitude: (start_lng+end_lng)/2)
            let distance = startLocation.distance(from: endLocation)
            region = MKCoordinateRegionMakeWithDistance(midLocation, distance * 0.6, distance * 0.6)
            
            let startPlace = Place (title: "Start", subtitle: start_address, coordinate: startLocation.coordinate)
            let endPlace = Place(title: "End", subtitle: end_address, coordinate: endLocation.coordinate)
            mapView.addAnnotation(startPlace)
            mapView.addAnnotation(endPlace)
        }
        mapView.setRegion(region, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        instruction.text=""
        starButton.titleLabel?.text="Start"
        guideStarted = false
        let navVC = self.navigationController as! MainNavController
        let locationManager = navVC.locationManager
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.requestLocation()
            mapView.showsUserLocation = true
        }
        displayMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
