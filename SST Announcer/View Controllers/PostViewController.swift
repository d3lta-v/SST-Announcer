//
//  PostViewController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 22/11/16.
//  Copyright © 2016 Pan Ziyue. All rights reserved.
//

import UIKit
import DTCoreText
import WebKit
import SnapKit
import SafariServices

class PostViewController: UIViewController {

    // MARK: - Variables

    internal var feedObject: FeedItem?

    // MARK: - IBOutlets

    @IBOutlet weak var textView: DTAttributedTextView! {
        didSet {
            //self.textView.textDelegate = self
            self.textView.shouldDrawImages = true
            self.textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 32, right: 16)
            self.textView.textDelegate = self
        }
    }

    var webView: WKWebView = WKWebView(frame: CGRect.zero)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true

        // Automatically show popover if device is an iPad in Portrait (size class is reg, reg)
        let horizontalIsRegular = UIScreen.main.traitCollection.horizontalSizeClass == .regular
        let verticalIsRegular = UIScreen.main.traitCollection.verticalSizeClass == .regular
        let isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
        if horizontalIsRegular && verticalIsRegular && isPortrait {
            let btn = self.splitViewController!.displayModeButtonItem
            btn.target!.performSelector(inBackground: btn.action!, with: btn)
        }

        if let feedItem = self.feedObject {
            self.loadFeed(feedItem)
        }

        //self.webView.isHidden = true
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.snp.edges)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let inset = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: 0, right: 0)
        self.webView.scrollView.contentInset = inset
        self.webView.scrollView.scrollIndicatorInsets = inset
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private convienience functions

    private func loadFeed(_ item: FeedItem) {
        if undisplayableTraitsExist(forItem: item) {
            self.webView.isHidden = false
            self.textView.isHidden = true
            guard let url = URL(string: item.link) else {
                self.displayError("Unable to open invalid URL: \(item.link)")
                return
            }
            let urlRequest = URLRequest(url: url)
            self.webView.load(urlRequest)
        } else {
            self.displayFeedNormally(item)
        }
    }

    private func displayFeedNormally(_ item: FeedItem) {
        self.webView.isHidden = true
        self.textView.isHidden = false
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
        self.textView.attributedString = stringBuilder.generatedAttributedString()
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
            self.webView.loadHTMLString(errorHtml, baseURL: nil)
        } catch {
            fatalError("Serious error has occured, app unable to locate MobileSafariError.html")
        }
        self.webView.isHidden = false
        self.textView.isHidden = true
    }

    /*
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PostViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //self.navigationController?.cancelSGProgress()
        //_ = self.navigationController?.popViewController(animated: true)
        self.displayError("Unable to open webpage: \(error.localizedDescription)")
        print(error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //self.navigationController?.cancelSGProgress()
        //_ = self.navigationController?.popViewController(animated: true)
        self.displayError("Unable to open webpage: \(error.localizedDescription)")
        print(error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // set progress to 0
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //0.5 seconds
//            self.navigationController?.cancelSGProgress()
//        }
    }

}

extension PostViewController: DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, DTWebVideoViewDelegate {

    func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {
        let linkButton = DTLinkButton(frame: frame)
        linkButton.url = url
        //TODO: Add action via selector
        linkButton.addTarget(self, action: #selector(self.linkPushed(_:)), for: .touchUpInside)
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
                button.addTarget(self, action: #selector(self.linkPushed(_:)), for: .touchUpInside)
                imageView.addSubview(button)
            }
            return imageView
        }
        return nil
    }

    func lazyImageView(_ lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        let url = lazyImageView.url!
        var imageSize = size
        var screenSize = self.view.bounds.size
        screenSize.width -= 32

        if size.width > screenSize.width {
            let ratio = screenSize.width/size.width
            imageSize.width = size.width*ratio
            imageSize.height = size.height*ratio
        }

        let pred = NSPredicate(format: "contentURL == %@", url as CVarArg)

        var didUpdate = false

        guard var predicateArray: [DTTextAttachment] = self.textView.attributedTextContentView.layoutFrame.textAttachments(with: pred) as? [DTTextAttachment] else {
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
            self.textView.relayoutText()
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
                    self.present(safariViewControler, animated: true, completion: nil)
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
                self.textView.scroll(toAnchorNamed: fragment, animated: true)
            }
        }
    }

}
