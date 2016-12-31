//
//  SplitViewController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 31/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import UIKit

/// This is for propagation of the push notification
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
