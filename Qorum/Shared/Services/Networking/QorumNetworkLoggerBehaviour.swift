//
//  QorumNetworkLoggerBehaviour.swift
//  Qorum
//
//  Created by Dmitry Tsurkan on 3/4/19.
//  Copyright © 2019 Bizico. All rights reserved.
//

import Foundation

enum QorumNetworkLoggerBehaviour {
    case disabled
    case enabled(verbose: Bool, cURL: Bool)
}
