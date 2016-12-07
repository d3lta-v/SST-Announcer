//
//  DateExtensions.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 29/11/16.
//  Copyright © 2016 Pan Ziyue. All rights reserved.
//

import Foundation

extension DateFormatter {

  /// Initialises a DateFormatter object with a `en_US_POSIX` locale
  /// - returns: A `DateFormatter` object with a "safe" locale
  public class func initWithSafeLocale() -> DateFormatter {
    let df = DateFormatter()
    let locale = Locale(identifier: "en_US_POSIX")
    df.locale = locale
    return df
  }

}

extension Date {

  /// Decodes a date to ___ mins ago or ___ hrs ago. If all else fails,
  /// this method will decode the date to a yyyy/MM/dd format (ISO 8601)
  /// - returns: An optional `String` that represents how much time passed
  public func decodeToTimeAgo() -> String {
    let dateToDecode = self
    let currentDate = Date()
    let difference = currentDate.timeIntervalSince(dateToDecode)
    if difference < 24*60*60 { // Between 1hr and 24 hours
      return "Today"
    } else if difference >= 24*60*60 && difference < 24*60*60*14 { //Between 1day and 1fortnight
      let days = Int(round(difference/60/60/24))
      switch days {
      case 1:
        return "Yesterday"
      default:
        return "\(days) days"
      }
    } else {
      // Return date of post
      let dateFormatter = DateFormatter.initWithSafeLocale()
      dateFormatter.dateFormat = "d.M.yy"
      return dateFormatter.string(from: dateToDecode)
    }
  }

}
