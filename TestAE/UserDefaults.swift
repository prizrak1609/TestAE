//
//  UserDefaults.swift
//  TestAE
//
//  Created by Dima Gubatenko on 24.07.17.
//  Copyright © 2017 Dima Gubatenko. All rights reserved.
//

import Foundation
import GooglePlaces

extension UserDefaults {

    struct Keys {
        // disable because need to spleet keys of first place and second
        // swiftlint:disable nesting
        struct FirstPlace {
            static let name = "First place name"
            static let latitude = "First place latitude"
            static let longitude = "First place longitude"
        }
        struct SecondPlace {
            static let name = "Second place name"
            static let latitude = "Second place latitude"
            static let longitude = "Second place longitude"
        }
    }

    func setValue(firstPlace place: PlaceModel) {
        setValue(place.name, forKey: Keys.FirstPlace.name)
        setValue(place.location.latitude, forKey: Keys.FirstPlace.latitude)
        setValue(place.location.longitude, forKey: Keys.FirstPlace.longitude)
    }

    func setValue(secondPlace place: PlaceModel) {
        setValue(place.name, forKey: Keys.SecondPlace.name)
        setValue(place.location.latitude, forKey: Keys.SecondPlace.latitude)
        setValue(place.location.longitude, forKey: Keys.SecondPlace.longitude)
    }

    func getFirstPlace() -> PlaceModel? {
        guard let name = string(forKey: Keys.FirstPlace.name) else { return nil }
        let latitude = double(forKey: Keys.FirstPlace.latitude)
        let longitude = double(forKey: Keys.FirstPlace.longitude)
        return PlaceModel(name: name, latitude: latitude, longitude: longitude)
    }

    func getSecondPlace() -> PlaceModel? {
        guard let name = string(forKey: Keys.SecondPlace.name) else { return nil }
        let latitude = double(forKey: Keys.SecondPlace.latitude)
        let longitude = double(forKey: Keys.SecondPlace.longitude)
        return PlaceModel(name: name, latitude: latitude, longitude: longitude)
    }
}
