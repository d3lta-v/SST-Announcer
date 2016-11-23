//
//  FeedKit.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 23/11/16.
//  Copyright © 2016 Pan Ziyue. All rights reserved.
//

import Foundation

public class FeedItem: NSObject, NSCoding {

    public var title: String
    public var link: String
    public var date: String
    public var author: String
    public var content: String

    public init(title: String, link: String, date: String, author: String, content: String) {
        self.title = title
        self.link = link
        self.date = date
        self.author = author
        self.content = content
    }

    // MARK: NSCoding

    required public init?(coder aDecoder: NSCoder) {
        self.title = (aDecoder.decodeObject(forKey: "title") as? String)!
        self.link = (aDecoder.decodeObject(forKey: "link") as? String)!
        self.date = (aDecoder.decodeObject(forKey: "date") as? String)!
        self.author = (aDecoder.decodeObject(forKey: "author") as? String)!
        self.content = (aDecoder.decodeObject(forKey: "content") as? String)!

        super.init()
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.link, forKey: "link")
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.author, forKey: "author")
        aCoder.encode(self.content, forKey: "content")
    }

}
