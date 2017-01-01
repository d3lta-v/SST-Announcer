//
//  PostRowController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 17/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import WatchKit

class PostRowController: NSObject {

  @IBOutlet var readIndicator: WKInterfaceGroup!
  @IBOutlet var titleLabel: WKInterfaceLabel!
  @IBOutlet var dateLabel: WKInterfaceLabel!
  @IBOutlet var authorLabel: WKInterfaceLabel!

  var feed: FeedItem? {
    didSet {
      guard let feed = feed else {
        return
      }
      titleLabel.setText(feed.title)
      dateLabel.setText(feed.date.decodeToTimeAgo())
      authorLabel.setText(feed.author)
      readIndicator.setAlpha(feed.read ? 0 : 1)
    }
  }

}
