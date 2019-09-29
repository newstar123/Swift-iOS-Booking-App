//
//  UberDetailController.swift
//  Qorum
//
//  Created by Michael Wilson on 10/26/15.
//  Copyright © 2015 Qorum. All rights reserved.
//

import Foundation
import MapKit
import GoogleMaps
import UberRides
import GooglePlaces
import GooglePlacePicker
import KDLoadingView

class UberDetailController: UIViewController, UIAlertViewDelegate, GMSMapViewDelegate, UITextFieldDelegate {

    // MARK: - Properties
//    var tableview:UITableView!
    var productsCollectionView:UICollectionView!
    var estimatesContainer = UIView(frame: CGRect(x: 0, y: .deviceHeight - 370, width: .deviceWidth, height: 370))
    var backgroundImage:UIImageView!
    var nameLabel = UILabel()
    let addressesView = UIView()
//    var venue:Venue?
    var selectedUberEstimate:UberEstimate?
    var rideFromVenue = false
    var freeRide = false
    var adImageView = UIImageView()
    var timeLabel = UILabel()
    var uberTypeName = UILabel()
    var uberTypeTagline = UILabel()
    var pickupMarker = GMSMarker()
    var destinationMarker = GMSMarker()
    let directionPolyline = GMSPolyline()
//    let mapResultsView = MapResultsView(frame: CGRect(x: 0, y: .deviceHeight - 430, width: .deviceWidth, height: 370), style: .plain)
    var location: Location? { didSet { locationPicked() } }
    var checkin: Checkin?
    //var products: [UberProduct] = [UberProduct]()
    var classes: [UberClass] = []
    var isShowingAddresses: Bool = false
    var selectedType: UberType?
    var seatsCount: Int?
    
    
    //New properties
    weak var pageController: UberTypesPageController!
    @IBOutlet weak var uberGroupsView: UberGroupButtonsView!
    @IBOutlet weak var uberAdressesView: UberAdressesView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var typeDetails: UberTypeDetailsView!
    @IBOutlet weak var searchResultsContainer: AddressSearchResultsContainer!
    @IBOutlet weak var poolSeatsView: PoolSeatSelectionView!
    @IBOutlet weak var typesLoaderView: KDLoadingView!
    @IBOutlet weak var estimatedArrivalLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    
    @IBOutlet weak var typeDetailsBottom: NSLayoutConstraint!
    @IBOutlet weak var adTopOffset: NSLayoutConstraint!
    @IBOutlet weak var timeXPosition: NSLayoutConstraint!
    @IBOutlet weak var typesViewBottom: NSLayoutConstraint!
    @IBOutlet weak var typesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var confirmViewBottom: NSLayoutConstraint!

    // MARK: - Init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init () {
        self.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAddresses()
        addMapStyle()
        setupTypes()
        adjustWithVenue()
        
        poolSeatsView.delegate = self
        
        let backButton = self.backButton
        
        let img = backButton.currentImage?.withRenderingMode(.alwaysTemplate)
        backButton.imageView?.tintColor = .black
        backButton.setImage(img, for: UIControlState())
        self.view.addSubview(backButton)
        
        logInUber()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backButton.y = 20
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if typesViewBottom.constant != 0 {
            showAnimatedAppereance()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    override func backButtonPressed() {
        if isShowingAddresses {
            uberAdressesView.deactivate()
        } else {
            navigationController?.isNavigationBarHidden = true
            navigationController?.popViewController(animated: true)
        }
    }
    
    func showAnimatedAppereance() {
        typesViewBottom.constant = 0
        UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
            /*self.uberGroupsView.show()
             self.pageController.show()*/
            self.uberAdressesView.show()
            if !self.rideFromVenue {
                self.showTypesLoader()
                self.setCurrentAddress()
            }
        }
        
        adTopOffset.constant = 24.5
        UIView.animate(withDuration: 0.2, delay: 0.6, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in }
    }
    
    func showTypesLoader() {
        self.typesLoaderView.isHidden = false
        self.typesLoaderView.startAnimating()
        timeXPosition.constant = -110
        estimatedArrivalLabel.text = ""
        orderButton.setTitle("REQUEST UBER", for: .normal)
        UIView.animate(withDuration: 0.2, delay: 0.6, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in }
    }
    
