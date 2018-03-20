//
//  CacheTest.swift
//  CacherTests
//
//  Created by Prajwal Lobo on 20/03/18.
//  Copyright © 2018 Prajwal Lobo. All rights reserved.
//

import XCTest
@testable import Cacher

class CacheTest: XCTestCase {
    
    var cache : ImageCache!
    var cacheName = "CacheTest"
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        cache = ImageCache(name: cacheName)

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        clearCache(cache: cache)
        cache = nil
    }

    
    func testMaxMemoryCost(){
        cache.maxMemoryCost = 1
        XCTAssert(cache.maxMemoryCost == 1, "Should be able to set Max Memory Cost")
    }
    
    func testCleanMemoryCache(){
        let expectation = self.expectation(description: "Retriving image..")
        cache.store(testImage!, forKey: testCacheKey[0], toMemory: true) {
            //Clear the cache after storing, so that when we fetch the cache shouldnt be there
            self.cache.clearCache(type: .memory)
            self.cache.retriveObject(forKey: testCacheKey[0], completionHanlder: { (object, cacheType) in
               XCTAssert(object == nil, "No data cached for given key")
            })
            expectation.fulfill()
            
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testIsObjectCachedForKey(){
        let expectation = self.expectation(description: "Checking object exists in Cache")
        let object = cache.retriveObjectFromMemoryCache(forKey: testCacheKey[0])
        XCTAssert(object == nil, "Given object is not cached yet")
        cache.store(testImage!, forKey: testCacheKey[0], toMemory: true) {
            let object = self.cache.retriveObjectFromMemoryCache(forKey: testCacheKey[0])
            XCTAssert(object != nil, "Given object is available in cache")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

}
