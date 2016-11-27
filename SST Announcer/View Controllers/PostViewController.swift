//
//  PostViewController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 22/11/16.
//  Copyright © 2016 Pan Ziyue. All rights reserved.
//

import UIKit
import DTCoreText

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true

        // Automatically show popover if device is an iPad in Portrait
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private convienience functions

    private func loadFeed(_ item: FeedItem) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
