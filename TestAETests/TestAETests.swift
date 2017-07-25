//
//  TestAETests.swift
//  TestAETests
//
//  Created by Dima Gubatenko on 24.07.17.
//  Copyright © 2017 Dima Gubatenko. All rights reserved.
//

import XCTest
import CoreLocation
import GoogleMaps
@testable import TestAE

class TestAETests: XCTestCase {

    // Kiev
    let startPlace = PlaceModel(name: "Kiev", latitude: 50.45, longitude: 30.52)
    // Odessa
    let endPlace = PlaceModel(name: "Odessa", latitude: 46.48, longitude: 30.72)

    var server: Server?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        server = Server()
    }
    
    override func tearDown() {
        server = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertTrue(true)
    }

    func testServerGetRouteFromRouteModel() {
        let routeModel = RouteModel(startPlace: startPlace, endPlace: endPlace)
        var models = [GMSPolyline]()
        let expecatation = expectation(description: #function)
        server?.getRoute(from: routeModel, { result in
            switch result {
                case .failure(let error): XCTAssertTrue(false, error.localizedDescription)
                case .success(let _models):
                    models = _models
                    expecatation.fulfill()
            }
        })
        waitForExpectations(timeout: 20, handler: nil)
        XCTAssertFalse(models.isEmpty)
    }

    func testServerGetRouteFromPlacesModel() {
        var models = [GMSPolyline]()
        let expecatation = expectation(description: #function)
        server?.getRoute(from: startPlace, to: endPlace, { result in
            switch result {
                case .failure(let error): XCTAssertTrue(false, error.localizedDescription)
                case .success(let _models):
                    models = _models
                    expecatation.fulfill()
            }
        })
        waitForExpectations(timeout: 20, handler: nil)
        XCTAssertFalse(models.isEmpty)
    }

    func testServerGetRouteFromCLLocationCoordinate2DModel() {
        var models = [GMSPolyline]()
        let expecatation = expectation(description: #function)
        server?.getRoute(from: startPlace.location, to: endPlace.location, { result in
            switch result {
                case .failure(let error): XCTAssertTrue(false, error.localizedDescription)
                case .success(let _models):
                    models = _models
                    expecatation.fulfill()
            }
        })
        waitForExpectations(timeout: 20, handler: nil)
        XCTAssertFalse(models.isEmpty)
    }
}
