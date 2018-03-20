# Cacher

## Introduction
A sample application to demonstrate the download and caching of the images with given URL

## Features
- Asynchronous image downloading and caching
- URLSession based networking
- Cache in memory using NSCache
- Extension for UIIMageView to directly set the image
- Configurable total cost limit on memeory Cache
- Cancelable download task

## Usage

```swift
let url = URL(string: "url_of_your_image")
imageView.setImage(with: url)
```

With Completion Handler

```swift
let url = URL(string: "url_of_your_image")
imageView.setImage(with: url), completionHandler: {[weak self] (object, error, cacheType, url) in

})
```
## Future
- Caching Library for images (JSON, XML Yet to be supported)
- Pod library for the Utilities file yet to be created

## Installation
- Drag and drop CacheManager.swift, Downloader.swift, ImageCache.swift, Resource.swift into your iOS Project

