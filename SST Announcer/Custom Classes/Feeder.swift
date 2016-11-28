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
    func feedLoadedPercent(_ percent: Double)

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
    fileprivate var currentFeedItem = FeedItem(title: "", link: "", date: "", author: "", rawHtml: "", strippedHtml: "")
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

        self.feeds.removeAll()

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
        self.expectedContentLength = response.expectedContentLength
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.buffer.append(data)
        let percentDownloaded = Double(buffer.count) / Double(expectedContentLength)
        self.delegate?.feedLoadedPercent(percentDownloaded)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            self.delegate?.feedFinishedParsing(withFeedArray: nil, error: AnnouncerError.networkError)
        } else {
            // Completed loading with no network errors, start the parser
            self.parser = XMLParser(data: self.buffer)
            self.parser.delegate = self
            self.parser.shouldResolveExternalEntities = false
            self.parser.parse()
        }
    }

}

// MARK: - XMLParserDelegate

extension Feeder: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.currentElement = elementName
        if elementName == "entry" {
            self.currentFeedItem = FeedItem(title: "", link: "", date: "", author: "", rawHtml: "", strippedHtml: "")
        } else if elementName == "link" {
            if attributeDict["rel"] == "alternate" && attributeDict["href"] != "http://studentsblog.sst.edu.sg/" {
                self.currentFeedItem.link = attributeDict["href"]!
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "entry" {
            // Clean up "dirty" HTML by removing stuff caused by Blogger's editor
            self.currentFeedItem.rawHtmlContent = self.currentFeedItem.rawHtmlContent.cleanHTML
            // Strip HTML tags away for better previews, as well as decoding HTML entities
            let decodedHtml = self.currentFeedItem.rawHtmlContent.stringByDecodingHTMLEntities
            self.currentFeedItem.strippedHtmlContent = decodedHtml.strippedHTML.trunc(140)
            // Append to feeds array
            self.feeds.append(currentFeedItem)
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.currentElement == "title" {
            self.currentFeedItem.title += string
        } else if self.currentElement == "link" {
            self.currentFeedItem.link += string
        } else if self.currentElement == "published" {
            if let date = self.rssDateFormatter.date(from: string) {
                self.currentFeedItem.date += self.longDateFormatter.string(from: date)
            } else {
                print("Unable to parse date! RSS format may have changed!")
            }
        } else if self.currentElement == "name" {
            // Name of author
            self.currentFeedItem.author += string
        } else if self.currentElement == "content" {
            self.currentFeedItem.rawHtmlContent += string
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        self.delegate?.feedFinishedParsing(withFeedArray: self.feeds, error: nil)
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.delegate?.feedFinishedParsing(withFeedArray: nil, error: AnnouncerError.parseError)
    }

}
