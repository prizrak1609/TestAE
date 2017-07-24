//
//  ViewController.swift
//  TestAE
//
//  Created by Dima Gubatenko on 24.07.17.
//  Copyright © 2017 Dima Gubatenko. All rights reserved.
//

import UIKit
import GoogleMaps


final class Main: UIViewController {
    @IBOutlet fileprivate weak var firstPlaceTextField: UITextField!
    @IBOutlet fileprivate weak var secondPlaceTextField: UITextField!
    @IBOutlet fileprivate weak var buildRouteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initTextFields()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildRouteButton.layer.cornerRadius = 10
        buildRouteButton.layer.borderColor = UIColor.blue.cgColor
        buildRouteButton.layer.borderWidth = 1
        // add map
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        mapView.isMyLocationEnabled = true
        view.insertSubview(mapView, belowSubview: firstPlaceTextField)
    }

    @IBAction func buildRoute(_ sender: UIButton) {
        // TODO: show route between points
    }
}

extension Main : UITextFieldDelegate {

    func initTextFields() {
        firstPlaceTextField.delegate = self
        secondPlaceTextField.delegate = self
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // TODO: open search places
        return false
    }
}
