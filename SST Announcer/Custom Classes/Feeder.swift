//
//  Feeder.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 23/11/16.
//  Copyright © 2016 Pan Ziyue. All rights reserved.
//

import UIKit

protocol FeederDelegate: class {

  func feedFinishedParsing(withFeedArray feedArray: [FeedItem]?, error: Error?)
  func feedLoadedPercent(_ percent: Float)

}

/// A collection of all the possible errors that the entire Announcer app can
/// propagate from class to class, optimised for maximum interoperability
enum AnnouncerError: Error {
  /// A network error occured
  case networkError
  /// The program was unable to unwrap data from nil to a non-nil value
  case unwrapError
  /// The parser was unable to validate the XML
  case validationError
  /// The parser was unable to parse the XML
  case parseError
}

class Feeder: NSObject {

  fileprivate var expectedContentLength: Int64 = 0
  fileprivate var buffer: Data = Data()

  fileprivate var parser: XMLParser!
  internal var feeds: [FeedItem] = []
  fileprivate var currentFeedItem = FeedItem(title: "", link: "", date: Date(), author: "", rawHtml: "", strippedHtml: "", read: false)
  fileprivate var currentElement = ""

  /**
   Date formatter specific to Blogger RSS 2.0 datestamps
   NOTE: This is NOT ISO8601!
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

  internal func requestFeedsAsynchronous() {
    let request = URLRequest(url: URL(string: "https://node1.sstinc.org/api/cache/blogrss.csv")!)

    feeds.removeAll()

    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    let dataTask = session.dataTask(with: request)
    dataTask.resume()
    session.finishTasksAndInvalidate()
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
    if let error = error {
      print(error.localizedDescription)
      delegate?.feedFinishedParsing(withFeedArray: nil, error: AnnouncerError.networkError)
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
      currentFeedItem = FeedItem(title: "", link: "", date: Date(), author: "", rawHtml: "", strippedHtml: "", read: false)
    } else if elementName == "link" {
      if attributeDict["rel"] == "alternate" && attributeDict["href"] != "http://studentsblog.sst.edu.sg/" {
        currentFeedItem.link = attributeDict["href"]!
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "entry" {
      // Clean up "dirty" HTML by removing stuff caused by Blogger's editor
      currentFeedItem.rawHtmlContent = currentFeedItem.rawHtmlContent.cleanHTML
      // Strip HTML tags away for better previews, as well as decoding HTML entities
      let decodedHtml = currentFeedItem.rawHtmlContent.stringByDecodingHTMLEntities
      currentFeedItem.strippedHtmlContent = decodedHtml.strippedHTML.trunc(280)
      // Append to feeds array
      feeds.append(currentFeedItem)
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
        print("Unable to parse date! RSS format may have changed!")
      }
    } else if currentElement == "name" {
      // Name of author
      currentFeedItem.author += string
    } else if currentElement == "content" {
      currentFeedItem.rawHtmlContent += string
    }
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    delegate?.feedFinishedParsing(withFeedArray: feeds, error: nil)
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    delegate?.feedFinishedParsing(withFeedArray: nil, error: AnnouncerError.parseError)
  }

}
