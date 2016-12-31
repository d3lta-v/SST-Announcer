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

  var pushedFeedItem: FeedItem?

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
          //TODO: Relay telemetry as this may be a severe failure
          Logger.shared.log.debug("[SEVERE]: Unable to unwrap additional data dictionary from payload")
          return
        }
        guard let link = additionalData["link"] as? String else {
          //TODO: Relay telemetry as this may be a severe failure
          Logger.shared.log.debug("[SEVERE]: Unable to unwrap link from additionalData array")
          return
        }
        let payloadFeedItem = FeedItem()
        payloadFeedItem.title = fullMessage
        payloadFeedItem.link = link
        self.pushedFeedItem = payloadFeedItem
        Logger.shared.log.debug("[DEBUG]: Successfully changed pushedFeedItem to non-nil value")
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
