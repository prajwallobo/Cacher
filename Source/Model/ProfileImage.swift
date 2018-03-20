//
//  ProfileImage.swift
//  Cacher
//
//  Created by Prajwal Lobo on 19/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import UIKit
import ObjectMapper

class ProfileImage: BaseModel {

    var small : String?
    var medium : String?
    var large : String?
    
    override func mapping(map: Map) {
        small <- map["small"]
        medium <- map["medium"]
        large <- map["large"]
    }
}
