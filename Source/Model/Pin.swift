//
//  Pin.swift
//  Cacher
//
//  Created by Prajwal Lobo on 19/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import UIKit
import ObjectMapper

class Pin: BaseModel {
    var likes : Int?
    var user : User?
    var link : String?
    
    override func mapping(map: Map) {
        likes <- map["likes"]
        user <- map["user"]
        link <- map["links.download"]
    }
}
