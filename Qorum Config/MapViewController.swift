//
//  MapViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 30.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import MapKit

/// The screen for picking Qorum fake location.
class MapViewController: UIViewController {
    
    /// The main view. Represents a map to pick a location on.
    let mapView = MKMapView()
    
    /// The `MKPointAnnotation` indicating current fake location on the `mapView`.
    let pointer = MKPointAnnotation()
    
    /// The `UITextField` for entering the fake location latitude.
    let latitudeField = UITextField()
    
    /// The `UITextField` for entering the fake location longitude.
    let longitudeField = UITextField()
    
    /// Requests the real location to get initial coordinate for user convenience.
    let locationManager = CLLocationManager()
    
    /// Specifies the constraints for entering fake location coordinates in the text fields.
    var fieldFormatter: NumberFormatter {
        return QorumLocation.stringFormatter
    }
    
    //MARK: -
    
    /// Sets the `mapView`, text fields and navigation items up.
    override func loadView() {
        super.loadView()
        title = "Map"
        view = mapView
        latitudeField.returnKeyType = .next
        latitudeField.placeholder = "Latitude"
        setupField(latitudeField)
        longitudeField.returnKeyType = .done
        longitudeField.placeholder = "Longitude"
        setupField(longitudeField)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                            target: navigationController,
                                                            action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(done))
    }
    
    /// The `mapView` and `locationManager` setup.
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.addAnnotation(pointer)
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        if let initialCoordinate = AppConfig.location.customCoordinate {
            updateLocation(newCoordinate: initialCoordinate, size: 0.05, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getLocation()
    }
    
    /// Updates layout of the text fields (because no constraints added here)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fieldWidth = view.bounds.width/2 - 24
        let fieldHeight: CGFloat = 40
        let originY = topLayoutGuide.length + 16
        latitudeField.frame = CGRect(x: 16, y: originY, width: fieldWidth, height: fieldHeight)
        longitudeField.frame = CGRect(x: fieldWidth+32, y: originY, width: fieldWidth, height: fieldHeight)
    }
    
    //MARK: -
    
    /// Asks the `locationManager` to request initial location.
    /// Also does `requestWhenInUseAuthorization` if necessary.
    func getLocation() {
        // No need to ask a location in this case - it will default (or did) to `AppConfig.location.customCoordinate` (see the `viewDidLoad`)
        guard AppConfig.location.isReal else { return }
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestLocation()
            }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        }
    }
    
    /// Configures given text field - its appearance and keyboard.
    /// Also assigns it a delegate of `self` and adds it as a subview.
    ///
    /// - Parameter textField: The `UITextField` to configure.
    private func setupField(_ textField: UITextField) {
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numbersAndPunctuation
        textField.delegate = self
        view.addSubview(textField)
        textField.applyToolbar()
    }
    
    /// Applies new fake location and returns to the previous screen.
    @objc func done() {
        AppConfig.location = .custom(pointer.coordinate)
        navigationController?.popViewController(animated: true)
    }
    
    /// Moves visible region of the `mapView` to given location.
    ///
    /// - Parameters:
    ///   - newCoordinate: The `CLLocationCoordinate2D` to move to.
    ///   - size: The span size in `CLLocationDegrees`. Will use the `mapView` span if `nil` passed.
    ///   - animated: Whether it will be animated transition.
    func updateLocation(newCoordinate: CLLocationCoordinate2D,
                         size: CLLocationDegrees? = nil,
                         animated: Bool) {
        let span: MKCoordinateSpan
        if let size = size {
            span = MKCoordinateSpan(latitudeDelta: size,
                                    longitudeDelta: size)
        } else {
            span = mapView.region.span
        }
        mapView.setRegion(MKCoordinateRegion(center: newCoordinate,
                                             span: span),
                          animated: animated)
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        pointer.coordinate = mapView.centerCoordinate
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let newCoordinate = mapView.centerCoordinate
        latitudeField.text = fieldFormatter.string(from: NSNumber(value: newCoordinate.latitude))
        longitudeField.text = fieldFormatter.string(from: NSNumber(value: newCoordinate.longitude))
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        getLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userCoordinate = locations.last?.coordinate {
            updateLocation(newCoordinate: userCoordinate, size: 0.05, animated: true)
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager did fail with error:\n\(error)")
    }
    
}

// MARK: - UITextFieldDelegate
extension MapViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let newString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        if newString.isEmpty { return true } // allow to remove the value from the text field
        if newString == "-" { return true } // allow to enter negative degrees
        return fieldFormatter.number(from: newString) != nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard
            let newInput = textField.text,
            let newDegrees = fieldFormatter.number(from: newInput)?.doubleValue else
        {
            textField.clear()
            return
        }
        var newCoordinate = pointer.coordinate
        switch textField {
        case latitudeField:
            let latSpan = mapView.region.span.latitudeDelta
            // ensure that new map view region won't exceed polar lines by latitude plus ten degrees (90-80=10) margin
            newCoordinate.latitude = min(max(latSpan-80, newDegrees), 80-latSpan)
            longitudeField.becomeFirstResponder()
        case longitudeField:
            newCoordinate.longitude = newDegrees
        default:
            break
        }
        updateLocation(newCoordinate: newCoordinate, animated: true)
    }
    
}
