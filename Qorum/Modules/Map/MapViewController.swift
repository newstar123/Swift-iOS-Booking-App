//
//  MapViewController.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/10/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import GoogleMaps
import MapKit

let kClusterItemCount = 10000

protocol MapDisplayLogic: class {
    func display(viewModel: Map.ViewModel)
}

class MapViewController: BaseViewController, MapDisplayLogic, SBInstantiable {
    
    static let storyboardName = StoryboardName.map
    var interactor: MapBusinessLogic?
    var router: (NSObjectProtocol & MapRoutingLogic & MapDataPassing)?
    var mapItems: [VenueMapItem] = []
    fileprivate var gmuClusterManager: GMUClusterManager!
    
    // MARK: - Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var accountButton: ProfileIconButton!
    @IBOutlet weak var searchBar: QorumSearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var bottomGradientView: GradientView!
    @IBOutlet weak var bottomButtonGradientView: GradientView!
    @IBOutlet weak var listButtonBottom: NSLayoutConstraint!
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = MapInteractor()
        let presenter = MapPresenter()
        let router = MapRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        interactor?.fetchMapItems()
        QorumNotification.selectedCityChanged.add(observer: self, selector: #selector(selectedCityChanged))
        QorumNotification.selectedCityVenuesUpdated.add(observer: self, selector: #selector(venuesUpdated))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        accountButton.badgeView?.isHidden = User.stored.isAllVerified
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        zoomIn()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - MapDisplayLogic
    func display(viewModel: Map.ViewModel) {
        switch viewModel {
        case let .mapItems(items):
            mapItems = items
            zoomIn()
        case .openProfile:
            router?.routeToProfile()
        case .quitGuestMode:
            router?.routeToAuth()
        }
    }
    
    // MARK: - Internal
    
    private func configureView() {
        configureNavigationController()
        if #available(iOS 11, *) {
            let isIphoneX = UIApplication.shared.keyWindow?.safeAreaInsets.bottom != 0
            bottomGradientView.isHidden = !isIphoneX
            bottomButtonGradientView.isHidden = !isIphoneX
            listButtonBottom.constant = isIphoneX ? -22 : -17
        } else {
            bottomGradientView.isHidden = true
            bottomButtonGradientView.isHidden = true
            listButtonBottom.constant = -17
        }
        configureMapView()
        if let cityName = CityManager.shared.selectedCity?.name {
            searchBar.text = cityName
        }
        searchBar.cancelButton.isHidden = true
        searchBar.delegate = self
        searchBar.allSubviews.compactMap({ $0 as? UITextField }).first?.font = UIFont.montserrat.medium(14)
    }
    
    private func configureNavigationController() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func configureMapView() {
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
        
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.delegate = self
        if LocationService.shared.isLocationDisabled {
            LocationService.shared.requestAuthorization(isAlwaysUse: false) {[weak self] (status) in
                self?.mapView.isMyLocationEnabled = status == .authorizedWhenInUse || status == .authorizedAlways
            }
        } else {
            mapView.isMyLocationEnabled = true
        }
        if let initialCity = CityManager.shared.selectedCity ?? CityManager.shared.nearestCity {
            let initialCoordinate = initialCity.location.coordinate
            let initialZoomLevel = kGMSMaxZoomLevel / 2
            let update = GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withTarget: initialCoordinate, zoom: initialZoomLevel))
            mapView.moveCamera(update)
        }
        configureMapClustering()
    }
    
    private func configureMapClustering() {
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        gmuClusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Call cluster() after items have been added to perform the clustering and rendering on map.
        gmuClusterManager.cluster()
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        gmuClusterManager.setDelegate(self, mapDelegate: self)
    }
    
    
    /// Animates map zoom in
    private func zoomIn() {
        showMarkers()
        
        // VR_MARK
        // let city = LocationService.shared.selectedVendorCity
        // let bounds = GMSCoordinateBounds(theLocation: (city?.location)!)
        // let cameraUpdate = GMSCameraUpdate.fit(bounds)
        
        var bounds = GMSCoordinateBounds()
        let selectedCityId = CityManager.shared.selectedCity?.id
        mapItems
            .filter { $0.venue.location_id == selectedCityId }
            .forEach { bounds = bounds.includingCoordinate($0.position) }
        let markerHeight: CGFloat = 34
        let padding: CGFloat = 40
        let cameraUpdate = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: headerView.frame.maxY + markerHeight,
                                                                          left: padding, bottom: listButton.height, right: padding))
        CATransaction.begin()
        CATransaction.setValue(0.8, forKey: kCATransactionAnimationDuration)
        CATransaction.setValue(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), forKey: kCATransactionAnimationTimingFunction)
        mapView.animate(with: cameraUpdate)
        CATransaction.commit()
    }
    
    
    /// Animates map zoom out
    private func zoomOut() {
        CATransaction.begin()
        CATransaction.setValue(0.8, forKey: kCATransactionAnimationDuration)
        CATransaction.setValue(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), forKey: kCATransactionAnimationTimingFunction)
        mapView.animate(toZoom: kGMSMaxZoomLevel/2)
        CATransaction.commit()
    }
    
    /// Updates Map clusters
    func showMarkers() {
        gmuClusterManager.clearItems()
        mapItems.forEach { gmuClusterManager.add($0) }
    }
    
    @objc func navigateBack() {
        router?.routeToVenues()
    }
    
    /// Focuses on newely selected city
    @objc func selectedCityChanged() {
        let city = CityManager.shared.selectedCity
        searchBar.text = city?.name ?? ""
        zoomIn()
    }
    
    /// Asks interactor to update list of venues
    @objc func venuesUpdated() {
        interactor?.fetchMapItems()
    }
    
    // MARK: - Actions
    
    @IBAction func listButtonPressed(_ sender: Any) {
        zoomOut()
        self.perform(#selector(navigateBack), with: nil, afterDelay: 0.8)
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        interactor?.openProfile()
    }
    
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let _marker = marker as? VenueMarker {
            let venue = _marker.venue
            let trackProperties: [String: Any] = ["Venue Name": venue.name,
                                                  "Discount": venue.discountValue,
                                                  "Market": venue.market?.name ?? "",
                                                  "Neighborhood": venue.neighborhood ?? "",
                                                  "Venue View": "Map"]
            AnalyticsService.shared.track(event: MixpanelEvents.venueSelected.rawValue,
                                          properties: trackProperties)
            
            router?.routeToVenueDetails(venue: _marker.venue)
        }
        return true
    }
    
}

