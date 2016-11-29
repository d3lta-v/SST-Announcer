//
//  FeedItem.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 23/11/16.
//  Copyright © 2016 Pan Ziyue. All rights reserved.
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

    public init(title: String, link: String, date: Date, author: String, rawHtml: String, strippedHtml: String) {
        self.title = title
        self.link = link
        self.date = date
        self.author = author
        self.rawHtmlContent = rawHtml
        self.strippedHtmlContent = strippedHtml

        super.init()
    }

    // MARK: - NSCoding

    required public init?(coder aDecoder: NSCoder) {
        self.title = (aDecoder.decodeObject(forKey: "title") as? String)!
        self.link = (aDecoder.decodeObject(forKey: "link") as? String)!
        self.date = (aDecoder.decodeObject(forKey: "date") as? Date)!
        self.author = (aDecoder.decodeObject(forKey: "author") as? String)!
        self.rawHtmlContent = (aDecoder.decodeObject(forKey: "rawHtmlContent") as? String)!
        self.strippedHtmlContent = (aDecoder.decodeObject(forKey: "strippedHtmlContent") as? String)!

        super.init()
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.link, forKey: "link")
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.author, forKey: "author")
        aCoder.encode(self.rawHtmlContent, forKey: "rawHtmlContent")
        aCoder.encode(self.strippedHtmlContent, forKey: "strippedHtmlContent")
    }

}
