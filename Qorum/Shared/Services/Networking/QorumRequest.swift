//
//  QorumRequest.swift
//  Qorum
//
//  Created by Stanislav on 11.01.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

typealias BasicRequest = QorumRequest<QorumAPI>
typealias AuthenticatedRequest = QorumRequest<QorumAuthenticatedAPI>
typealias VenuesRequest = QorumRequest<QorumVenuesAPI>
typealias RideRequest = QorumRequest<QorumRideAPI>
typealias UberRequest = QorumRequest<UberAPI>
typealias DirectionsRequest = QorumRequest<QorumDirectionsAPI>
typealias VerificationRequest = QorumRequest<QorumVerificationAPI>
typealias ITunesLookupRequest = QorumRequest<ITunesConnectionAPI>

protocol DecodingRequest {
    func perform(completion: @escaping (APIResponse<JSON>) -> ())
}

extension DecodingRequest {
    
    func performDecoding<ResultType: JSONAbleType>(for pathKeys: JSONSubscriptType...,
                                                   completion: @escaping APIHandler<ResultType>) {
        perform { response in
            switch response.result {
            case let .value(baseJSON):
                let sourceJSON = baseJSON[pathKeys]
                let decodingResult = ResultType.result(json: sourceJSON)
                let decodingResponse = APIResponse(endpointDescriptor: response.endpointDescriptor,
                                                   urlResponse: response.urlResponse,
                                                   result: decodingResult)
                decodingResponse.validate {
                    completion(decodingResult)
                }
            case let .error(error):
                completion(.error(error))
            }
        }
    }
    
    func performArrayDecoding<ResultType: JSONAbleType>(for pathKeys: JSONSubscriptType...,
                                                        completion: @escaping APIHandler<[ResultType]>) {
        perform { response in
            switch response.result {
            case let .value(baseJSON):
                let sourceJSON = baseJSON[pathKeys]
                let arrayResult = ResultType.arrayResult(from: sourceJSON)
                let arrayResponse = APIResponse(endpointDescriptor: response.endpointDescriptor,
                                                urlResponse: response.urlResponse,
                                                result: arrayResult)
                arrayResponse.validate {
                    completion(arrayResult)
                }
            case let .error(error):
                completion(.error(error))
            }
        }
    }
    
}

struct QorumRequest<Target: QorumAPITarget>: DecodingRequest {
    
    let target: Target
    
    func perform(completion: @escaping (APIResponse<JSON>) -> ()) {
        let provider = MoyaProvider<Target>.headerTypeProvider
        var backgroundTaskId = UIBackgroundTaskInvalid
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: self.target.endpointDescription) {
            debugPrint("Background task \(backgroundTaskId) expired")
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
        }
        debugPrint("Background task \(backgroundTaskId) started")
        provider.request(target) { result in
            let jsonResult: APIResult<JSON>
            let urlResponse: HTTPURLResponse?
            switch result {
            case let .success(response):
                jsonResult = response.jsonResult
                urlResponse = response.response
            case let .failure(error):
                jsonResult = .error(error)
                urlResponse = error.response?.response
            }
            let jsonResponse = APIResponse(endpointDescriptor: self.target,
                                          urlResponse: urlResponse,
                                          result: jsonResult)
            jsonResponse.validate {
                completion(jsonResponse)
                debugPrint("Background task \(backgroundTaskId) ended")
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
            }
        }
    }
    
}
