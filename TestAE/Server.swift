//
//  Server.swift
//  TestAE
//
//  Created by Dima Gubatenko on 25.07.17.
//  Copyright © 2017 Dima Gubatenko. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON
import GoogleMaps

typealias ServerRouteCompletion = (Result<[GMSPolyline]>) -> Void

final class Server {

    func getRoute(from route: RouteModel, _ completion: @escaping ServerRouteCompletion) {
        getRoute(from: route.startPlace, to: route.endPlace, completion)
    }

    func getRoute(from start: PlaceModel, to end: PlaceModel, _ completion: @escaping ServerRouteCompletion) {
        getRoute(from: start.location, to: end.location, completion)
    }

    func getRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, _ completion: @escaping ServerRouteCompletion) {
        let startLocation = "\(start.latitude),\(start.longitude)"
        let endLocation = "\(end.latitude),\(end.longitude)"
        let url = "https://maps.googleapis.com/maps/api/directions/json"
        let params = ["origin" : startLocation, "destination" : endLocation, "mode" : "driving"]
        Alamofire.request(url, method: .get, parameters: params).responseJSON { [weak self] response in
            guard let welf = self else { return }
            let result = welf.parseResponse(response)
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            if case .success(let json) = result {
                let routes = json["routes"].arrayValue
                var result = [GMSPolyline]()
                for route in routes {
                    let routeOverviewPolyline = route["overview_polyline"].dictionaryValue
                    if let points = routeOverviewPolyline["points"]?.stringValue, let path = GMSPath(fromEncodedPath: points) {
                        result.append(GMSPolyline(path: path))
                    } else {
                        continue
                    }
                }
                completion(.success(result))
            }
        }
    }

    private func parseResponse(_ response: DataResponse<Any>) -> Result<JSON> {
        if let error = response.error ?? response.result.error {
            return .failure(NSError(domain: error.localizedDescription, code: 0, userInfo: nil))
        }
        if let result = response.result.value {
            return .success(JSON(result))
        }
        return .failure(NSError(domain: NSLocalizedString("failed to parse json", comment: "Server parseJSON"), code: 0, userInfo: nil))
    }
}
