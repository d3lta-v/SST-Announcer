//
//  FeedItem.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 23/11/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import Foundation

public class FeedItem: NSObject, NSCoding {

  // MARK: - Variables

  public var title: String
  public var link: String
  public var date: Date
  public var author: String
  public var rawHtmlContent: String
  public var strippedHtmlContent: String
  public var read: Bool

  init(title: String, link: String, date: Date, author: String, rawHtml: String, strippedHtml: String, read: Bool) {
    self.title = title
    self.link = link
    self.date = date
    self.author = author
    self.rawHtmlContent = rawHtml
    self.strippedHtmlContent = strippedHtml
    self.read = read

    super.init()
  }

  /// Initializes a fresh FeedItem object with minimal detail, meant to be an empty object
  convenience override init() {
    self.init(title: "",
              link: "",
              date: Date(),
              author: "",
              rawHtml: "",
              strippedHtml: "",
              read: false)
  }

  // MARK: - NSCoding

  required public init?(coder aDecoder: NSCoder) {
    title = (aDecoder.decodeObject(forKey: "title") as? String)!
    link = (aDecoder.decodeObject(forKey: "link") as? String)!
    date = (aDecoder.decodeObject(forKey: "date") as? Date)!
    author = (aDecoder.decodeObject(forKey: "author") as? String)!
    rawHtmlContent = (aDecoder.decodeObject(forKey: "rawHtmlContent") as? String)!
    strippedHtmlContent = (aDecoder.decodeObject(forKey: "strippedHtmlContent") as? String)!
    read = aDecoder.decodeBool(forKey: "read")

    super.init()
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(title, forKey: "title")
    aCoder.encode(link, forKey: "link")
    aCoder.encode(date, forKey: "date")
    aCoder.encode(author, forKey: "author")
    aCoder.encode(rawHtmlContent, forKey: "rawHtmlContent")
    aCoder.encode(strippedHtmlContent, forKey: "strippedHtmlContent")
    aCoder.encode(read, forKey: "read")
  }

}
