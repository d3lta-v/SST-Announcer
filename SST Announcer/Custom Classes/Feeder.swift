//
//  Feeder.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 23/11/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import UIKit

protocol FeederDelegate: class {

  func feedFinishedParsing(withFeedArray feedArray: [FeedItem]?, error: Error?)
  func feedLoadedFromCache()
  func feedLoadedPercent(_ percent: Float)

}

class Feeder: NSObject {

  private let request: URLRequest = {
    let url = URL(string: "https://node1.sstinc.org/api/cache/blogrss.csv")!
    let rq = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
    return rq
  }()
  private var config = URLSessionConfiguration.default
  private var session: URLSession?
  fileprivate var expectedContentLength: Int64 = 0
  fileprivate var buffer: Data = Data()

  private let defaults = UserDefaults.standard

  fileprivate var parser: XMLParser!
  internal var feeds: [FeedItem] = []
  internal var loading = false
  fileprivate var currentFeedItem = FeedItem()
  fileprivate var currentElement = ""

  /**
   Date formatter specific to Blogger RSS 2.0 datestamps
   NOTE: This is similar to, but NOT ISO8601!
   */
  fileprivate var rssDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    return dateFormatter
  }()
  fileprivate var longDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm"
    return dateFormatter
  }()

  internal var delegate: FeederDelegate?

  /// Requests for feeds asynchronously and caches them
  internal func requestFeedsAsynchronous() {
    buffer = Data() //clear buffer, this is very important for refreshing logic to work
    expectedContentLength = 0

    loading = true
    session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    let dataTask = session!.dataTask(with: request)
    dataTask.resume()
    session!.finishTasksAndInvalidate()
  }

  /**
   Stores a copy of the cached feeds to NSUserDefaults, serializes it and stores it as Data.
   - parameter feeds: An array of `FeedItem` s.
   */
  internal func setCachedFeeds() {
    NSKeyedArchiver.setClassName("FeedItem", for: FeedItem.self)
    let cachedData = NSKeyedArchiver.archivedData(withRootObject: feeds)
    defaults.set(cachedData, forKey: "feedCache")
  }

  /// Retreives a copy of the cached feeds from NSUserDefaults, 
  /// deserializes it and returns it to a FeedItem object
  internal func getCachedFeeds() {
    guard let feedsObject = defaults.object(forKey: "feedCache") as? Data else {
      return
    }
    NSKeyedUnarchiver.setClass(FeedItem.self, forClassName: "FeedItem")
    guard let cachedFeeds = NSKeyedUnarchiver.unarchiveObject(with: feedsObject) as? [FeedItem] else {
      return
    }
    feeds = cachedFeeds
    delegate?.feedLoadedFromCache()
  }

}

// MARK: - URLSessionDataDelegate

extension Feeder: URLSessionDataDelegate {

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    expectedContentLength = response.expectedContentLength
    completionHandler(.allow)
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    buffer.append(data)
    let percentDownloaded = Float(buffer.count) / Float(expectedContentLength)
    delegate?.feedLoadedPercent(percentDownloaded)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    loading = false
    if let error = error {
      let error = AnnouncerError(type: .networkError, errorDescription: error.localizedDescription)
      delegate?.feedFinishedParsing(withFeedArray: nil, error: error)
    } else {
      // Completed loading with no network errors, start the parser
      parser = XMLParser(data: buffer)
      parser.delegate = self
      parser.shouldResolveExternalEntities = false
      parser.parse()
    }
  }

}

// MARK: - XMLParserDelegate

extension Feeder: XMLParserDelegate {

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElement = elementName
    if elementName == "entry" {
      currentFeedItem = FeedItem()
    } else if elementName == "link" {
      let studentsBlogUrl = "http://studentsblog.sst.edu.sg/"
      if attributeDict["rel"] == "alternate" && attributeDict["href"] != studentsBlogUrl {
        currentFeedItem.link = attributeDict["href"]!
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "entry" {
      // Clean up "dirty" HTML by removing stuff caused by Blogger's editor
      currentFeedItem.rawHtmlContent = currentFeedItem.rawHtmlContent.cleanHTML
      // Strip HTML tags away for better previews on table views, as well as decoding HTML entities
      let decodedHtml = currentFeedItem.rawHtmlContent.stringByDecodingHTMLEntities
      currentFeedItem.strippedHtmlContent = decodedHtml.cleanerHTML(withNewlineCharacter: " ", compactNewlines: true).strippedHTML.truncate(280)
      // Append to feeds array
      var sameElement = false
      var elementChanged = false
      var indexChanged = -1
      for (index, feed) in feeds.enumerated() {
        if currentFeedItem.link == feed.link {
          sameElement = true
        }
        if currentFeedItem.date == feed.date && currentFeedItem.rawHtmlContent != feed.rawHtmlContent {
          // An article with the same publication date has its content altered
          if !elementChanged {
            indexChanged = index
            elementChanged = true
          }
        }
      }
      if !sameElement {
        feeds.insert(currentFeedItem, at: 0)
      } else if elementChanged {
        // If it is the same element and the element was changed at index
        feeds[indexChanged] = currentFeedItem
      }
    }
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if currentElement == "title" {
      currentFeedItem.title += string
    } else if currentElement == "link" {
      currentFeedItem.link += string
    } else if currentElement == "published" {
      if let date = rssDateFormatter.date(from: string) {
        currentFeedItem.date = date
      } else {
        // swiftlint:disable:next line_length
        let error = AnnouncerError(type: .validationError, errorDescription: "Unable to parse date! RSS format has changed!")
        print(error)
      }
    } else if currentElement == "name" {
      // Name of author
      currentFeedItem.author += string
    } else if currentElement == "content" {
      currentFeedItem.rawHtmlContent += string
    }
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    // Sort feeds
    feeds.sort { lhs, rhs in
      return lhs.date > rhs.date
    }
    // Truncate feeds if there are more than 30 feeds to prevent "overcaching"
    if feeds.count > 30 {
      feeds.removeLast(feeds.count - 30)
    }
    // Set cached feeds
    setCachedFeeds()
    delegate?.feedFinishedParsing(withFeedArray: feeds, error: nil)
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    let error = AnnouncerError(type: .parseError, errorDescription: parseError.localizedDescription)
    delegate?.feedFinishedParsing(withFeedArray: nil, error: error)
  }

}
