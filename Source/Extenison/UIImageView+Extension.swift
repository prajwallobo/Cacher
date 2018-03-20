//
//  UIImageView+Extension.swift
//  Cacher
//
//  Created by Prajwal Lobo on 18/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import Foundation
import UIKit

//Associated property
private var imageTaskKey: Void?


extension UIImageView{
    fileprivate var imageTask: RetriveImageTask? {
        return objc_getAssociatedObject(UIImageView.self, &imageTaskKey) as? RetriveImageTask
    }
    
    fileprivate func setImageTask(_ task: RetriveImageTask?) {
        objc_setAssociatedObject(UIImageView.self, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension UIImageView{

@discardableResult
func setImage(with resource : Resource?, completionHandler : CompletionHandler? = nil) -> RetriveImageTask{
    guard let resource = resource else{
        completionHandler?(nil,nil,.none,nil)
        return .empty //Return empty task
    }
    
    let task = CacheManager.shared.retriveImage(with: resource) {[weak self] (object, error, cacheType, url) in
        guard let ref = self else {
            return
            
        }

        DispatchQueue.main.async {
            ref.setImageTask(nil)
            guard let object = object else{
                completionHandler?(nil,error,cacheType, url)
                return
                
            }
            if object is UIImage{
                ref.image = object as? UIImage
                completionHandler?(object,nil,cacheType, url)
            }else{
                //Handle other types here
            }
           
        }
    }
    setImageTask(task)
    return task
}
    //Cancelling the download task associated with image if it is running
    public func cancelDownloadTask() {
        imageTask?.cancel()
    }

}
