//
//  CacheManager.swift
//  Cacher
//
//  Created by Prajwal Lobo on 18/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import Foundation
import UIKit

typealias CompletionHandler = ((_ object : AnyObject?, _ error : ServerError?, _ cacheType : CacheType, _ url : URL?) -> Void)

///An async task of getting image from network
final class RetriveImageTask{
    static let empty = RetriveImageTask()
    
    // If task is canceled before the download, the download task should not begin.
    var cancelledBeforeDownloadStarting: Bool = false
    //The network retrive task
    var downloadTask : ImageDownloadTask?
    
    ///Cancel current task
    public func cancel(){
        if let task = downloadTask{
            task.cancel()
        }else{
            cancelledBeforeDownloadStarting = true
        }
    }
}
    
    public class CacheManager{
        //Shared class used by extension
        static let shared = CacheManager()
        
        //Cache used by the class
         var cache : ImageCache
        
        //Downloader used by class
         var downloader : Downloader
        
        convenience init() {
            self.init(downloader: .default, cache: .default)
        }
        
        init(downloader : Downloader, cache : ImageCache) {
            self.downloader = downloader
            self.cache = cache
        }

        
    @discardableResult
        func retriveImage(with resource : Resource, completionHandler : CompletionHandler?) -> RetriveImageTask{
            let task = RetriveImageTask()
            retriveImageFromCache(forKey: resource.cacheKey,
                                  with: resource.downloadURL,
                                  retriveImageTask: task,
                                  completionHandler: completionHandler)
            return task
        }
    
    func retriveImageFromCache(forKey key : String, with url : URL, retriveImageTask : RetriveImageTask, completionHandler : CompletionHandler?){
        
        let taskCompletionHandler: CompletionHandler = { (object, error, cacheType, url) -> Void in
            completionHandler?(object, error, cacheType, url)
        }
        func handleNoCache(){
           downloadAndCacheImage(for: url, key: key, retriveImageTask: retriveImageTask, completionHandler: taskCompletionHandler)
        }
        let targetCache = ImageCache.default
        //Try to get image from cache
        targetCache.retriveObject(forKey: key) { (object, cacheType) in
            if object != nil{
                taskCompletionHandler(object!, nil, cacheType, url)
            }else{
                handleNoCache()
                
            }
        }
        
    }
    
    @discardableResult
    func downloadAndCacheImage(for url : URL, key : String, retriveImageTask : RetriveImageTask, completionHandler : CompletionHandler?) -> ImageDownloadTask?{
        
        let downloader = Downloader.default
       return downloader.downloadImage(with: url, retriveImageTask: retriveImageTask) { (image, error, url, data) in
            if let error = error{
                print(error.message ?? "")
            }else{
                let targetCache = ImageCache.default

                if let image = image{
                    targetCache.store(image, forKey: key, toMemory: true, completionHandler: nil)
                    completionHandler?(image, error, .none, url)

                }
            }
        }
    }
    
}

