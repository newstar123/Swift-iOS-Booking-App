//
//  LocationManager.swift
//  Qorum
//
//  Created by Michael Wilson on 10/2/15.
//  Copyright © 2015 Qorum. All rights reserved.
//

import CoreLocation
import SwiftyBeaver

final class LocationService: CLLocationManager {
    
    // MARK: - shared instance
    static let shared = LocationService()
    
    /// Fires on every authorization status change.
    private var authorizationCallback: ((CLAuthorizationStatus) -> ())?
    
    /// Indicates whether the user has requested .authorizedAlways or .authorizedWhenInUse.
    private var isAlwaysUseStatusRequested: Bool?
    
    fileprivate override init() {
        super.init()
        delegate = self
        desiredAccuracy = kCLLocationAccuracyBest
        distanceFilter = kCLDistanceFilterNone
        
        if monitoredRegions.isEmpty {
            startMonitoringBeacons()
        }
        
        QorumNotification.checkedIn
            .add(observer: self, selector: #selector(handleCheckIn))
        QorumNotification.checkedOut
            .add(observer: self, selector: #selector(handleCheckOut))
    }
    
    // MARK: - Beacons properties
    
    /// Beacon region which represents the single region for all the beacons in the Qorum service, under the same unique Qorum UUID.
    fileprivate let qorumBeaconRegion: CLBeaconRegion = {
        let proximityUUID = UUID(uuidString: kBeaconsIdentifier)
        let regionId = "com.qorum.ios"
        
        return CLBeaconRegion(proximityUUID: proximityUUID!,
                              identifier: regionId)
    }()
    
    /// A stored property for the nearest beacon in range.
    ///
    /// Setting this value results in a new request to fetch the beacons data for the venue by the venue's identifier (Beacon's major value represents the identifier of the venue).
    /// Response handler will try to find in the response the beacon that matches parameters.
    ///
    /// Trying to set this value with the value that has the same major value or nil, will result to nothing.
    fileprivate var nearestBeacon: CLBeacon? {
        didSet {
            guard
                let beacon = nearestBeacon,
                beacon.major != oldValue?.major else { return }
            
            let venueId = beacon.major.intValue
            
            let worker = VenuesWorker()
            worker.loadBeacons(venueId: venueId) { [weak self] (result) in
                switch result {
                case let .value(beacons):
                    guard !beacons.isEmpty else {
                        SwiftyBeaver.warning("loadBeacons returns an empty array")
                        return
                    }
                    self?.matchingBeacon = beacons.first {
                        $0.major == beacon.major.intValue &&
                        $0.minor == beacon.minor.intValue
                    }
                case let .error(error):
                    SwiftyBeaver.error(error.localizedDescription)
                }
            }
            SwiftyBeaver.info("loadBeacons request was sended")
        }
    }
    
    /// Wrapper for the region notification, that notifies about the venue that is next to the user.
    ///
    /// - Parameter trackedVenue: venue next to the user.
    fileprivate func checkRegionNotif(_ trackedVenue: (Venue)) {
        VenueTracker.shared.trackedVenue = trackedVenue
        let hasActiveCheckin = UserDefaults.standard.bool(for: .hasActiveCheckin)
        if !hasActiveCheckin && trackedVenue.isOpen && trackedVenue.isActive == true {
            VenueTrackerNotifier.showRegionNotif(for: trackedVenue)
        }
    }
    
    /// A stored property for the matching beacon instance, fetched from server.
    ///
    /// This value sets automaticaly by the nearestBeacon request handler.
    /// Setting this value results in a new request to fetch the venue's data for the venue with identifier that equals the matchingBeacon's major value.
    /// Response handler will asign the result venue to the VenueTracker's trackedVenue property.
    ///
    /// If user has no active checkin and the result venue is available to checkin, user will receive the local notification which includes the info about the venue and suggestion to checkin.
    fileprivate var matchingBeacon: Beacon? {
        didSet {
            guard
                matchingBeacon != nil,
                let venueId = matchingBeacon?.major else { return }
            if let matchingVenue = CityManager.shared.allVenues.first(where: { $0.venue_id == venueId }) {
                SwiftyBeaver.debug("matching venue defined")
                checkRegionNotif(matchingVenue)
            } else {
                VenuesWorker().loadVenue(venueId: venueId) { [weak self] (result) in
                    switch result {
                    case let .value(venueToCheckIn):
                        SwiftyBeaver.debug("loadVenue returns venue: \(venueToCheckIn)")
                        self?.checkRegionNotif(venueToCheckIn)
                    case let .error(error):
                        SwiftyBeaver.error(error.localizedDescription)
                    }
                }
                SwiftyBeaver.info("loadVenue request was sended")
            }
        }
    }
    
    // MARK: - Beacons Monitoring
    
    
    /// Starts monitoring beacons if it is available.
    ///
    /// Monitoring beacons will notify only the entrance a beacon region.
    fileprivate func startMonitoringBeacons() {
        guard AppConfig.beaconsEnabled else { return }
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            let region = qorumBeaconRegion
            region.notifyOnEntry = true
            region.notifyOnExit = false
            
            startMonitoring(for: region)
            SwiftyBeaver.debug("didStartMonitoringBeacons")
        } else {
            SwiftyBeaver.warning("\(#function) failed")
        }
    }
    
    /// Stops monitoring beacons.
    fileprivate func stopMonitoringBeacons() {
        if let beaconRegion = monitoredRegions.find(CLBeaconRegion.self) {
            stopRanging()
            stopMonitoring(for: beaconRegion)
            SwiftyBeaver.debug("didStopMonitoringBeacons")
        } else {
            SwiftyBeaver.warning("\(#function) failed")
        }
    }
    
    // MARK: - Beacons Ranging
    
    /// Starts region ranging if it is available.
    ///
    /// - Parameter region: region to range
    fileprivate func rangeBeaconsIn(_ region: CLBeaconRegion) {
        if CLLocationManager.isRangingAvailable() {
            startRangingBeacons(in: region)
            SwiftyBeaver.debug("didStartRanging")
            isRanging = true
        } else {
            SwiftyBeaver.warning("\(#function) failed")
        }
    }
    
    /// Stops region ranging.
    fileprivate func stopRanging() {
        stopRangingBeacons(in: qorumBeaconRegion)
        SwiftyBeaver.debug("didStopRanging with qorumBeaconRegion")
        isRanging = false
    }
    
    /// Refreshes region ranging.
    func refreshRanging() {
        rangeBeaconsIn(qorumBeaconRegion)
        SwiftyBeaver.info("refreshRanging")
    }
    
    /// Indicates the ranging proccess activity.
    ///
    /// Returns YES if region ranging is on.
    fileprivate var isRanging = false
    
    // MARK: - Location Monitoring
    
    /// Invokes starting region monitoring of the venue if it's available.
    ///
    /// The location region is taken from the VenueTracker's trackedVenue coordinates... if this value is missing, it will try to fetch venue with identifier stored in UserDefaults by activeCheckinVenueId key. If both values are missing, this method does nothing.
    ///
    /// Monitoring locations notifies only on exiting the location radius.
    fileprivate func startMonitoringLocation() {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            if let venue = VenueTracker.shared.trackedVenue {
                startMonitoringLocation(ofTheVenue: venue)
            } else if let activeCheckinVenueId = UserDefaults.standard.value(forKey: UserDefaultsKeys.activeCheckinVenueId.rawValue) as? Int {
                VenuesWorker().loadVenue(venueId: activeCheckinVenueId) { (result) in
                    switch result {
                    case let .value(venue):
                        SwiftyBeaver.info("loadVenue returns venue: \(venue)")
                        self.startMonitoringLocation(ofTheVenue: venue)
                    case let .error(error):
                        SwiftyBeaver.error(error.localizedDescription)
                    }
                }
            } else {
                SwiftyBeaver.warning("\(#function) failed because of missing VenueTracker.shared.trackedVenue")
            }
        } else {
            SwiftyBeaver.warning("\(#function) failed")
        }
    }
    
    
    /// Starts region monitoring for defined venue.
    ///
    /// If checkoutRadius is missing for this venue, the default 50 metters will be adjusted.
    ///
    /// - Parameter venue: venue which location should be monitored.
    fileprivate func startMonitoringLocation(ofTheVenue venue: Venue) {
        guard let lat = venue.locLatitude, let lon = venue.locLongitude else {
            SwiftyBeaver.warning("\(#function) failed because location for venue is missing")
            return
        }
        
        let center = CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon
        )
        let checkOutRegion = CLCircularRegion(
            center: center,
            radius: venue.checkOutRadius ?? 50,
            identifier: venue.venue_id.description
        )
        checkOutRegion.notifyOnEntry = false
        checkOutRegion.notifyOnExit = true
        