    func hideTypesLoader() {
        self.typesLoaderView.stopAnimating()
        self.typesLoaderView.isHidden = true
    }
    
    // MARK: - Setup
    func setupAddresses() {
        self.uberAdressesView.setup(for: rideFromVenue, venue: venue!)
    }
    
    func addMapStyle() {
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "UberMapStyle", withExtension: "json") {
                self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        mapView.padding = UIEdgeInsetsMake(100, 10, 330, 10)
    }
    
    func setupTypes() {
        pageController = self.childViewControllers.first as! UberTypesPageController
        pageController.uberController = self
        uberGroupsView.pageController = pageController
        
        /*uberGroupsView.uberClasses = types
        pageController.uberClasses = types*/
    }
    
    func updateClasses() {
        uberGroupsView.uberClasses = self.classes
        pageController.uberClasses = self.classes
        
        self.uberGroupsView.show()
        self.pageController.show()
        self.hideTypesLoader()
    }
    
    //MARK: - Animations
    func showAds() {
        adTopOffset.constant = 24.5
        if selectedType != nil { timeXPosition.constant = 15 }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in }
    }
    
    func hideAds() {
        adTopOffset.constant = -110
        timeXPosition.constant = -110
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in }
    }
    
    @IBAction func swipteNextTypes() {
        pageController.next()
    }
    
    @IBAction func swipePrevTypes() {
        pageController.prev()
    }
    
    func showAddresses() {
        guard self.typesLoaderView.isHidden else {
            return
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reloadTypes), object: nil)
        
        uberAdressesView.activate()
        
        hideAds()
        self.hideTypes()
        
        self.isShowingAddresses = true
