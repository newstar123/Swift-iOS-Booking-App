//
//  UberTypesLoader.swift
//  Qorum
//
//  Created by Vadym Riznychok on 5/31/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class UberTypesLoader: NSObject {
    var classes: [UberClass] = []
    
//    func loadEstimates(startLocation: CLLocationCoordinate2D, finishLocation: CLLocationCoordinate2D, handler:@escaping (_ success:Bool, _ resultType: [UberClass]) -> ()) {
//        let classesToLoad = self.classes.filter({ $0.hasNotLoadedEstimate() })
//        if classesToLoad.count > 0 {
//            let classToLoad = classesToLoad.first
//            let typesToLoad = classToLoad?.types.filter({ $0.estimate == nil })
//            if (typesToLoad?.count)! > 0 {
//                let typeToLoad = typesToLoad?.first
//                UberController.sharedController.uberTypeEstimateWith(productId: (typeToLoad?.productData?.product_id)!, startLocation: startLocation, finishLocation: finishLocation, seatCount: nil, handler: { (result, estimate) in
//                    guard estimate != nil else {
//                        typeToLoad?.estimate = UberTypeEstimate(data: [:])
//
//                        let notLoaded = self.classes.filter({ $0.hasNotLoadedEstimate() })
//                        if notLoaded.count != 0 {
//                            self.loadEstimates(startLocation: startLocation, finishLocation: finishLocation, handler: handler)
//                        } else {
//                            handler(true, self.classes)
//                        }
//
//                        return
//                    }
//
//                    typeToLoad?.estimate = estimate
//
//                    let notLoaded = self.classes.filter({ $0.hasNotLoadedEstimate() })
//                    if notLoaded.count != 0 {
//                        self.loadEstimates(startLocation: startLocation, finishLocation: finishLocation, handler: handler)
//                    } else {
//                        handler(true, self.classes)
//                    }
//                })
//            }
//        }
//    }
//
//    func loadEstimate(for type: UberType, startLocation: CLLocationCoordinate2D, finishLocation: CLLocationCoordinate2D, handler:@escaping (_ success:Bool, _ resultType: UberType?) -> ()) {
//        UberController.sharedController.uberTypeEstimateWith(productId: (type.productData?.product_id)!, startLocation: startLocation, finishLocation: finishLocation, seatCount: nil, handler: { (result, estimate) in
//            guard estimate != nil else {
//                handler(false, nil)
//                return
//            }
//
//            type.estimate = estimate
//            handler(true, type)
//        })
//    }

}
