//
//  QorumEnvironment.swift
//  Qorum
//
//  Created by Stanislav on 30.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation

/// The structure which describes Qorum server base URL.
struct QorumEnvironment: Equatable {
    
    /// Defines option to use HTTPS or HTTP for the base URL.
    enum Scheme: String, Codable {
        
        /// Safe, encrypted connection.
        case https
        
        /// Network traffic can be sniffed for debugging.
        case http
        
    }
    
    /// A host option defining server to use.
    enum Path: Equatable, Codable {
        
        /// The Staging server. Used for testing new features.
        case staging
        
        /// The Demo Staging is used for testing new features before updating the Demo server.
        case demoStaging
        
        /// The Demo server, which is used for demonstration activities.
        case demo
        
        /// The Production server. Used by end consumers.
        case production
        
        /// The custom path, reserved for testing purposes. Can't be used by default.
        case custom(String)
        
        /// The server name.
        var title: String {
            switch self {
            case .staging: return "Staging"
            case .demoStaging: return "Demo Staging"
            case .demo: return "Demo"
            case .production: return "Production"
            case .custom(let string): return "Custom (\(string))"
            }
        }
        
    }
    
    /// Defines the scheme for the base URL.
    var scheme: Scheme
    
    /// Defines the host/path for the base URL.
    var path: Path
    
    /// The server base `URL` as a result of combining the `scheme` and `path`.
    var url: URL {
        let link = "\(scheme.rawValue)://\(path.rawValue)"
        return URL(string: link)!
    }
    
    /// The Staging server with HTTPS.
    static var staging: QorumEnvironment {
        return QorumEnvironment(scheme: .https, path: .staging)
    }
    
    /// The Demo server with HTTPS.
    static var demo: QorumEnvironment {
        return QorumEnvironment(scheme: .https, path: .demo)
    }
    
    /// The Production server with HTTPS.
    static var production: QorumEnvironment {
        return QorumEnvironment(scheme: .https, path: .production)
    }
    
}

// MARK: - RawRepresentable
extension QorumEnvironment.Path: RawRepresentable {
    
    typealias RawValue = String
    
    /// Defines the server `URL` host component string.
    var rawValue: RawValue {
        switch self {
        case .staging:
            return "qorum-backend-staging.herokuapp.com"
        case .demoStaging:
            return "qorum-backend-demo-staging.herokuapp.com"
        case .demo:
            return "qorum-backend-demo.herokuapp.com"
        case .production:
            return "prod.backend.qorum.com"
        case .custom(let string):
            return string
        }
    }
    
    /// Initializes the `Path` from given host string.
    ///
    /// - Parameter rawValue: The host component string defining the server `URL`.
    init(rawValue: RawValue) {
        switch rawValue {
        case "qorum-backend-staging.herokuapp.com":
            self = .staging
        case "qorum-backend-demo-staging.herokuapp.com":
            self = .demoStaging
        case "qorum-backend-demo.herokuapp.com":
            self = .demo
        case "prod.backend.qorum.com":
            self = .production
        default:
            self = .custom(rawValue)
        }
    }
    
}

// MARK: - Codable
extension QorumEnvironment: Codable {
    
    /// Decodes the environment either from a dictionary or a single string.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            let scheme = try container.decode(QorumEnvironment.Scheme.self, forKey: .scheme)
            let path = try container.decode(QorumEnvironment.Path.self, forKey: .path)
            self.init(scheme: scheme, path: path)
            return
        }
        // legacy support
        let container = try decoder.singleValueContainer()
        let urlString = try container.decode(String.self)
        if  let url = URL(string: urlString),
            let schemeString = url.scheme,
            let hostString = url.host
        {
            let scheme = QorumEnvironment.Scheme(rawValue: schemeString) ?? .https
            let path = QorumEnvironment.Path(rawValue: hostString)
            self.init(scheme: scheme, path: path)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "url decoding error")
        }
    }
    
}
