//
//  ViewController.swift
//  TestAE
//
//  Created by Dima Gubatenko on 24.07.17.
//  Copyright © 2017 Dima Gubatenko. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

fileprivate let mapZoomLevel: Float = 6

final class Main: UIViewController {
    @IBOutlet fileprivate weak var firstPlaceTextField: UITextField!
    @IBOutlet fileprivate weak var secondPlaceTextField: UITextField!

    fileprivate var selectedTextField: UITextField?
    fileprivate var mapView: GMSMapView?
    fileprivate let locationManager = CLLocationManager()
    fileprivate let server = Server()

    fileprivate var route = RouteModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        initTextFields()
        getPlacesIfExists()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // set current location
        if route.startPlace != .zero {
            firstPlaceTextField.text = route.startPlace.name
            map(zoomOn: route.startPlace, value: mapZoomLevel)
        }
        if route.endPlace != .zero {
            secondPlaceTextField.text = route.endPlace.name
            map(zoomOn: route.endPlace, value: mapZoomLevel)
        }
        if route.startPlace == .zero, route.endPlace == .zero {
            if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .denied {
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            } else {
                mapZoomOnCurrentPlace()
            }
        }
        buildRouteIfCan()
    }
}

extension Main {

    func getPlacesIfExists() {
        route.startPlace = UserDefaults.standard.getFirstPlace() ?? .zero
        route.endPlace = UserDefaults.standard.getSecondPlace() ?? .zero
    }

    func mapZoomOnCurrentPlace() {
        GMSPlacesClient.shared().currentPlace(callback: { [weak self] placeList, error in
            guard let welf = self else { return }
            if let error = error {
                log(error.localizedDescription)
                return
            }
            if let place = placeList?.likelihoods.first?.place {
                welf.map(zoomOn: PlaceModel(place: place), value: mapZoomLevel)
            }
        })
    }

    func map(zoomOn place: PlaceModel, value: Float) {
        if mapView == nil {
            let camera = GMSCameraPosition.camera(withTarget: place.location, zoom: value)
            let mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
            mapView.isMyLocationEnabled = true
            self.mapView = mapView
            mapView.isMyLocationEnabled = true
            view.insertSubview(mapView, belowSubview: firstPlaceTextField)
        } else {
            mapView?.moveCamera(.setTarget(place.location, zoom: value))
        }
    }

    func buildRouteIfCan() {
        guard route.startPlace != .zero,
            route.endPlace != .zero,
            let mapView = mapView
            else {
                return
            }
        mapView.clear()
        route.startMarker.map = mapView
        route.endMarker.map = mapView
        server.getRoute(from: route) { [weak self] result in
            guard let welf = self else { return }
            if case .failure(let error) = result {
                showText(error.localizedDescription)
                return
            }
            if case .success(let models) = result {
                for model in models {
                    model.map = welf.mapView
                }
            }
        }
    }
}

extension Main : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapZoomOnCurrentPlace()
        }
    }
}

extension Main : UITextFieldDelegate {

    func initTextFields() {
        firstPlaceTextField.delegate = self
        secondPlaceTextField.delegate = self
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedTextField = textField
        let searchPlacesController = GMSAutocompleteViewController()
        searchPlacesController.delegate = self
        present(searchPlacesController, animated: true, completion: nil)
        return false
    }
}

extension Main : GMSAutocompleteViewControllerDelegate {

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        selectedTextField?.text = place.formattedAddress
        let model = PlaceModel(place: place)
        if selectedTextField == firstPlaceTextField {
            route.startPlace = model
            UserDefaults.standard.setValue(firstPlace: model)
        }
        if selectedTextField == secondPlaceTextField {
            route.endPlace = model
            UserDefaults.standard.setValue(secondPlace: model)
        }
        map(zoomOn: model, value: mapZoomLevel)
        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        showText(error.localizedDescription)
        selectedTextField = nil
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        selectedTextField = nil
        dismiss(animated: true, completion: nil)
    }
}
