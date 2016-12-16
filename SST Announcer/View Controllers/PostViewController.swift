//
//  PostViewController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 22/11/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import UIKit
import DTCoreText
import WebKit
import SnapKit
import SafariServices
import SGNavigationProgress
import TUSafariActivity

class PostViewController: UIViewController {

  // MARK: - Variables

  var feedObject: FeedItem? {
    didSet {
      // Automatically set title
      self.title = feedObject?.title
    }
  }

  // MARK: - IBOutlets

  @IBOutlet weak var textView: DTAttributedTextView! {
    didSet {
      //textView.textDelegate = self
      textView.shouldDrawImages = true
      textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 32, right: 16)
      textView.textDelegate = self
    }
  }

  @IBOutlet weak var shareBarButtonItem: UIBarButtonItem!

  var webView: WKWebView = WKWebView(frame: CGRect.zero)

  var originalNavigationController: UINavigationController?

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    navigationItem.leftItemsSupplementBackButton = true

    // Automatically show popover if device is an iPad in Portrait (size class is reg, reg)
    let isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
    if splitViewController!.traitCollection.isRR && isPortrait {
      let btn = splitViewController!.displayModeButtonItem
      DispatchQueue.main.async {
        btn.target!.performSelector(inBackground: btn.action!, with: btn)
      }
    }

    if let feedItem = feedObject {
      loadFeed(feedItem)
    }

    // Initialise web view
    webView.navigationDelegate = self
    view.addSubview(webView)
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.snp.makeConstraints { make in
      make.edges.equalTo(view.snp.edges)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Add KVO for progress to webview
    webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController!.cancelSGProgress()
    // Remove observer
    webView.removeObserver(self, forKeyPath: "estimatedProgress")
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    let inset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: 0, right: 0)
    webView.scrollView.contentInset = inset
    webView.scrollView.scrollIndicatorInsets = inset
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - KVO

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "estimatedProgress" {
      print(webView.estimatedProgress)
      if webView.estimatedProgress != 1 {
        DispatchQueue.main.async {
          (self.originalNavigationController ?? self.navigationController!).setSGProgressPercentage(Float(self.webView.estimatedProgress * 100))
        }
      } else {
        DispatchQueue.main.async {
          (self.originalNavigationController ?? self.navigationController!).finishSGProgress()
        }
      }
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  // MARK: - Private convienience functions

  private func loadFeed(_ item: FeedItem) {
    if undisplayableTraitsExist(forItem: item) {
      webView.isHidden = false
      textView.isHidden = true
      guard let url = URL(string: item.link) else {
        displayError("Unable to open invalid URL: \(item.link)")
        return
      }
      let urlRequest = URLRequest(url: url)
      webView.load(urlRequest)
    } else {
      displayFeedNormally(item)
    }
  }

  private func displayFeedNormally(_ item: FeedItem) {
    webView.isHidden = true
    textView.isHidden = false
    let builderOptions = [
      DTDefaultFontFamily: UIFont.systemFont(ofSize: UIFont.systemFontSize).familyName,
      DTDefaultFontSize: String.getPixelSizeForDynamicType(),
      DTDefaultLineHeightMultiplier: "1.43",
      DTDefaultLinkColor: "#146FDF",
      DTDefaultLinkDecoration: "",
      ]
    guard let htmlData = item.rawHtmlContent.data(using: .utf8) else {
      //TODO: Show error
      return
    }
    guard let stringBuilder = DTHTMLAttributedStringBuilder(html: htmlData, options: builderOptions, documentAttributes: nil) else {
      //TODO: Show error
      return
    }
    textView.attributedString = stringBuilder.generatedAttributedString()
  }

  private func undisplayableTraitsExist(forItem item: FeedItem) -> Bool {
    let content = item.rawHtmlContent
    if content.range(of: "<iframe") != nil {
      return true
    }
    if content.range(of: "<table") != nil {
      return true
    }
    return false
  }

  fileprivate func displayError(_ errString: String) {
    let errorFileName = Bundle.main.path(forResource: "MobileSafariError", ofType: "html")!
    do {
      var errorHtml = try String(contentsOfFile: errorFileName)
      errorHtml = errorHtml.replacingOccurrences(of: "errMsg", with: errString)
      webView.loadHTMLString(errorHtml, baseURL: nil)
    } catch {
      fatalError("Serious error has occured, app unable to locate MobileSafariError.html")
    }
    webView.isHidden = false
    textView.isHidden = true
  }

  // MARK: - IBActions

  @IBAction func shareTapped(_ sender: Any) {
    guard let feedObject = feedObject else {
      return
    }
    guard let url = URL(string: feedObject.link) else {
      return
    }
    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: [TUSafariActivity()])
    activityVC.popoverPresentationController?.barButtonItem = shareBarButtonItem
    navigationController!.present(activityVC, animated: true, completion: nil)
  }

  /*
   // MARK: - Navigation

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

}

// MARK: - WKNavigationDelegate

extension PostViewController: WKNavigationDelegate {

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    (originalNavigationController ?? navigationController!).cancelSGProgress()
    displayError("Unable to open webpage: \(error.localizedDescription)")
    print(error.localizedDescription)
  }

  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    (originalNavigationController ?? navigationController!).cancelSGProgress()
    displayError("Unable to open webpage: \(error.localizedDescription)")
    print(error.localizedDescription)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    // set progress to 0
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //0.5 seconds
      (self.originalNavigationController ?? self.navigationController!).cancelSGProgress()
    }
  }

}

// MARK: - DTAttributedContentView-related delegates

extension PostViewController: DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, DTWebVideoViewDelegate {

  func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {
    let linkButton = DTLinkButton(frame: frame)
    linkButton.url = url
    //TODO: Add action via selector
    linkButton.addTarget(self, action: #selector(linkPushed(_:)), for: .touchUpInside)
    return linkButton
  }

  func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewFor attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
    if attachment.isKind(of: DTImageTextAttachment.self) {
      let imageView = DTLazyImageView(frame: frame)
      imageView.delegate = self
      imageView.url = attachment.contentURL
      if attachment.hyperLinkURL != nil {
        imageView.isUserInteractionEnabled = true
        let button = DTLinkButton(frame: imageView.bounds)
        button.url = attachment.hyperLinkURL
        button.minimumHitSize = CGSize(width: 25, height: 25)
        button.guid = attachment.hyperLinkGUID
        //TODO: Add action via selector
        button.addTarget(self, action: #selector(linkPushed(_:)), for: .touchUpInside)
        imageView.addSubview(button)
      }
      return imageView
    }
    return nil
  }

  func lazyImageView(_ lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
    let url = lazyImageView.url!
    var imageSize = size
    var screenSize = view.bounds.size
    screenSize.width -= 32

    if size.width > screenSize.width {
      let ratio = screenSize.width/size.width
      imageSize.width = size.width*ratio
      imageSize.height = size.height*ratio
    }

    let pred = NSPredicate(format: "contentURL == %@", url as CVarArg)

    var didUpdate = false

    guard var predicateArray: [DTTextAttachment] = textView.attributedTextContentView.layoutFrame.textAttachments(with: pred) as? [DTTextAttachment] else {
      //TODO: Log severe message here to server
      return
    }

    for index in 0..<predicateArray.count {
      if predicateArray[index].originalSize.equalTo(CGSize.zero) {
        predicateArray[index].originalSize = imageSize
        didUpdate = true
      }
    }

    if didUpdate {
      textView.relayoutText()
    }
  }

  @objc private func linkPushed(_ button: DTLinkButton) {
    guard let url = button.url else {
      //TODO: Log something here back to developer, including the absoluteString of the URL
      return
    }
    if UIApplication.shared.canOpenURL(url.absoluteURL) {
      let urlString = url.absoluteString
      if urlString.hasPrefix("http") {
        if #available(iOS 9.0, *) {
          let safariViewControler = SFSafariViewController(url: url)
          present(safariViewControler, animated: true, completion: nil)
        } else {
          // Fallback to redirecting the user to Safari
          UIApplication.shared.openURL(url)
        }
      } else if urlString.hasPrefix("mailto") || urlString.hasPrefix("tel") {
        // This is to catch malicious URLs opening unintended apps
        UIApplication.shared.openURL(url)
      }
    } else {
      if url.host == nil && url.path.characters.count == 0 {
        guard let fragment = url.fragment else {
          return
        }
        textView.scroll(toAnchorNamed: fragment, animated: true)
      }
    }
  }

}
