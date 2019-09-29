//
//  FacebookRequest.swift
//  Qorum
//
//  Created by Stanislav on 24.01.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import FacebookCore
import SwiftyJSON

struct FacebookRequest: DecodingRequest {
    
    let target: FacebookAPI
    
    func perform(completion: @escaping (APIResponse<JSON>) -> ()) {
        target.start { urlResponse, result in
            let apiResult: APIResult<JSON>
            switch result {
            case let .success(json):
                apiResult = .value(json)
            case let .failed(error):
                apiResult = .error(error)
            }
            let apiResponse = APIResponse(endpointDescriptor: self.target,
                                          urlResponse: urlResponse,
                                          result: apiResult)
            apiResponse.validate {
                completion(apiResponse)
            }
        }
    }
    
}


