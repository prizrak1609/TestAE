//
//  RouteModel.swift
//  TestAE
//
//  Created by Dima Gubatenko on 25.07.17.
//  Copyright © 2017 Dima Gubatenko. All rights reserved.
//

import Foundation
import GoogleMaps

struct RouteModel {
    var startPlace = PlaceModel.zero
    var endPlace = PlaceModel.zero
    var startMarker: GMSMarker {
        let place = GMSMarker(position: startPlace.location)
        place.title = startPlace.name
        return place
    }
    var endMarker: GMSMarker {
        let place = GMSMarker(position: endPlace.location)
        place.title = endPlace.name
        return place
    }
}
