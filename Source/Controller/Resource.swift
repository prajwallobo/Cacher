//
//  Resource.swift
//  Cacher
//
//  Created by Prajwal Lobo on 19/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import Foundation

protocol Resource {
    var cacheKey : String {get}
    var downloadURL : URL {get}
}

///Combination of `downloadURL` and `cacheKey`.
struct ImageResource: Resource{
    public let cacheKey: String
    public let downloadURL: URL
    
    //Create resource
    init(downloadURL : URL, cacheKey : String? = nil) {
        self.cacheKey = cacheKey ?? downloadURL.absoluteString
        self.downloadURL = downloadURL
    }
}

///The `absoluteString` of this URL is used as `cacheKey`. And the URL  will be used as `downloadURL`.

extension URL : Resource{
    var cacheKey : String{
        return absoluteString
    }
    var downloadURL : URL{
        return self
    }
}
