//
//  BluetoothHelper.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/1/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothHelper: NSObject {
    
    /// Singleton instance
    static let shared = BluetoothHelper()
    
    /// CoreBluetoth manager instance
    private lazy var peripheralManager: CBPeripheralManager = {
        let manager = CBPeripheralManager()
        manager.delegate = self

        return manager
    }()
    
    /// Indicates Bluetooth status and notifies on update
    private(set) var state: CBManagerState = .unknown {
        didSet {
            switch state {
            case .poweredOn, .poweredOff:
                guard state != oldValue else { return }
                QorumNotification.bluetoothStatusChanged.post()
            default:
                break
            }
        }
    }
    
    // MARK: - Init
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Checks current Bluetooth status
    func checkBluetooth() {
        state = peripheralManager.state
        print("Bluetooth:", state)
    }
    
}

// MARK: - CBPeripheralManagerDelegate
extension BluetoothHelper: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        checkBluetooth()
    }
}

// MARK: - CustomStringConvertible
extension CBManagerState: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .resetting: return "resetting"
        case .unsupported: return "unsupported"
        case .unauthorized: return "unauthorized"
        case .poweredOff: return "powered off"
        case .poweredOn: return "powered on"
        }
    }
    
}
