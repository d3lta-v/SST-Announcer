//
//  SplitViewController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 31/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import UIKit

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
 1. AppDelegate retrieves the feed item, assigns it as a property of the SplitViewController
 2. SplitViewController has a property observer on pushedFeedItem, which triggers a delegate call <-
 3. The MainTableViewController receives this delegate call, and initiates the segue
 */

/// This is for propagation of push notifications
protocol SplitViewControllerPushDelegate: class {

  func feedPushed()

}

class SplitViewController: UISplitViewController {

  internal var pushDelegate: SplitViewControllerPushDelegate?
  internal var pushedFeedItem: FeedItem? {
    didSet {
      // call delegate method
      self.pushDelegate?.feedPushed()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}
