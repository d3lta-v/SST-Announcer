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

class PostViewController: UIViewController {

    // MARK: - Variables

    internal var feedObject: FeedItem?

    // MARK: - IBOutlets

    @IBOutlet weak var textView: DTAttributedTextView! {
        didSet {
            //self.textView.textDelegate = self
            self.textView.shouldDrawImages = true
            self.textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 32, right: 16)
        }
    }

    var webView: WKWebView = WKWebView(frame: CGRect.zero)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true

        // Automatically show popover if device is an iPad in Portrait (size class is regular, regular)
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
        var errorHtml = try! String(contentsOfFile: errorFileName)
        errorHtml = errorHtml.replacingOccurrences(of: "errMsg", with: errString)
        self.webView.loadHTMLString(errorHtml, baseURL: nil)
        self.webView.isHidden = false
        self.textView.isHidden = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
