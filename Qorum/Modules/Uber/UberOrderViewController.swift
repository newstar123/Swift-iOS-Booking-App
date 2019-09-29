//
//  UberOrderViewController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/04/17.
//  Copyright © 2015 Qorum. All rights reserved.
//

import Foundation
import MapKit
import GoogleMaps
import UberRides
import UberCore
import GooglePlaces
import Mixpanel
import SDWebImage

protocol UberOrderDisplayLogic: class {
    
    func showAuthError(_ error: NSError)
    func authorizeReturn(_ token: String)
    
}

enum QorumRideType {
    case from
    case to
    case free
}

class UberOrderViewController: BaseViewController, SBInstantiable {
    static let storyboardName = StoryboardName.uberOrder
    
    // MARK: - Properties
    var interactor: UberOrderBusinessLogic?
    var router: (NSObjectProtocol & UberOrderRoutingLogic & UberOrderDataPassing)?
    
    var productsCollectionView:UICollectionView!
    var estimatesContainer = UIView(frame: CGRect(x: 0, y: .deviceHeight - 370, width: .deviceWidth, height: 370))
    var backgroundImage:UIImageView!
    var nameLabel = UILabel()
    let addressesView = UIView()
    var selectedUberEstimate:UberEstimate?
    var rideType: QorumRideType = .to
    var freeRide = false
    var adImageView = UIImageView()
    var timeLabel = UILabel()
    var uberTypeName = UILabel()
    var uberTypeTagline = UILabel()
    var pickupMarker = GMSMarker()
    var destinationMarker = GMSMarker()
    let directionPolyline = GMSPolyline()
    var location: Location? { didSet { locationPicked() } }
    var destinationLocation: Location? { didSet { locationPicked() } }
    var checkin: Checkin?
    var venue: Venue?
    var classes: [UberClass] = []
    var isShowingAddresses: Bool = false
    var selectedType: UberType?
    var seatsCount: Int?
    var iphoneXFixBot: CGFloat { return UIApplication.shared.safeAreaInsets.bottom }
    
    //New properties
    weak var pageController: UberTypesPageController!
    @IBOutlet weak var uberGroupsView: UberGroupButtonsView!
    @IBOutlet weak var uberAdressesView: UberAdressesView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var typeDetails: UberTypeDetailsView!
    @IBOutlet weak var searchResultsContainer: AddressSearchResultsContainer!
    @IBOutlet weak var poolSeatsView: PoolSeatSelectionView!
    @IBOutlet weak var typesLoaderView: QorumLoadingView!
    @IBOutlet weak var estimatedArrivalLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var adView: UIImageView!
    
    @IBOutlet weak var backButtonTop: NSLayoutConstraint!
    @IBOutlet weak var typeDetailsBottom: NSLayoutConstraint!
    @IBOutlet weak var timeXPosition: NSLayoutConstraint!
    @IBOutlet weak var typesViewBottom: NSLayoutConstraint!
    @IBOutlet weak var typesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var confirmViewBottom: NSLayoutConstraint!
    @IBOutlet weak var orderUberBottom: NSLayoutConstraint!
    
