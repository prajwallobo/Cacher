//
//  ImageCache.swift
//  Cacher
//
//  Created by Prajwal Lobo on 18/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import Foundation
import UIKit


enum CacheType{
    case memory, none
    
    //To know wheather an image is cached or not
    var cached : Bool{
        switch self {
        case .memory:
            return true
        case .none:
            return false
        }
    }
}

class ImageCache{
    
    //Memory Cache
    let memoryCache = NSCache<NSString, AnyObject>()
    
    ///The maximum total cost that the cache can hold before it starts evicting objects.
    var maxMemoryCost : Int = 0{
        didSet{
            memoryCache.totalCostLimit = maxMemoryCost
        }
    }
    
    /// The default cache.
    public static let `default` = ImageCache(name: "default")
    

    ///Passing the name for the memory cache
    init(name : String) {
        if name.isEmpty{
            fatalError("Cache cannot be created with empty name")
        }
        let cacheName = "com.mv.\(name)"
        memoryCache.name = cacheName
        
        
    }
    
    //MARK:- Store Cache
    
     /*For storing AnyObject to Cache. This is an async operation
            - parameter object : Any object that needs to cached. For this tutorail im caching images only
            - key : Key to identify the cached object
            - toMemory : Weather cache should be done on Memory or Disk. For this tutorail im caching to Memory only
            - completionHandler : Called when the storing the cache object is completed.
 
     */
    
    func store(_ object : AnyObject, forKey key : String, toMemory : Bool = true, completionHandler : (() -> Void)? = nil){
        if toMemory {
            memoryCache.setObject(object, forKey: key as NSString, cost: imageCost(for: object))
            if let handler = completionHandler{
                //Assuming download happens on the the Background Queue. Dispatch the handler to main Queue
                DispatchQueue.main.async {
                    handler()
                }
            }
        }else{
            //Handle the disk caching mechanisam here
        }
    }
    
    //MARK :- Remove Cache
    
    /*For storing AnyObject to Cache. This is an async operation
     - parameter object : Any object that needs to be removed from cache. For this tutorail im caching images only
     - parameter key : Key to identify the cached object
     - parameter fromMemory : Weather cache should be removed from Memory or Disk.
     - parameter completionHandler : Called when removing the cache object is completed.
     
     */
    func remove(_ object : AnyObject, forKey key : String, fromMemory : Bool = true, completionHandler : (() -> Void)? = nil){
        if fromMemory{
            memoryCache.removeObject(forKey: key as NSString)
            if let handler = completionHandler{
                //Assuming download happens on the the Background Queue. Dispatch the handler to main Queue
                DispatchQueue.main.async {
                    handler()
                }
            }
        }else{
            //Handle removing from disk here
        }
    }
    
    //MARK:- Retriving the the objects from Cache
    
    /**
     Get an Object for a key from memory
     
     - parameter key:               Key for the object.
     - parameter completionHandler: Called when retriving operation is completed with image and cached type of
     this image. If there is no such key cached, the object will be `nil`.
     
    */
    func retriveObject(forKey key : String, completionHanlder : ((AnyObject?, CacheType) -> Void)?){
        guard let handler = completionHanlder else{
            return
        }
        
        if let object = retriveObjectFromMemoryCache(forKey: key){
            handler(object, .memory)
        }else{
            handler(nil, .none)
        }
    }

    /**
     For getting object for a key from memory.
 
     - parameter key:     Key for the Object.
     - returns: The object if it is cached, or `nil` if there is no such key in the cache.
     */
    func retriveObjectFromMemoryCache(forKey key : String) -> AnyObject?{
        if let object = memoryCache.object(forKey: key as NSString){
            return object
        }
        return nil
    }
    
    
    //MARK:- Clear Cache
    func clearCache(type : CacheType){
        switch type {
        case .memory:
            memoryCache.removeAllObjects()
        default: break
        }
    }
    
    
    //MARK:- Helper
    func imageCost(for object : AnyObject) -> Int{
        if object is UIImage{
            return Int(object.size.height * object.size.width * object.scale)
        }else{
            //Determine object type and calculate size accordingly
            return 0
        }
    }
}

