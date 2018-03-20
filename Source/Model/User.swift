//
//  User.swift
//  Cacher
//
//  Created by Prajwal Lobo on 19/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import UIKit
import ObjectMapper

class User: BaseModel {

    var identifier : String?
    var name : String?
    var profileImage : ProfileImage?
    
    override func mapping(map: Map) {
        identifier <- map["id"]
        name <- map["name"]
        profileImage <- map["profile_image"]
    }
    
    
}
