//
//  Downloader.swift
//  Cacher
//
//  Created by Prajwal Lobo on 18/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import Foundation
import UIKit

typealias ImageDownloaderCompletionHandler = ((_ image: UIImage?, _ error: ServerError?, _ url: URL?, _ originalData: Data?) -> Void)
///Download Task
public struct ImageDownloadTask{
    let dataTask : URLSessionDataTask
    
    //Owner of the download
    private(set) weak var downloadOwner : Downloader?
    
    //Fix:- Method to cancel
    public func cancel(){
        downloadOwner?.cancelDownloadTask(for: self)
    }
    
    ///Original request URL of the download task
    var url : URL?{
        return dataTask.originalRequest?.url
    }
    
}


protocol ImageDownloaderDelegate:class {
    
    /**
     Called when the `Downloader` object successfully downloads an image from specified URL.
     
     - parameter downloader: The `Downloader` object finishes the downloading.
     - parameter image:      Downloaded image.
     - parameter url:        URL of the original request URL.
     - parameter response:   The response object of the downloading process.
     */
    func downloader(_ downloader : Downloader, didDownload image : UIImage, for url : URL?, with response : URLResponse?)
    
    /**
     Called when the `Downloader` object starts to downloading an image from specified URL.
     
     - parameter downloader: The `Downloader` object that starts the downloading.
     - parameter url:        URL of the original request.
     - parameter response:   The request object of the downloading process.
     */
    func downloader(_ downloader : Downloader, willDownloadImageFor url : URL?, with request : URLRequest?)
    
}

class Downloader{
    
    class ImageFetchLoad{
        var responseData = NSMutableData()
        var downloadTaskCount = 0
        var downloadTask : ImageDownloadTask?
        //used to control access to a resource across multiple execution contexts.
        var cancelSempaphore : DispatchSemaphore?
        
    }
    ///Duration before the download is timed out, default is set to 20.0
    var downloadTimeout : TimeInterval = 20.0
    /// Delegate of this `Downloader` object
    weak var delegate : ImageDownloaderDelegate?
    
    var fetchloads = [URL : ImageFetchLoad]()
    
    let session : URLSession?
    
    // MARK: - Property
    let barrierQueue: DispatchQueue
    //let processQueue: DispatchQueue
    let cancelQueue: DispatchQueue
    
    /// The default downloader.
    public static let `default` = Downloader(name: "default")
    
    init(name : String) {
        if name.isEmpty{
            fatalError("Downloder must have a valid name")
        }
        barrierQueue = DispatchQueue(label: "com.mv.\(name)")
        cancelQueue = DispatchQueue(label : "com.mv.\(name)")
        //processQueue = DispatchQueue(label: "com.mv.\(name)")
        
        //Default session
        session = URLSession(configuration: URLSessionConfiguration.default)

    }
    
    func fetchLoad(for url : URL) -> ImageFetchLoad?{
        var fetchLoad : ImageFetchLoad?
        barrierQueue.sync(flags: .barrier) {
            fetchLoad = fetchloads[url]
        }
        return fetchLoad
        
    }
    
    @discardableResult
    func downloadImage(with url : URL,
                       retriveImageTask : RetriveImageTask? = nil,
                       completionHandler : ImageDownloaderCompletionHandler? = nil) -> ImageDownloadTask? {
        
        if let retriveImageTask = retriveImageTask, retriveImageTask.cancelledBeforeDownloadStarting{
            let error = ServerError()
            error.code = ErrorCode.UserCancelledDownload
            error.message = ErrorMessage.cancelledDownload
            completionHandler?(nil,error,nil,nil)
            return nil
        }
        
        let timeout = downloadTimeout == 0.0 ? 20.0 : downloadTimeout
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        //Weather reciver transmits the data before the previous response is recived set to `NO`
        request.httpShouldUsePipelining = false
        
        var downloadTask : ImageDownloadTask?
        setup(with: completionHandler, for: url) { (session, fetchLoad) in
            if fetchLoad.downloadTask == nil{
                self.delegate?.downloader(self, willDownloadImageFor: url, with: request)
                
                let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let error = error{
                        let aError = ServerError()
                        aError.message = error.localizedDescription
                        completionHandler?(nil, aError, nil, nil)
                        
                    }else{
                        if let data = data, let image = UIImage(data : data){
                            completionHandler?(image, nil, response?.url, data)
                            self.delegate?.downloader(self, didDownload: image, for: url, with: response)
                        }
                    }
                })
                dataTask.resume()
                fetchLoad.downloadTask = ImageDownloadTask(dataTask: dataTask, downloadOwner: self)
                fetchLoad.downloadTaskCount += 1
                downloadTask = fetchLoad.downloadTask
                //Used for cancelling download task if required
                retriveImageTask?.downloadTask = downloadTask
            }
        }
        return downloadTask
    }
    
    deinit {
        session?.invalidateAndCancel()
    }
    
}

extension Downloader{
    /// A single key may have called more than once. Make sure it gets downloaded only once
    func setup(with completionHandler : ImageDownloaderCompletionHandler?, for url : URL, started : @escaping((URLSession, ImageFetchLoad) -> Void)){
        
        func prepareFetchLoad(){
            barrierQueue.sync(flags: .barrier) {
                let loadObjectForURL = fetchloads[url] ?? ImageFetchLoad()
                fetchloads[url] = loadObjectForURL
                if let session = session{
                    started(session, loadObjectForURL)
                }
                
            }
        }
        
        if let fetchLoad = fetchLoad(for: url), fetchLoad.downloadTaskCount == 0{
            if fetchLoad.cancelSempaphore == nil{
                fetchLoad.cancelSempaphore = DispatchSemaphore(value: 0)
            }
            cancelQueue.async {
                _ = fetchLoad.cancelSempaphore?.wait(timeout: .distantFuture)
                fetchLoad.cancelSempaphore = nil
                prepareFetchLoad()
                
            }
        }else{
            prepareFetchLoad()
        }
    }
    //Cancel the download task, if task has finished downloading nothing will be done
    func cancelDownloadTask(for task : ImageDownloadTask){
        barrierQueue.sync(flags: .barrier) {
            if let url = task.dataTask.originalRequest?.url, let fetchLoad = fetchloads[url]{
                fetchLoad.downloadTaskCount -= 1
                if fetchLoad.downloadTaskCount == 0{
                    task.dataTask.cancel()
                }
            }
        }
    }
}