//        self.backButton.isHidden = true
        
        typesViewHeight.constant = .deviceHeight
        self.backButton.isEnabled = false
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.setNeedsStatusBarAppearanceUpdate()
            self.backButton.imageView?.tintColor = .white
        }) { (completed) in
            self.backButton.isEnabled = true
            self.searchResultsContainer.isHidden = false
            self.searchResultsContainer.alpha = 1
        }
    }
    
    func hideAddresses() {
        searchResultsContainer.hide()
        
        self.isShowingAddresses = false
        typesViewHeight.constant = 327
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.setNeedsStatusBarAppearanceUpdate()
            self.backButton.imageView?.tintColor = .black
        }) { (completed) in
            self.showAds()
            /*self.uberGroupsView.show()
            self.pageController.show() */
            self.loadPlace()
        }
    }
    
    // MARK: - Subviews
    func showTypeDetails(type: UberType) {
        typeDetails.freeRide = self.freeRide
        typeDetails.positionImage(image: pageController.selectedView())
        pageController.selectedView().isHidden = true
        typeDetails.animateAppereance()
        typeDetails.showWithType(type: type)
        typeDetailsBottom.constant = 0
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveLinear, animations: {
            self.view.layoutIfNeeded()
        })  { (completed) in
            
        }
    }
    
    //MARK: - Uber Functionality
    func loadPlace() {
        guard searchResultsContainer.lastSelectedPlacePrediction?.placeID != nil else {
//            if let coordinates = self.location?.coordinate, let name = self.location?.name {
//                self.location = Location(name: name, coordinate: coordinates)
//            }
            if let loc = self.location, uberAdressesView.activeFieldText() != "" {
                self.perform(#selector(self.reloadTypes), with: nil, afterDelay: 30)
                self.updateClasses()
            }
            
            return
        }
        
        GMSPlacesClient().lookUpPlaceID((searchResultsContainer.lastSelectedPlacePrediction?.placeID)!) { (place, error) in
            guard place != nil else {
                return
            }
            
            self.location = Location(name: (place?.formattedAddress)!, coordinate: (place?.coordinate)!)
            print(place)
        }
    }
    
    func selectUber(type: UberType) {
        guard isShowingAddresses == false else {
            return
        }
        
        if type.name.lowercased() != "pool" {
            seatsCount = nil
        }
        
        selectedType = type
        estimatedArrivalLabel.text = String(describing: Int(type.estimate!.pickupEstimate))
        orderButton.setTitle("REQUEST \(type.name!)", for: .normal)
        
        timeXPosition.constant = 15
        UIView.animate(withDuration: 0.2, delay: 0.6, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in }
    }

    // MARK: -
    func adjustWithVenue() {
//        if !rideFromVenue {
//            //setCurrentAddress()
//        } else {
//            
//        }
        
        adjustMap()
    }
    
    func adjustMap() {
        if let coordinate = checkin?.venue.coordinate, let place = location {
            let pickupCoordinate = rideFromVenue ? coordinate : place.coordinate
            let destinationCoordinate = rideFromVenue ? place.coordinate : coordinate
        
            pickupMarker.position = pickupCoordinate
            pickupMarker.snippet = place.name
            pickupMarker.icon = UIImage(named: rideFromVenue ? "Venue_Start_Icon" : "User_Start_Icon")
            pickupMarker.map = mapView
            pickupMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5);

            destinationMarker.position = destinationCoordinate
            destinationMarker.snippet = checkin?.venue.address != nil ? checkin?.venue.address : checkin?.venue.name
            destinationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5);
            destinationMarker.icon = UIImage(named: rideFromVenue ? "User_Finish_Icon" : "Venue_Finish_Icon")
            destinationMarker.map = mapView
            self.mapView.isMyLocationEnabled = true
            
            var bounds = GMSCoordinateBounds(coordinate: pickupCoordinate, coordinate: destinationCoordinate)
            let cameraDestUpdate = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(40, 40, 40, 40))
            self.mapView.animate(with: cameraDestUpdate)
            
            QorumAPIClient.sharedInstance.loadRoute(from: pickupCoordinate, to: destinationCoordinate, handler: { (direction, error) in
                guard direction?.status != "ZERO_RESULTS" && direction?.status != "OVER_QUERY_LIMIT" else {
                    self.noUberEstimatesAlert()
                    return
                }
                
                if self.selectedType?.name.lowercased() == "pool" {
                    self.directionPolyline.map = nil
                    return
                }
                
                let path = direction?.path()
                bounds = bounds.includingPath(path!)
                
                let cameraDestUpdate = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(40, 40, 40, 40))
                self.mapView.animate(with: cameraDestUpdate)
                    
                self.pickupMarker.position = (path?.coordinate(at: 0))!
                self.destinationMarker.position = (path?.coordinate(at: (path?.count())!-1))!
                
                self.directionPolyline.path = path
                self.directionPolyline.strokeWidth = 4;
                self.directionPolyline.zIndex = 1;
                
                let bluredColor = GMSStrokeStyle.gradient(from: UIColor(red: 104/255.0, green: 190/255.0, blue: 104/255.0, alpha: 1.0), to: UIColor(red: 0/255.0, green: 171/255.0, blue: 221/255.0, alpha: 1.0))
                self.directionPolyline.spans = [GMSStyleSpan(style: bluredColor)]
                
                self.directionPolyline.map = self.mapView;
            })
            
        } else if let coordinate = checkin?.venue?.coordinate {
            let cameraPickUpdate = GMSCameraUpdate.setTarget(coordinate)
            
            mapView.animate(with: cameraPickUpdate)
            mapView.animate(toZoom: 14)
            
            let marker = GMSMarker()
            marker.position = coordinate
            marker.snippet = venue!.name
            marker.icon = UIImage(named: rideFromVenue ? "Venue_Start_Icon" : "Venue_Finish_Icon")
            marker.map = mapView
            if rideFromVenue {
                marker.groundAnchor = CGPoint(x: 0.5, y: 0.5);
                pickupMarker = marker
            } else {
                destinationMarker = marker
            }
        }
    }
    
    func setCurrentAddress() {
        if !rideFromVenue {
            LocationManager.sharedManager.getCurrentAddress({ address in
                if let coordinate = LocationManager.sharedManager.coordinates {
                    self.location = Location(name: address, coordinate: coordinate)
                }
            })
        }
    }
    
    @objc func reloadTypes() {
        self.hideTypes()
        self.locationPicked()
    }
    
    func hideTypes() {
        self.uberGroupsView.hide()
        self.pageController.hide()
    }
    
    func locationPicked() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reloadTypes), object: nil)
        if let place = location {
//            if !rideFromVenue {
            if rideFromVenue {
                uberAdressesView.bottomField.text = place.name
            } else {
                uberAdressesView.topField.text = place.name
            }
            adjustMap()
            
            if let venue = venue, let venueCoordinate = venue.coordinate, let _ = UberController.sharedController.user_token {
                self.checkin?.venue.uberEstimates = []
                self.showTypesLoader()
                    
                UberController.sharedController.getProducts(startLocation: pickupMarker.position, finishLocation: destinationMarker.position, handler: { (success, classes) in
                    if success {
                        DispatchQueue.main.async {
                            guard classes.count > 0 else {
                                self.noUberEstimatesAlert()
                                return
                            }
                                
                            self.classes = classes
                            self.updateClasses()
                            if self.view.window != nil { self.perform(#selector(self.reloadTypes), with: nil, afterDelay: 60) }
                        }
                    } else {
                        self.hideTypesLoader()
                        print("dt_error_getProducts")
                    }
                })
            }
        }
    }
    
    func noUberEstimatesAlert() {
        let alert = UIAlertController(title: "Could not load Uber", message: "Could not load Uber for selected route. Please check route points", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        topVC().present(alert, animated: true, completion: nil)
        
        self.hideTypes()
        self.hideTypesLoader()
    }
    
    func authorizeReturn(_ token: String) {
        QorumAPIClient.sharedInstance.registerUberToken(token) { accessToken in
            UberController.sharedController.user_token = UberToken(acessToken: accessToken, refreshToken: nil, expiresIn: nil)
            let uberToken = NSKeyedArchiver.archivedData(withRootObject: UberToken(acessToken: accessToken, refreshToken: nil, expiresIn: nil))
            UserDefaults.standard.set(uberToken, forKey: "UberToken")
            self.locationPicked()
        }
    }
    
    func showUberAd() {
        let uberAdController = UberAdController()
        uberAdController.uberData = UberRequestData(type: selectedType!,
                                                    pickup: pickupMarker.position,
                                                    dropoff: destinationMarker.position,
                                                    pickupAddress: uberAdressesView.topField.text,
                                                    dropoffAddress: uberAdressesView.bottomField.text,
                                                    seatsCount: seatsCount,
                                                    fromVenue: rideFromVenue)
        uberAdController.checkin = checkin
        uberAdController.rideFromVenue = rideFromVenue
        navigationController?.pushViewController(uberAdController, animated: true)
    }
    
    func logInUber() {
        guard UberController.sharedController.user_token == nil else {
            self.locationPicked()
            return
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.uberDetailController = self
        }
        
        let loginManager = LoginManager(loginType: .authorizationCode)
        loginManager.login(requestedScopes:[.Request, .Profile, .RequestReceipt], presentingViewController: self, completion: { accessToken, error in
            print(error)
            if let error = error {
                print(error)
                let alert = UIAlertController(title: "Uber authorization error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                    
                topVC().present(alert, animated: true, completion: nil)
            } else if let tokenString = accessToken?.tokenString {
                UberController.sharedController.user_token = UberToken(accessToken: accessToken)
                self.locationPicked()
            }
        })
    }
    
    @IBAction func didTapOrder() {
        if selectedType != nil {
            if selectedType?.name.lowercased() == "pool" && seatsCount == nil {
                poolSeatsView.formattPrice()
                poolSeatsView.isHidden = false
            } else {
                showOrderConfirmation()
            }
        }
    }
    
    func showOrderConfirmation() {
        showUberAd()
    }

    override var prefersStatusBarHidden : Bool {
        return false
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        if isShowingAddresses {
            return .lightContent
        } else {
            return.default
        }
    }
    
}

extension UberDetailController: PoolSeatSelectionViewDelegate {
    
    func didSelectSeatsCount(count: Int) {
        seatsCount = count
        poolSeatsView.isHidden = true
        didTapOrder()
    }
    
}


