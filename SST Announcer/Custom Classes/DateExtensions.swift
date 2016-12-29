//
//  DateExtensions.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 29/11/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
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
    let calendar = Calendar(identifier: .gregorian)
    let dateToDecode = calendar.startOfDay(for: self)
    let currentDate = calendar.startOfDay(for: Date())
    let components = calendar.dateComponents([.day], from: dateToDecode, to: currentDate)
    let difference = components.day!

    if difference < 1 {
      return "Today"
    } else if difference < 14 {
      switch difference {
      case 1:
        return "Yesterday"
      default:
        return "\(difference) days"
      }
    } else {
      let dateFormatter = DateFormatter.initWithSafeLocale()
      dateFormatter.dateFormat = "d.M.yy"
      return dateFormatter.string(from: dateToDecode)
    }
  }

}

func <= (lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.timeIntervalSince1970 <= rhs.timeIntervalSince1970
}

func >= (lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.timeIntervalSince1970 >= rhs.timeIntervalSince1970
}

func > (lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970
}

func < (lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}

func == (lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}
