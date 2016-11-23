//
//  AppDelegate.swift
//  ForceUpdate
//
//  Created by Active Mac05 on 11/02/16.
//  Copyright © 2016 techactive. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        isNewUpdateAvailable()
        // Override point for customization after application launch.
        return true
    }

    func isNewUpdateAvailable(){
        let url = iTunesURLFromString()
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        session.sendSynchronousRequest(request) { data, response, error in
            guard data != nil else {
                return
            }
//            print(String(data: data!, encoding: NSUTF8StringEncoding))
            let json = JSON(data: data!)
            let version = json["results"][0]["version"].stringValue
            print("the current appstore version is \(version)")
            let currentBuildVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
            print("the current debugging version is \(currentBuildVersion)")
            if self.isAppStoreVersionNewer(currentBuildVersion, currentAppStoreVersion: version) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.window?.rootViewController?.presentedViewController is UIAlertController {
                        self.window?.rootViewController?.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                    }
                    let alertController = UIAlertController(title: "", message: "A newer version \(version) \nis Available", preferredStyle: .Alert)
                    alertController.addAction(self.updateAlertAction())
                    self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                })
                
            }
        }
    }
    
    func updateAlertAction() -> UIAlertAction {
        let action = UIAlertAction(title: "Update", style: .Default) { (alert: UIAlertAction) -> Void in
            let iTunesString =  "https://itunes.apple.com/app/id\(1068737983)"
            let iTunesURL = NSURL(string: iTunesString)
            UIApplication.sharedApplication().openURL(iTunesURL!)
            return
        }
        
        return action
    }
    
    func iTunesURLFromString() -> NSURL {
        let appID = 1068737983
        var countryCode: String?
        var storeURLString = "https://itunes.apple.com/lookup?id=\(appID)"
        countryCode = "in"
        if let countryCode = countryCode {
            storeURLString += "&country=\(countryCode)"
        }
            print("[Siren] iTunes Lookup URL: \(storeURLString)")
        
        return NSURL(string: storeURLString)!
    }
    
    func isAppStoreVersionNewer(currentInstalledVersion : String?, currentAppStoreVersion : String?) -> Bool {
        
        var newVersionExists = false
        print("currentInstalledVersion = \(currentInstalledVersion)  and currentAppStoreVersion = \(currentAppStoreVersion)")
        if let currentInstalledVersion = currentInstalledVersion, currentAppStoreVersion = currentAppStoreVersion {
            if (currentInstalledVersion.compare(currentAppStoreVersion, options: .NumericSearch) == NSComparisonResult.OrderedAscending) {
                newVersionExists = true
            }
        }
        
        return newVersionExists
    }
    
    func applicationWillResignActive(application: UIApplication) {
        if self.window?.rootViewController?.presentedViewController is UIAlertController {
            self.window?.rootViewController?.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
        }
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        isNewUpdateAvailable()
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