        startMonitoring(for: checkOutRegion)
        SwiftyBeaver.info("didStartMonitoringLocation")
    }
    
    /// Stops monitoring of location region.
    fileprivate func stopMonitoringLocation() {
        if let circularRegion = monitoredRegions.find(CLCircularRegion.self) {
            stopMonitoring(for: circularRegion)
            SwiftyBeaver.info("didStopMonitoringLocation")
        } else {
            SwiftyBeaver.warning("\(#function) failed")
        }
    }
    
    // MARK: - Handlers
    
    /// This method will stop monitoring beacons and starts monitoring of the venue's location, if it's possible.
    @objc fileprivate func handleCheckIn() {
        guard monitoredRegions.find(CLBeaconRegion.self) != nil else {
            SwiftyBeaver.warning("\(#function) failed")
            return
        }
        stopMonitoringBeacons()
        startMonitoringLocation()
    }
    
    /// This method will stop monitoring of the venue's location and starts monitoring beacons.
    ///
    /// This method also sets the nearestBeacon's and matchingBeacon's values to nil.
    @objc fileprivate func handleCheckOut() {
        guard monitoredRegions.find(CLCircularRegion.self) != nil else {
            SwiftyBeaver.warning("\(#function) failed")
            return
        }
        nearestBeacon = nil
        matchingBeacon = nil
        stopMonitoringLocation()
        startMonitoringBeacons()
    }
    
    /// This method tries to fire the VenueTracker's attemptAutoCheckout(to:) and handleCheckOut().
    ///
    /// If the value for VenueTracker's trackedVenue is missing, than it will try to find the venue id by the UserDefaultsKeys.activeCheckinVenueId key, stored in UserDefaults and request the venue by this id from server.
    fileprivate func exitFromRegion() {
        if let venueToCheckout = VenueTracker.shared.trackedVenue {
            VenueTracker.shared.attemptAutoCheckout(to: venueToCheckout)
            self.handleCheckOut()
        } else if let activeCheckinVenueId = UserDefaults.standard.value(forKey: UserDefaultsKeys.activeCheckinVenueId.rawValue) as? Int {
            let worker = VenuesWorker()
            worker.loadVenue(venueId: activeCheckinVenueId) { (result) in
                switch result {
                case let .value(venue):
                    SwiftyBeaver.info("loadVenue returns venue: \(venue)")
                    VenueTracker.shared.attemptAutoCheckout(to: venue)
                    self.handleCheckOut()
                case let .error(error):
                    SwiftyBeaver.error(error.localizedDescription)
                }
            }
        } else {
            SwiftyBeaver.warning("no venue to checkout")
        }
    }
    
    // MARK: - Background task API
    
    fileprivate var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    fileprivate func registerBackgroundTask() {
        guard backgroundTask == UIBackgroundTaskInvalid else {
            SwiftyBeaver.info("Background task is already started.")
            return
        }
        SwiftyBeaver.info("Background task started.")
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    fileprivate func endBackgroundTask() {
        guard backgroundTask != UIBackgroundTaskInvalid else {
            SwiftyBeaver.info("Background task is already invalid.")
            return
        }
        SwiftyBeaver.info("Our app is sleeping now.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    // MARK: - Location API
    
    let geocoder = CLGeocoder()
    
    /// Represents location property of the CLLocationManager or custom coordinates from AppConfig if it's not nil.
    override var location: CLLocation? {
        if let customCoordinate = AppConfig.location.customCoordinate {
            return CLLocation(latitude: customCoordinate.latitude, longitude: customCoordinate.longitude)
        }
        return super.location
    }
    
    /// Returns YES if CLLocationManager.authorizationStatus() is .authorizedAlways or .authorizedWhenInUse, otherwise NO.
    var isLocationEnabled: Bool {
        guard AppConfig.location.isReal else { return true }
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    /// Returns YES if CLLocationManager.authorizationStatus() is .notDetermined, otherwise NO.
    var isLocationUndetermined: Bool {
        guard AppConfig.location.isReal else { return false }
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            return true
        default:
            return false
        }
    }
    
    /// Returns NO if CLLocationManager.authorizationStatus() is .authorizedAlways or .authorizedWhenInUse, otherwise YES.
    var isLocationDisabled: Bool {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return false
        default:
            return true
        }
    }
    
    /// Returns YES if the distance from user to the nearest city is less than the market's radius, otherwise NO.
    ///
    /// Location data of the nearest city and market radius is taken from the CityManager, so if this values is missing there it will retun NO.
    var isLocationInMarketRange: Bool {
        let nearestCity = CityManager.shared.nearestCity
        guard
            let latitude = nearestCity?.latitude,
            let longitude = nearestCity?.longitude,
            let marketRadius = CityManager.shared.marketRadius,
            let userLocation = location else { return false }
        let destination = CLLocation(latitude: latitude, longitude: longitude)
        let distance = userLocation.distance(from: destination)
        return distance < marketRadius
    }

    /// Invokes location request with accuracy of hundred meters.
    func requestLocationUpdate() {
        print("request usual location update")
        requestLocation(accuracy: kCLLocationAccuracyHundredMeters)
    }
    
    /// Invokes location request with accuracy of three kilometers.
    func requestFastestLocationUpdate() {
        print("request fastest location update")
        requestLocation(accuracy: kCLLocationAccuracyThreeKilometers)
    }
    
    /// Wrapper for the request to change authorization level of location services.
    ///
    /// - Parameters:
    ///   - isAlwaysUse: represents whether location services should use authorization level .always or .onlyWhenInUse.
    ///   - completion: completion handler for location service authorization level change.
    func requestAuthorization(isAlwaysUse: Bool, completion: ((CLAuthorizationStatus) -> ())? = nil) {
        authorizationCallback = completion
        isAlwaysUseStatusRequested = isAlwaysUse
        let eventAlert: MixpanelEvents = isAlwaysUse ? .viewLocationAlwaysAllowAlert : .viewLocationAccessAlert
        AnalyticsService.shared.track(event: eventAlert.rawValue)
        isAlwaysUse ?  requestAlwaysAuthorization() : requestWhenInUseAuthorization()
    }
    
    /// Wrapper for the request of one-time delivery user's location.
    ///
    /// If AppConfig has a value for customCoordinate, this method will ignore request and tell this location to the delegates.
    ///
    /// - Parameter accuracy: the accuracy of a geographical coordinate.
    private func requestLocation(accuracy: CLLocationAccuracy) {
        // just to save the battery, okay? - in case we got a custom location
        if let customCoordinate = AppConfig.location.customCoordinate {
            let customLocation = CLLocation(latitude: customCoordinate.latitude,
                                            longitude: customCoordinate.longitude)
            locationManager(self, didUpdateLocations: [customLocation])
            stopUpdatingLocation()
            return
        }
        desiredAccuracy = accuracy
        if !isLocationEnabled {
            requestAuthorization(isAlwaysUse: false)
        }
        requestLocation()
    }
    
    /// Wrapper for the reverse geocoding. Returns info about a place based on coordinates.
    ///
    /// - Parameter handler: stores an address string if available.
    func getCurrentAddress(_ handler: @escaping (_ address: String) -> ()) {
        guard let loc = location else { return }
        
        let geocoderHandler: CLGeocodeCompletionHandler = { (placemarks, error) in
            guard let placemark = placemarks?.first else {
                print("geocoderHandler - missing placemark")
                handler("")
                return
            }
            print("geocoderHandler placemark:", placemark)
            if let number = placemark.subThoroughfare, let street = placemark.thoroughfare {
                let address = "\(number) \(street)"
                handler(address)
            } else if let street = placemark.thoroughfare {
                handler(street)
            } else {
                handler("")
            }
        }
        if #available(iOS 11.0, *) {
            geocoder.reverseGeocodeLocation(loc,
                                            preferredLocale: Locale(identifier: "en_US"),
                                            completionHandler: geocoderHandler)
        } else {
            geocoder.reverseGeocodeLocation(loc,
                                            completionHandler: geocoderHandler)
        }
    }
    
    /// Shows if checkin available for the given location.
    ///
    /// - Parameter coordinate: represents destination location.
    /// - Returns: YES if given location is farther than 250 meters to the user's current location, otherwise NO.
    func tooFarForCheckin(_ coordinate: CLLocationCoordinate2D?) -> Bool {
        guard
            let coordinate = coordinate,
            let userLocation = location else
        {
            return true
        }
        let destination = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let distance = userLocation.distance(from: destination)
        return distance > AppConfig.maxDistanceToCheckin // 250 // meters
    }
    
    /// Shows if Uber ride available for the given location.
    ///
    /// - Parameter coordinate: represents destination location.
    /// - Returns: YES if given location is farther than 50_000 meters to the user's current location, otherwise NO.
    func tooFarToRide(_ coordinate: CLLocationCoordinate2D?) -> Bool {
        guard
            let coordinate = coordinate,
            let userLocation = location else { return false }
        let destination = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let distance = userLocation.distance(from: destination)
        return distance > 50_000
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if UIApplication.shared.applicationState == .active {
            QorumNotification.locationUpdated.post()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        QorumNotification.locationChanged.post()
        if let authorizationCallback = authorizationCallback {
            authorizationCallback(status)
        }
        if let isAlwaysUseStatusRequested = isAlwaysUseStatusRequested {
            self.isAlwaysUseStatusRequested = nil
            var response: String
            switch status {
            case .authorizedAlways:
                response = "Always Allow"
            case .authorizedWhenInUse:
                response = isAlwaysUseStatusRequested ? "Only While Using the App" : "Allow"
            case .denied:
                response = "Don’t Allow"
            case .notDetermined:
                response = "Don’t Allow"
            case .restricted:
                response = "Don’t Allow"
            }
            let eventAlert: MixpanelEvents = isAlwaysUseStatusRequested ? .respondToLocationAlwaysAllowAccessAlert : .respondToLocationAccessAlert
            AnalyticsService.shared.track(event: eventAlert.rawValue, properties: ["Response": "\(response)"])
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        SwiftyBeaver.error(error.localizedDescription)
        stopUpdatingLocation()
    }
    
    // MARK: - Monitoring API
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        SwiftyBeaver.info("Did start monitoring for region: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        SwiftyBeaver.warning("Monitoring failed for region: \(String(describing: region?.identifier))")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        SwiftyBeaver.debug("Did enter region: \(region.identifier)")
        
        if UIApplication.shared.applicationState != .active {
            registerBackgroundTask()
        }
        if region is CLBeaconRegion {
            rangeBeaconsIn(region as! CLBeaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        SwiftyBeaver.debug("Did exit region: \(region.identifier)")
        
        if UIApplication.shared.applicationState != .active {
            registerBackgroundTask()
        }
        exitFromRegion()
    }
    
    // MARK: - Ranging API
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        SwiftyBeaver.warning("Failed to range for region: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
        guard let nearestBeacon = beacons.first else { return }
        self.nearestBeacon = nearestBeacon // see the `didSet` property observer
        
        guard let venueToCheckIn = VenueTracker.shared.trackedVenue else {
            SwiftyBeaver.warning("VenueTracker doesn't have a venue to checkin")
            return
        }
        let isAutoCheckInEnabled = UserDefaults.standard.bool(for: .autoOpenTabKey)
        guard isAutoCheckInEnabled else {
            SwiftyBeaver.warning("autoOpenTabKey disabled")
            stopRanging()
            return
        }
        
        guard let checkinRadius = matchingBeacon?.checkinRadius else {
            SwiftyBeaver.warning("Missing checkinRadius for venue: \(venueToCheckIn)")
            return
        }
        
        switch nearestBeacon.accuracy {
        case 0...checkinRadius: // Conditions for checkin
            
            if isRanging {
                
                if let activeCheckin = AppDelegate.shared.checkinHash.values
                    .first(where: { $0.checkout_time == nil && $0.venue?.venue_id == venueToCheckIn.venue_id })
                {
                    SwiftyBeaver.debug("You have an active checkin so we are going to cancel checkout")
                    UserDefaults.standard.set(nil, forKey: UserDefaultsKeys.delayedCheckinId.rawValue)
                    BillWorker().cancelDelayedCheckOut(checkinId: activeCheckin.checkin_id) {_ in
                        VenueTrackerNotifier.notifyOnCheckoutCanceling(for: venueToCheckIn)
                        self.handleCheckIn()
                    }
                } else if let differentVenueActiveCheckin = AppDelegate.shared.checkinHash.values
                    .first(where: { $0.checkout_time == nil && $0.venue?.venue_id != venueToCheckIn.venue_id })
                {
                    SwiftyBeaver.warning("Looks like you're next to the new venue, while you already has an active checkin")
                    // TODO: add checkout from old venue and checkin to another one logic
                } else if venueToCheckIn.isOpen && venueToCheckIn.isActive == true {
                    SwiftyBeaver.debug("Firing checkin")
                    VenueTracker.shared.checkInToVenue(venueToCheckIn)
                }
            }
            
            stopRanging()
            
        default:
            break
        }
    }
    
}
