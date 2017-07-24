//
//  PlaceModel.swift
//  TestAE
//
//  Created by Dima Gubatenko on 24.07.17.
//  Copyright © 2017 Dima Gubatenko. All rights reserved.
//

import Foundation
import GooglePlaces

struct PlaceModel {
    let name: String
    let location: CLLocationCoordinate2D

    init(location: CLLocationCoordinate2D) {
        name = ""
        self.location = location
    }

    init(name: String, location: CLLocationCoordinate2D) {
        self.name = name
        self.location = location
    }

    init(name: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.init(name: name, location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }

    init(place: GMSPlace) {
        self.init(name: place.name, location: place.coordinate)
    }
}
