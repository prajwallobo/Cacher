//
//  APIService.swift
//  HFSimulator
//
//  Created by Prajwal Lobo on 19/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class APIService: NSObject {
    
    static let shared = APIService()
    
    func getPin(completionHandler : @escaping([Pin]?, ServerError?) ->Void){
        Alamofire.request(Router.getPin()).validate().responseArray(queue: .main, keyPath: nil, context: nil) { (response : DataResponse<[Pin]>) in
            if response.result.isFailure{
                let error = ServerError()
                error.message = "Something Unexpected"
                completionHandler(nil,error)

            }else{
                let pins = response.result.value
                completionHandler(pins, nil)
            }
        }
        
    }


}
