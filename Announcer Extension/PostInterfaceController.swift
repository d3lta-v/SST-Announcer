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
  @IBOutlet weak var timeLabel: WKInterfaceLabel!
  @IBOutlet weak var contentLabel: WKInterfaceLabel!

  let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US_POSIX")
    df.dateFormat = "h:mm a"
    return df
  }()

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    // Configure interface objects here.
    if let feed = context as? FeedItem {
      titleLabel.setText(feed.title)
      authorLabel.setText(feed.author)
      dateLabel.setText(feed.date.decodeToTimeAgo())
      timeLabel.setText(dateFormatter.string(from: feed.date))
      contentLabel.setAttributedText(feed.rawHtmlContent.attributedStringFromHTML)
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
