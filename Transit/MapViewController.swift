//
//  MapViewController.swift
//  Transit
//
//  Created by Pat on 08/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var starButton: UIButton!
    private var guideStarted = false
    private var polylinePoints = [CLLocationCoordinate2D]()
    var selectedPath: [String:Any]!
    var currentLocation: CLLocation?
    
    @IBAction func startGuide () {
        let navVC = self.navigationController as! MainNavController
        let locationManager = navVC.locationManager
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if guideStarted {
            guideStarted = false
            starButton.setTitle("Start", for: UIControlState.normal)
            locationManager.distanceFilter = CLLocationDistance(appDelegate.locationUpdateDistanceInterchange)
        }
        else {
            guideStarted = true
            starButton.setTitle("End", for: UIControlState.normal)
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
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let navVC = self.navigationController as! MainNavController
        let locationManager = navVC.locationManager
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guideStarted = false
        starButton.setTitle("Start", for: UIControlState.normal)
        locationManager.distanceFilter = CLLocationDistance(appDelegate.locationUpdateDistanceInterchange)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mapView.delegate = self
        instruction.text=""
        guideStarted = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
        let polylineString = selectedPath["polyline"] as! String
        polylinePoints = decodePolyline(polylineString)!
        let polyline = MKPolyline(coordinates: polylinePoints, count: polylinePoints.count)
        self.mapView.addOverlays([polyline], level: .aboveRoads)
        self.currentLocation = appDelegate.lastLocation
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
