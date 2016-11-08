//
//  Place.swift
//  Transit
//
//  Created by Pat on 08/11/2016.
//  Copyright © 2016 LiuQiang. All rights reserved.
//

import UIKit
import MapKit

class Place: NSObject, MKAnnotation {
    let title:String?
    let subtitle:String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate:CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    

}
