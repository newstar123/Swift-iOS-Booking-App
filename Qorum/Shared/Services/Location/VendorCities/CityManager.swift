//
//  CityManager.swift
//  Qorum
//
//  Created by Stanislav on 10/9/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

/// Vendor cities manager
class CityManager {
    
    static let shared = CityManager()
    
    /// Storage for the selected city object.
    ///
    /// The default value is .nearestStored.
    ///
    /// If the newValue is not equals to the previous, than the selectedCityChanged notification will be sended for the receivers... and if selected city is equals to the nearest city, than this city stores in the UserDefaults.
    var selectedCity: VendorCity? = .nearestStored {
        didSet {
            if oldValue != selectedCity {
                QorumNotification.selectedCityChanged.post()
                if isNearestCitySelected {
                    selectedCity?.save()
                }
            }
        }
    }
    
    /// Represents a boolean value that defines whether the selected city is equals to the nearest city.
    var isNearestCitySelected: Bool {
        guard
            let selected = selectedCity,
            let nearest = nearestCity else { return false }
        return selected == nearest
    }
    
    /// Represents a boolean value that defines whether the marketRadius is not nil.
    var isMarketsLoaded: Bool {
        return marketRadius != nil
    }
    
    /// Storage for the available cities.
    ///
    /// Updating this value results in sending a citiesLoaded notification for the receivers.
    private(set) var cities: [VendorCity] {
        didSet {
            QorumNotification.citiesLoaded.post()
        }
    }
    
    /// Represents a collection of cities sorted by name, where the selected city is always the first member in array.
    var sortedCities: [VendorCity] {
        return cities.sorted { (leftCity, rightCity) -> Bool in
            switch selectedCity {
            case leftCity?: return true
            case rightCity?: return false
            default: return leftCity < rightCity
            }
        }
    }
    
    /// All venues from the cities property of the CityManager.
    var allVenues: [Venue] {
        return cities.flatMap { $0.venues }
    }
    
    /// Radius for the current market.
    var marketRadius: Double?
    
    private init() {
        cities = [selectedCity].compactMap { $0 }
        QorumNotification.locationUpdated.add(observer: self, selector: #selector(locationUpdated))
    }
    
    deinit {
        QorumNotification.locationUpdated.remove(observer: self)
    }
    
    /// Assigns the nearestCity value to the selectedCity.
    func selectNearestCity() {
        selectedCity = nearestCity
    }
    
    /// Represents the nearest city to the current users location.
    var nearestCity: VendorCity? {
        guard let userLocation = LocationService.shared.location else { return nil }
        let nearestCity = cities.min {
            $0.location.distance(from: userLocation) < $1.location.distance(from: userLocation)
        }
        return nearestCity
    }
    
    /// Updates the selectedCity after location update.
    @objc func locationUpdated() {
        if selectedCity == nil {
            selectNearestCity()
        }
    }
    
    /// Wrapper for fetching market data.
    ///
    /// Updates marketRadius and cities.
    func fetchMarketsData() {
        fetchMarketRadius { [weak self] (result) in
            switch result {
            case let .value(marketRadius):
                self?.marketRadius = marketRadius.radius
                self?.fetchCities()
            case let .error(error):
                QorumNotification.citiesLoadFailed.post()
                print("AppDelegate.fetchMarketRadius failure: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchCities() {
        let request = BasicRequest(target: .locations)
        request.performArrayDecoding { [weak self] (result: APIResult<[VendorCity]>) in
            switch result {
            case let .value(newCities):
                let activeCities = newCities.filter { $0.isActive }
                self?.cities = activeCities.map { (newCity) -> VendorCity in
                    // Let me explain the black magic happening here
                    if let oldCity = self?.cities.first(where: { $0 == newCity }) {
                        // okay, we rather need to keep reference to the original (pre-cached) selected city
                        // than the reference to the fetched one (if they are identical, of course) -
                        // the original city may (or will, in some cases) contain fetched venues
                        return oldCity
                    }
                    return newCity
                }
                self?.selectNearestCity()
            case let .error(error):
                QorumNotification.citiesLoadFailed.post()
                print("CityManager.fetchCities failure: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchMarketRadius(completion: @escaping APIHandler<MarketRadius>) {
        let request = BasicRequest(target: .marketRadius)
        request.performDecoding(completion: completion)
    }
}
