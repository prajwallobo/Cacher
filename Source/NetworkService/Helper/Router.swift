//
//  Router.swift
//  HFSimulator
//
//  Created by Prajwal Lobo on 19/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import Foundation
import Alamofire

enum Router : URLRequestConvertible{

    static let baseURL = "http://pastebin.com/raw/wgkJgazE"
    
    case getPin()
    
    
    var path : String{
        switch self {
        case .getPin():
            return ""
        }
    }
    
    var method : Alamofire.HTTPMethod{
        switch self {
        case .getPin():
            return .get
        }
    }
    func asURLRequest() throws -> URLRequest {
        let url = URL(string : Router.baseURL + path)
        var requestURL = URLRequest(url: url!)
        requestURL.httpMethod = method.rawValue
        
        switch self{
        case .getPin():
            return try Alamofire.JSONEncoding.default.encode(requestURL, with: nil)
            
        }
    }
        

}



