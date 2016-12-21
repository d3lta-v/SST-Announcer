//
//  AppDelegate.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 19/11/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import UIKit
import OneSignal
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    Fabric.with([Crashlytics.self, Answers.self])
    OneSignal.initWithLaunchOptions(launchOptions, appId: "76349b34-5515-4dbe-91bd-3dff5ca1e780") { result in
      guard let result = result else {
        // No notifications received
        return
      }
      let payload = result.notification.payload
      guard let fullMessage = payload?.title else {
        //TODO: Relay telemetry as this may be a severe failure
        return
      }
      // Check if this is a "New Post: " type of message
      if fullMessage.substring(to: fullMessage.index(fullMessage.startIndex, offsetBy: 10)) == "New Message: " {
        guard let splitViewController = self.window?.rootViewController as? UISplitViewController else {
          //TODO: Relay telemetry as this may be a severe failure
          print("Severe error occured, unable to assign split view controller")
          return
        }
        guard let primaryViewController = splitViewController.viewControllers.first as? MainTableViewController else {
          //TODO: Relay telemetry as this may be a severe failure
          print("Severe error occured, unable to assign primary view controller")
          return
        }
        guard let additionalData = payload?.additionalData as? [String: String] else {
          //TODO: Relay telemetry as this may be a severe failure
          print("Severe error occured, unable to unwrap addtional data dictionary from payload")
          return
        }
        guard let link = additionalData["link"] else {
          //TODO: Relay telemetry as this may be a severe failure
          print("Severe error occured, unable to unwrap link from addtionalData array")
          return
        }
        let actualTitle = fullMessage.substring(from: fullMessage.index(fullMessage.startIndex, offsetBy: 10))
        primaryViewController.pushedFeedItem = FeedItem(title: actualTitle, link: link, date: Date(), author: "", rawHtml: "", strippedHtml: "", read: false)
      } else {
        //TODO: Handle other types of payloads
      }
    }
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    var token = ""
    for i in 0 ..< deviceToken.count {
      token += String(format: "%02.2hhx", [deviceToken[i]])
    }
    print("Device token retrieved: \(token)")
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an incoming phone
    // call or SMS message) or when the user quits the application and it begins the transition
    // to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering
    // callbacks.
    // Games should use this method to pause the game.
    UserDefaults.standard.synchronize()
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store
    // enough application state information to restore your application to its current state in
    // case it is terminated later.
    // If your application supports background execution, this method is called instead of
    // applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you
    // can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was
    // inactive.
    // If the application was previously in the background, optionally refresh the user
    // interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate.
    // See also applicationDidEnterBackground:.
  }

}
