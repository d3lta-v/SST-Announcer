//
//  PostInterfaceController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 17/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import WatchKit
import Foundation


class PostInterfaceController: WKInterfaceController {

  @IBOutlet weak var titleLabel: WKInterfaceLabel!
  @IBOutlet weak var authorLabel: WKInterfaceLabel!
  @IBOutlet weak var dateLabel: WKInterfaceLabel!
  @IBOutlet weak var contentLabel: WKInterfaceLabel!

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    // Configure interface objects here.
    if let feed = context as? FeedItem {
      titleLabel.setText(feed.title)
      authorLabel.setText(feed.author)
      dateLabel.setText(feed.date.decodeToTimeAgo())
      contentLabel.setAttributedText(feed.rawHtmlContent.attributedStringFromHTML)
      //contentLabel.setText(feed.rawHtmlContent.attributedStringFromHTML?.string)
    }
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

}
