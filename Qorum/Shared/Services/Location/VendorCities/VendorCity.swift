//
//  VendorCity.swift
//  Qorum
//
//  Created by Stanislav on 10/9/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import CoreLocation
import SwiftyJSON

final class VendorCity {
    
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let imageLink: String
    let isActive: Bool
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private(set) lazy var venues: [Venue] = []
    
    init(id: Int,
         name: String,
         latitude: Double,
         longitude: Double,
         imageLink: String,
         isActive: Bool)
    {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.imageLink = imageLink
        self.isActive = isActive
    }
    
    /// Fetches venues for this city from server by identifier of the city.
    ///
    /// Result assigns to the venues property of the current city.
    ///
    /// In case the city is not equals to the CityManager.shared.selectedCity, selectedCityVenuesUpdated notification will be sended for the receivers.
    ///
    /// - Parameter completion: completion block
    func updateVenues(completion: @escaping APIHandler<[Venue]>) {
        let route = QorumVenuesAPI.fetchVenuesForCity(cityId: id)
        route.performArrayDecoding(for: "vendors") { [weak self] (result: APIResult<[Venue]>) in
            switch result {
            case let .value(venues):
                guard let city = self else {
                    completion(.error("City to attach venues (\(venues.count)) to is missing"))
                    return
                }
                let activeVenues = venues.filter { $0.isActive ?? false }
                city.venues = activeVenues
                if city == CityManager.shared.selectedCity {
                    QorumNotification.selectedCityVenuesUpdated.post()
                }
                completion(.value(activeVenues))
            case let .error(error):
                completion(.error(error))
            }
        }
    }
    
}

// MARK: - JSONAbleType
extension VendorCity: JSONAbleType {
    
    static func from(json: JSON) throws -> VendorCity {
        let id = try json["id"].expectingInt()
        let name = json["label"].stringValue
        let latitude = try json["latitude"].expectingDouble()
        let longitude = try json["longitude"].expectingDouble()
        let imageLink = json["image_url"].stringValue
        let isActive = json["is_active"].boolValue
        return VendorCity(id: id,
                          name: name,
                          latitude: latitude,
                          longitude: longitude,
                          imageLink: imageLink,
                          isActive: isActive)
    }
    
}

// MARK: - Comparable
extension VendorCity: Comparable {
    
    static func <(lhs: VendorCity, rhs: VendorCity) -> Bool {
        switch lhs.name.localizedCaseInsensitiveCompare(rhs.name) {
        case .orderedAscending: return true
        case .orderedDescending: return false
        case .orderedSame: return lhs.id < rhs.id
        }
    }
    
    static func ==(lhs: VendorCity, rhs: VendorCity) -> Bool {
        return lhs.id == rhs.id && lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedSame
    }
    
}

// MARK: - Codable
extension VendorCity: Codable {
    
    /// Represents the stored object for the nearest city in the UserDefaults.
    static var nearestStored: VendorCity? {
        let defaults = UserDefaults.standard
        guard let cityData = defaults.nearestCityData else { return nil }
        do {
            return try VendorCity.decoded(from: cityData)
        } catch {
            print("City decoding error:", error)
            defaults.nearestCityData = nil
            return nil
        }
    }
    
    func save() {
        do {
            let defaults = UserDefaults.standard
            defaults.nearestCityData = try encode()
            defaults.synchronize()
        } catch {
            print("City encoding error:", error)
        }
    }
    
}

private extension UserDefaults {
    
    /// Represents the stored data for the nearest city in the UserDefaults.
    fileprivate(set) var nearestCityData: Data? {
        get {
            return data(forKey: #function)
        } set {
            guard let data = newValue else {
                removeObject(forKey: #function)
                return
            }
            set(data, forKey: #function)
        }
    }
    
}