    // MARK: - Object lifecycle
    deinit {
        print("Deinit uber")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    convenience init () {
        self.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let viewController = self
        let interactor = UberOrderInteractor()
        let presenter = UberOrderPresenter()
        let router = UberOrderRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    override var backgroundStyle: BaseViewController.BackgroundAppearance {
        return .empty
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if venue == nil, checkin?.venue != nil {
            venue = checkin?.venue
        }
        
        self.freeRide = checkin?.ridesafeStatus?.isFreeRideAvailable == true
        
        if let adPhotoURL = UserDefaults.standard.advertUberPhotoURL(rideFromVenue: rideType == .from,
                                                                     freeRide: freeRide)
        {
            adView.sd_setImage(with: adPhotoURL, completed: nil)
        }
        
        setupAddresses()
        addMapStyle()
        setupTypes()
        adjustMap()
        
        poolSeatsView.delegate = self
        
        view.setNeedsLayout()
        view.layoutIfNeeded() // to update adView's layout parameters
        backButtonTop.constant = adView.height + adView.y + 27
        backButton.tintColor = .black
        backButton.setTitleColor(.black, for: .normal)
        
        orderUberBottom.constant = iphoneXFixBot + 5
        typesViewHeight.constant = 300 + iphoneXFixBot
        typesViewBottom.constant -= iphoneXFixBot
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if typesViewBottom.constant != 0 {
            showAnimatedAppereance()
        }
        // TODO: - will need to remove this on production - ask @sshemiakov
        if AppConfig.uberSandboxModeEnabled {
            UberAPI.cancelUber(requestId: "current").perform { _ in }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Setup
    func setupAddresses() {
        self.uberAdressesView.setup(for: self.rideType, venue: venue!)
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
        
        mapView.padding = UIEdgeInsetsMake(17, 10, 300+iphoneXFixBot, 10)
    }
    
    func setupTypes() {
        pageController = childViewControllers.find(UberTypesPageController.self)
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
        //let types = self.classes.map({ $0.types.map({ $0.name }) })
    }
    
    //MARK: - Animations
    func showAnimatedAppereance() {
        typesViewBottom.constant = 0
        UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
            /*self.uberGroupsView.show()
             self.pageController.show()*/
            self.uberAdressesView.show()
            if self.rideType == .to {
                self.showTypesLoader()
                self.setCurrentAddress()
            } else if self.rideType == .free {
                self.setCurrentAddress()
            }
        }
        
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
    
    func checkTime() {
        if selectedType != nil, selectedType!.estimate?.pickupEstimate != nil { timeXPosition.constant = 15 }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in }
    }
    
    func hideAds() {
        timeXPosition.constant = -110
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in }
    }
    
    //MARK: - Actions
    
    @IBAction func backButtonPressed() {
        if isShowingAddresses {
            uberAdressesView.deactivate()
        } else if poolSeatsView.isHidden == false {
            poolSeatsView.isHidden = true
            seatsCount = nil
        } else {
            navigationController?.isNavigationBarHidden = true
            router?.routeBack()
        }
    }
    
    func showTypeDetails(type: UberType) {
        typeDetails.discountAmount = Double(checkin?.uberDiscountValue ?? 0)
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
    
    @IBAction func didTapOrder() {
        if selectedType != nil {
            if selectedType?.name.lowercased() == "pool" && seatsCount == nil {
                poolSeatsView.discountAmount = Double(checkin?.uberDiscountValue ?? 0)
                poolSeatsView.formattPrice()
                poolSeatsView.isHidden = false
            } else {
                showOrderConfirmation()
            }
        }
    }
    
    func showAddresses(selectingTop: Bool? = false) {
        guard self.typesLoaderView.isHidden else {
            return
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reloadTypes), object: nil)
        
        uberAdressesView.activate(selectingTop: selectingTop)
        
        hideAds()
        self.hideTypes()
        
        self.isShowingAddresses = true
        
        backButtonTop.constant = 10
        typesViewHeight.constant = .deviceHeight
        self.backButton.isEnabled = false
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.backButton.tintColor = .white
            self.backButton.setTitleColor(.white, for: .normal)
        }) { (completed) in
            self.backButton.isEnabled = true
            self.searchResultsContainer.isHidden = false
            self.searchResultsContainer.alpha = 1
        }
    }
    
