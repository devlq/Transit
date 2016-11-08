//
//  MapViewController.swift
//  Transit
//
//  Created by Pat on 08/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit
import MapKit

let DISTANCE_TO_START_GUIDE:Double = 100 // The maximum distance to the footpath allowed for start guiding
let DESTINATION_ARRIVED_DISTANCE:Double = 5 // The distance within which is considered arrived at the destination

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var starButton: UIButton!
    private var guideStarted = false
    private var polylinePoints = [CLLocationCoordinate2D]()
    var selectedPath: [String:Any]!
    var currentLocation: CLLocation?
    var currentHeading: CLLocationDirection?
    var next_point:Int?

    private func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    private func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    private func getBearingBetweenTwoPoints(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
    

    @IBAction func startGuide () {
        let navVC = self.navigationController as! MainNavController
        let locationManager = navVC.locationManager
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if guideStarted {
            guideStarted = false
            starButton.setTitle("Start", for: UIControlState.normal)
            instruction.text = ""
            locationManager.distanceFilter = CLLocationDistance(appDelegate.locationUpdateDistanceInterchange)
        }
        else {
            var shortest_distance:Double = DISTANCE_TO_START_GUIDE
            var nearest_point = 0
            var index = 0
            for point in polylinePoints {
                let pointLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
                let dist = currentLocation?.distance(from: pointLocation)
                if dist! < shortest_distance {
                    shortest_distance = dist!
                    nearest_point = index
                }
                index += 1
            }
            if shortest_distance >= DISTANCE_TO_START_GUIDE {
                instruction.text = "Walk to path"
                let alertController = UIAlertController(title: "Too far for directions", message: "You are too far away from the footpath. Please walk nearer to the footpath to start", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: {action in})
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
            else {
                guideStarted = true
                starButton.setTitle("End", for: UIControlState.normal)
                locationManager.distanceFilter = CLLocationDistance(appDelegate.locationUpdateDistanceFootpath)
                
                if nearest_point == polylinePoints.count - 1 {
                    next_point = nearest_point
                    if shortest_distance < DESTINATION_ARRIVED_DISTANCE {
                        instruction.text = "You have arrived"
                        let alertController = UIAlertController(title: "Arrived at the destination", message: "You have arrived at \(selectedPath ["end_address"] as! String).", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .cancel){action in
                            self.guideStarted = false
                            self.starButton.setTitle("Start", for: UIControlState.normal)
                            self.instruction.text = ""
                            locationManager.distanceFilter = CLLocationDistance(appDelegate.locationUpdateDistanceInterchange)
                            self.displayMap()
                        }
                        alertController.addAction(okAction)
                        present(alertController, animated: true, completion: nil)
                        return
                    }
                }
                else {
                    next_point = nearest_point + 1
                }
                if currentHeading == nil {
                    instruction.text = "Finding your heading..."
                }
                else if currentLocation == nil {
                    instruction.text = "Finding you location..."
                }
                else {
                    let nextLocation = CLLocation(latitude: polylinePoints[next_point!].latitude, longitude: polylinePoints[next_point!].longitude)
                    let bearing = getBearingBetweenTwoPoints(point1: currentLocation!, point2: nextLocation)
                    let angle = bearing - currentHeading!
                    if angle <= 30 && angle >= -30 {
                        instruction.text = "Walk straight ahead"
                    }
                    else if angle > 30 && angle < 60 {
                        instruction.text = "Walk towards right"
                    }
                    else if angle >= 60 && angle < 135 {
                        instruction.text = "Turn right"
                    }
                    else if angle < -30 && angle > -60 {
                        instruction.text = "Walk towards left"
                    }
                    else if angle <= -60 && angle > -135 {
                        instruction.text = "Turn left"
                    }
                    else {
                        instruction.text = "Turn around"
                    }
                }
            }
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
        if !guideStarted { // no need to update map if guide has not started
            return
        }
        if currentLocation == nil {
            instruction.text = "Finding you location..."
            return
        }
        let navVC = self.navigationController as! MainNavController
        let locationManager = navVC.locationManager
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        mapView.setCenter(currentLocation!.coordinate, animated: true)
        let nextLocation = CLLocation(latitude: polylinePoints[next_point!].latitude, longitude: polylinePoints[next_point!].longitude)
        let dist_to_next_point = currentLocation!.distance(from: nextLocation)
        if dist_to_next_point < DESTINATION_ARRIVED_DISTANCE {
            if next_point == polylinePoints.count-1 {
                instruction.text = "You have arrived"
                let alertController = UIAlertController(title: "Arrived at the destination", message: "You have arrived at \(selectedPath ["end_address"] as! String).", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel) {action in
                    self.guideStarted = false
                    self.starButton.setTitle("Start", for: UIControlState.normal)
                    locationManager.distanceFilter = CLLocationDistance(appDelegate.locationUpdateDistanceInterchange)
                    self.displayMap()
                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
                return
            }
            else {
                next_point! += 1
            }
        }
        else if next_point != polylinePoints.count-1 {
            let locationAfterNextPoint = CLLocation(latitude: polylinePoints[next_point!+1].latitude, longitude: polylinePoints[next_point!+1].longitude)
            let dist_to_point_after_next_point = currentLocation!.distance(from: locationAfterNextPoint)
            if dist_to_point_after_next_point <= dist_to_next_point {
                next_point! += 1
            }
        }
        if currentHeading == nil {
            instruction.text = "Finding you heading..."
            return
        }
        let updatedNextLocation = CLLocation(latitude: polylinePoints[next_point!].latitude, longitude: polylinePoints[next_point!].longitude)
        let bearing = getBearingBetweenTwoPoints(point1: currentLocation!, point2: updatedNextLocation)
        let angle = bearing - currentHeading!
        if angle <= 30 && angle >= -30 {
            instruction.text = "Walk straight ahead"
        }
        else if angle > 30 && angle < 60 {
            instruction.text = "Walk towards right"
        }
        else if angle >= 60 && angle < 135 {
            instruction.text = "Turn right"
        }
        else if angle < -30 && angle > -60 {
            instruction.text = "Walk towards left"
        }
        else if angle <= -60 && angle > -135 {
            instruction.text = "Turn left"
        }
        else {
            instruction.text = "Turn around"
        }
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
        locationManager.stopUpdatingHeading()
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
            locationManager.startUpdatingLocation()
            if locationManager.heading != nil {
                locationManager.headingFilter = 5
                locationManager.startUpdatingHeading()
            }
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
