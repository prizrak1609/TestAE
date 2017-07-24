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

    fileprivate var firstPlace: PlaceModel?
    fileprivate var firstPlaceMarker: GMSMarker?

    fileprivate var secondPlace: PlaceModel?
    fileprivate var secondPlaceMarker: GMSMarker?

    override func viewDidLoad() {
        super.viewDidLoad()
        initTextFields()
        getPlacesIfExists()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // set current location
        if let firstPlace = firstPlace {
            firstPlaceTextField.text = firstPlace.name
            map(zoomOn: firstPlace, value: mapZoomLevel)
        }
        if let secondPlace = secondPlace {
            secondPlaceTextField.text = secondPlace.name
            map(zoomOn: secondPlace, value: mapZoomLevel)
        } else {
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
        firstPlace = UserDefaults.standard.getFirstPlace()
        secondPlace = UserDefaults.standard.getSecondPlace()
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
        guard let firstPlace = firstPlace,
            let secondPlace = secondPlace,
            let mapView = mapView
            else {
                return
            }
        mapView.clear()
        if firstPlaceMarker == nil {
            firstPlaceMarker = GMSMarker(position: firstPlace.location)
            firstPlaceMarker?.title = firstPlace.name
        }
        if secondPlaceMarker == nil {
            secondPlaceMarker = GMSMarker(position: secondPlace.location)
            secondPlaceMarker?.title = secondPlace.name
        }
        firstPlaceMarker?.map = mapView
        secondPlaceMarker?.map = mapView
        let path = GMSMutablePath()
        path.add(firstPlace.location)
        path.add(secondPlace.location)
        let rectangle = GMSPolyline(path: path)
        rectangle.map = mapView
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
            firstPlace = model
            UserDefaults.standard.setValue(firstPlace: model)
            firstPlaceMarker = GMSMarker(position: model.location)
            firstPlaceMarker?.title = model.name
            firstPlaceMarker?.map = mapView
        }
        if selectedTextField == secondPlaceTextField {
            secondPlace = model
            UserDefaults.standard.setValue(secondPlace: model)
            secondPlaceMarker = GMSMarker(position: model.location)
            secondPlaceMarker?.title = model.name
            secondPlaceMarker?.map = mapView
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
