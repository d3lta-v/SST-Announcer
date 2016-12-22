//
//  MainTableController.swift
//  Announcer Extension
//
//  Created by Pan Ziyue on 16/12/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import WatchKit
import Foundation

class MainTableController: WKInterfaceController {

  fileprivate let feeder = Feeder()

  @IBOutlet weak var table: WKInterfaceTable!

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    // Configure interface objects here.
    feeder.delegate = self
    feeder.requestFeedsAsynchronous()
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    let context = feeder.feeds[rowIndex]
    pushController(withName: "Post", context: context)
  }

  @IBAction func refreshTapped() {
    feeder.requestFeedsAsynchronous()
  }

}

extension MainTableController: FeederDelegate {

  func feedFinishedParsing(withFeedArray feedArray: [FeedItem]?, error: Error?) {
    DispatchQueue.main.async {
      self.table.setNumberOfRows(self.feeder.feeds.count, withRowType: "postRow")
      for i in 0..<self.feeder.feeds.count {
        guard let controller = self.table.rowController(at: i) as? PostRowController else {
          //TODO: Relay telemetry, severe error may have occured
          continue
        }
        controller.feed = self.feeder.feeds[i]
      }
    }
  }

  func feedLoadedFromCache() {
  }

  func feedLoadedPercent(_ percent: Float) {
    print("Loaded percent: \(percent * 100)")
  }

}