    func hideAddresses() {
        searchResultsContainer.hide()
        
        self.isShowingAddresses = false
        
        backButtonTop.constant = adView.height + 27
        typesViewHeight.constant = 300 + iphoneXFixBot
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.backButton.tintColor = .black
            self.backButton.setTitleColor(.black, for: .normal)
        }) { (completed) in
            self.checkTime()
            /*self.uberGroupsView.show()
             self.pageController.show() */
            self.loadPlace()
        }
    }
    
    //MARK: - Uber Functionality
    func logInUber() {
        guard interactor?.user_token == nil else {
            self.locationPicked()
            return
        }
        
        interactor?.authorizeUber()
    }
    
    func loadPlace() {
        guard searchResultsContainer.lastSelectedPlacePrediction?.placeID != nil else {
            if let _ = self.location, uberAdressesView.activeFieldText() != "" {
                self.perform(#selector(self.reloadTypes), with: nil, afterDelay: 30)
                self.updateClasses()
            }
            
            return
        }
        
        GMSPlacesClient().lookUpPlaceID((searchResultsContainer.lastSelectedPlacePrediction?.placeID)!) { (place, error) in
            guard place != nil else {
                return
            }
            
            guard self.rideType != .free else {
                if self.uberAdressesView.isEditingTop {
                    self.location = Location(name: (place?.formattedAddress)!, coordinate: (place?.coordinate)!)
                } else {
                    self.destinationLocation = Location(name: (place?.formattedAddress)!, coordinate: (place?.coordinate)!)
                }
                return
            }
            self.location = Location(name: (place?.formattedAddress)!, coordinate: (place?.coordinate)!)
            print(place ?? "place is empty")
        }
    }
    
    func selectUber(type: UberType) {
        guard isShowingAddresses == false else {
            return
        }
        
        if type.name.lowercased() != "pool" && type.name.lowercased() != "uberpool" {
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
    
    func showUberAd() {
        //AnalyticsService.shared.track(event: MixpanelEvents.orderUberPressed.rawValue,
        //                              properties: ["type": selectedType?.name ?? "",
        //                                           "isFree": freeRide])
        let adController = UberAdController()
        adController.venue = venue
        router?.navigateToAd(source: self, destination: adController)
    }
    
    func showOrderConfirmation() {
        showUberAd()
    }
    
    // MARK: - Update map
    func adjustMap() {
        if let coordinate = venue?.coordinate, let place = location, (self.rideType != .free || self.destinationLocation != nil) {
            var pickupCoordinate: CLLocationCoordinate2D
            var destinationCoordinate: CLLocationCoordinate2D
            
            switch self.rideType {
            case .from:
                pickupCoordinate = coordinate
                destinationCoordinate = place.coordinate
            case .to:
                pickupCoordinate = place.coordinate
                destinationCoordinate = coordinate
            case .free:
                pickupCoordinate = place.coordinate
                destinationCoordinate = self.destinationLocation!.coordinate
                break
            }
            
            updateMarkers(pickup: pickupCoordinate, destination: destinationCoordinate, place: place)
            updateCamera(with: GMSCoordinateBounds(coordinate: pickupCoordinate, coordinate: destinationCoordinate))
            self.mapView.isMyLocationEnabled = true
            
            interactor?.loadRoute(from: pickupCoordinate, to: destinationCoordinate) { (result) in
                switch result {
                case let .value(direction):
                    guard let path = direction.path() else {
                        self.noUberEstimatesAlert(status: direction.status)
                        return
                    }
                    
                    //if self.selectedType?.name.lowercased() == "pool" || self.selectedType?.name.lowercased() == "uberpool" {
                    //    self.directionPolyline.map = nil
                    //    return
                    //}
                    
                    self.updateCamera(with:GMSCoordinateBounds(path: path))
                    
                    self.pickupMarker.position = path.coordinate(at: 0)
                    self.destinationMarker.position = path.coordinate(at: path.count()-1)
                    
                    self.updateDirection(with: path)
                case let .error(error):
                    print("UberOrderViewController adjustMap - interactor loadRoute error:", error)
                }
            }
        } else if let coordinate = venue?.coordinate, self.rideType != .free {
            let cameraPickUpdate = GMSCameraUpdate.setTarget(coordinate)
            
            mapView.animate(with: cameraPickUpdate)
            mapView.animate(toZoom: 12)
            
            let marker = GMSMarker()
            marker.position = coordinate
            marker.snippet = venue!.name
            
            switch self.rideType {
            case .from:
                marker.icon = UIImage(named: "Venue_Start_Icon")
            case .to:
                marker.icon = UIImage(named: "Venue_Finish_Icon")
            default:
                break
            }
            
            marker.map = mapView
            if self.rideType == .from {
                marker.groundAnchor = CGPoint(x: 0.5, y: 0.5);
                pickupMarker = marker
            } else {
                destinationMarker = marker
            }
        } else if self.rideType == .free, let place = self.location {
            let cameraPickUpdate = GMSCameraUpdate.setTarget(place.coordinate)
            
            mapView.animate(with: cameraPickUpdate)
            mapView.animate(toZoom: 12)
            
            let marker = GMSMarker()
            marker.position = place.coordinate
            marker.snippet = place.name
            marker.icon = UIImage(named: "User_Start_Icon")
            
            marker.map = mapView
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5);
            pickupMarker = marker
        }
    }
    
    func updateMarkers(pickup: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, place: Location) {
        pickupMarker.position = pickup
        pickupMarker.snippet = place.name
        pickupMarker.map = mapView
        pickupMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        
        destinationMarker.position = destination
        destinationMarker.snippet = venue?.address != nil ? venue!.address : venue!.name
        destinationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        destinationMarker.map = mapView
        
        switch self.rideType {
        case .from:
            pickupMarker.icon = UIImage(named: "Venue_Start_Icon")
            destinationMarker.icon = UIImage(named: "User_Finish_Icon")
        case .to:
            pickupMarker.icon = UIImage(named: "User_Start_Icon")
            destinationMarker.icon = UIImage(named: "Venue_Finish_Icon")
        case .free:
            pickupMarker.icon = UIImage(named: "User_Start_Icon")
            destinationMarker.icon = UIImage(named: "User_Finish_Icon")
        }
    }
    
    func updateDirection(with path: GMSPath) {
        self.directionPolyline.path = path
        self.directionPolyline.strokeWidth = 4
        self.directionPolyline.zIndex = 1
        
        let bluredColor = GMSStrokeStyle.gradient(from: UIColor(in8bit: 104, 190, 104),
                                                  to: UIColor(in8bit: 0, 171, 221))
        self.directionPolyline.spans = [GMSStyleSpan(style: bluredColor)]
        self.directionPolyline.map = self.mapView
    }
    
    func updateCamera(with bounds: GMSCoordinateBounds) {
        let cameraDestUpdate = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(50, 0, 30, 0))
        self.mapView.animate(with: cameraDestUpdate)
    }
    
    func setCurrentAddress() {
        if rideType == .from { return }
        LocationService.shared.getCurrentAddress { address in
            if let coordinate = LocationService.shared.location?.coordinate {
                self.location = Location(name: address, coordinate: coordinate)
            }
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
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.reloadTypes),
                                               object: nil)
        guard let place = location else {
            return
        }
        
        switch self.rideType {
        case .from:
            uberAdressesView.bottomField.text = place.name
        case .to:
            uberAdressesView.topField.text = place.name
        case .free:
            uberAdressesView.topField.text = place.name
            if self.destinationLocation != nil {
                uberAdressesView.bottomField.text = self.destinationLocation!.name
            } else {
                adjustMap()
                return
            }
        }
        
        adjustMap()
        guard
            let _ = venue,
            interactor?.user_token?.accessToken != nil else
        {
            self.logInUber()
            return
        }
        showTypesLoader()
        interactor?.getProducts(from: pickupMarker.position, to: destinationMarker.position) { [weak self] result in
            switch result {
            case let .value(classes):
                DispatchQueue.main.async {
                    guard classes.isNotEmpty else {
                        self?.noUberEstimatesAlert(status: "Missing Uber classes")
                        return
                    }
                    self?.classes = classes
                    self?.updateClasses()
                    if self?.view.window != nil {
                        self?.perform(#selector(self?.reloadTypes), with: nil, afterDelay: Time(1, .minutes)[in: .seconds])
                    }
                }
            case let .error(error):
                print("UberOrderViewController locationPicked - interactor getProducts error:", error)
                self?.hideTypesLoader()
                switch error {
                case let genericError as GenericError:
                    UIAlertController.presentAsAlert(title: "Getting Uber products failure: \(genericError.title) (status \(genericError.status))", message: genericError.detail.description)
                case let stringError as String:
                    UIAlertController.presentAsAlert(message: stringError)
                default:
                    UIAlertController.presentAsAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func noUberEstimatesAlert(status: String?) {
        var message = "Could not load Uber for selected route."
        if let status = status, AppConfig.developerModeEnabled {
            message.append("\nStatus: \(status)\n[Developer Mode info]")
        } else {
            message.append(" Please check route points")
        }
        UIAlertController.presentAsAlert(title: "Could not load Uber",
                                         message: message)
        hideTypes()
        hideTypesLoader()
    }
    
}

// MARK: - UberOrderDisplayLogic
extension UberOrderViewController: UberOrderDisplayLogic {
    
    func authorizeReturn(_ token: String) {
        interactor?.registerUberToken(authorizationCode: token) { result in
            switch result {
            case let .value(accessToken):
                print(accessToken)
                self.locationPicked()
            case let .error(error):
                print("UberOrderViewController authorizeReturn error: \(error)")
            }
        }
    }
    
    func showAuthError(_ error: NSError) {
        let okAction: UIAlertController.CustomAction
        okAction = ("OK", .cancel, { [weak router] in router?.routeBack() })
        UIAlertController.presentAsAlert(title: "Uber authorization error",
                                         message: error.localizedDescription,
                                         actions: [okAction])
    }
    
}

// MARK: - PoolSeatSelectionViewDelegate
extension UberOrderViewController: PoolSeatSelectionViewDelegate {
    
    func didSelectSeatsCount(count: Int) {
        seatsCount = count
        poolSeatsView.isHidden = true
        didTapOrder()
    }
    
}



