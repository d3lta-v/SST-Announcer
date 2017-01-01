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

  // swiftlint:disable line_length
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    Fabric.with([Crashlytics.self, Answers.self])
    let appId = "76349b34-5515-4dbe-91bd-3dff5ca1e780"
    OneSignal.initWithLaunchOptions(launchOptions, appId: appId) { result in
      Logger.shared.log.debug("[DEBUG]: Launching from push notification...")
      guard let result = result else {
        AnnouncerError(type: .unwrapError, errorDescription: "Unable to unwrap push result!").relayTelemetry()
        Logger.shared.log.debug("[SEVERE]: Unable to unwrap result!")
        return
      }
      let payload = result.notification.payload
      guard let title = payload?.title else {
        AnnouncerError(type: .unwrapError, errorDescription: "Unable to unwrap payload title!").relayTelemetry()
        Logger.shared.log.debug("[SEVERE]: Unable to unwrap payload's title!")
        return
      }
      guard let fullMessage = payload?.body else {
        AnnouncerError(type: .unwrapError, errorDescription: "Unable to unwrap fullMessage!").relayTelemetry()
        Logger.shared.log.debug("[SEVERE]: Unable to unwrap fullMessage!")
        return
      }
      // Check if this is a "New Post!" type of message
      if title == "New Post!" {
        guard let additionalData = payload?.additionalData else {
          Logger.shared.log.debug("[SEVERE]: Unable to unwrap additional data dictionary from payload")
          return
        }
        guard let link = additionalData["link"] as? String else {
          Logger.shared.log.debug("[SEVERE]: Unable to unwrap link from additionalData array")
          return
        }
        guard let splitViewController = self.window!.rootViewController as? SplitViewController else {
          Logger.shared.log.debug("[SEVERE]: Unable to unwrap SplitViewController!")
          return
        }
        let payloadFeedItem = FeedItem()
        payloadFeedItem.title = fullMessage
        payloadFeedItem.link = link
        /*
         Please take note: there is a complicated chain of data passing here and I will explain it here

         This is the messaging mechanism for passing data from the push notification to the
         MainTableViewController
         AppDelegate > SplitViewController > SplitViewControllerPushDelegate > MainTableViewController

         Reason: This piece of code is run on a seperate thread that is different from the Main Thread.
         As a result, I cannot synchronously pass the data by setting some global property
         (which is bad practice in the first place)
         As such, a more complex messaging system was devised, based mostly on property observers and
         protocol/delegates was made to ensure relative robustness compaired to a global state.

         Steps:
         1. AppDelegate retrieves the feed item, assigns it as a property of the SplitViewController <-
         2. SplitViewController has a property observer on pushedFeedItem, which triggers a delegate call
         3. The MainTableViewController receives this delegate call, and initiates the segue
         */
        splitViewController.pushedFeedItem = payloadFeedItem
      } else {
        // Handle other types of push notifications here in the future
      }
    }
    return true
  }
  // swiftlint:enable line_length

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
