//
//  AppDelegate.swift
//  VirtualTorist
//
//  Created by Nathan  on 2/9/18.
//  Copyright © 2018 Nathan . All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataController = DataController(modelName: "VirtualTourist")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationsViewController = navigationController.topViewController as! TravelLocationsViewController
        travelLocationsViewController.dataController = dataController
        return true
    }


}

