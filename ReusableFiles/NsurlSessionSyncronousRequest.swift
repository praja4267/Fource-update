//
//  NsurlSessionSyncronousRequest.swift
//  ForceUpdate
//
//  Created by Active Mac05 on 11/02/16.
//  Copyright © 2016 techactive. All rights reserved.
//

import Foundation

extension NSURLSession {
    func sendSynchronousRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let semaphore = dispatch_semaphore_create(0)
        let task = self.dataTaskWithRequest(request) { data, response, error in
            completionHandler(data, response, error)
            dispatch_semaphore_signal(semaphore)
        }
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}

/// NSURLSession synchronous behavior
/// Particularly for playground sessions that need to run sequentially
public extension NSURLSession {
    
    /// Return data from synchronous URL request
    public static func requestSynchronousData(request: NSURLRequest) -> NSData? {
        var data: NSData? = nil
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            taskData, _, error -> () in
            data = taskData
            if data == nil, let error = error {print(error)}
            dispatch_semaphore_signal(semaphore);
        })
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return data
    }
    
    /// Return data synchronous from specified endpoint
    public static func requestSynchronousDataWithURLString(requestString: String) -> NSData? {
        guard let url = NSURL(string:requestString) else {return nil}
        let request = NSURLRequest(URL: url)
        return NSURLSession.requestSynchronousData(request)
    }
    
    /// Return JSON synchronous from URL request
    public static func requestSynchronousJSON(request: NSURLRequest) -> AnyObject? {
        guard let data = NSURLSession.requestSynchronousData(request) else {return nil}
        return try? NSJSONSerialization.JSONObjectWithData(data, options: [])
    }
    
    /// Return JSON synchronous from specified endpoint
    public static func requestSynchronousJSONWithURLString(requestString: String) -> AnyObject? {
        guard let url = NSURL(string: requestString) else {return nil}
        let request = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return NSURLSession.requestSynchronousJSON(request)
    }
}