// MARK: - GMSCircle
extension GMSCoordinateBounds {
    
    convenience init(theLocation: CLLocation) {
        let center = theLocation.coordinate
        let radius: Double = 3*1000
        
        let region = MKCoordinateRegionMakeWithDistance(center, radius*2, radius*2)
        
        let northEast = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2,
                                                   region.center.longitude - region.span.longitudeDelta/2)
        let southWest = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2,
                                                   region.center.longitude + region.span.longitudeDelta/2)
        
        self.init(coordinate: northEast, coordinate: southWest)
    }
}

// MARK: - QorumSearchBarDelegate
extension MapViewController: QorumSearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: QorumSearchBar) -> Bool {
        let searchVC = SearchViewController.fromStoryboard
        present(searchVC, animated: true, completion: nil)
        return false
    }
    
    func searchBarLocationButtonClicked(_ searchBar: QorumSearchBar) {
        CityManager.shared.selectNearestCity()
    }
    
}

// MARK: - GMUClusterManagerDelegate, GMUClusterRendererDelegate
extension MapViewController: GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    
    /**
     * Creates map objects grouped by locations
     */
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        var bounds = GMSCoordinateBounds()
        cluster.items.forEach {
            bounds = bounds.includingCoordinate($0.position)
        }
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 40))
        return true
    }
    
    /**
     * Renders map markers for venues group or single venue.
     */
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        let preferAddresses = false
        switch object {
        case let venueItem as VenueMapItem:
            return VenueMarker(with: venueItem.venue,
                               preferAddresses: preferAddresses)
        case let cluster as GMUStaticCluster:
            return ClusterMarker(with: cluster.count)
        default:
            print("GMUClusterRenderer marker for object:\n", object)
            return nil
        }
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        switch marker.iconView {
        case let container as MarkerContainerView:
            marker.groundAnchor = container.groundAnchor
        default:
            break
        }
    }
    
}

