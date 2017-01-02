//
//  MainTableViewController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 22/11/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import UIKit
import SGNavigationProgress
import JGProgressHUD

class MainTableViewController: UITableViewController {

  // MARK: - Variables

  // MARK: UI Assistants
  /// Tracks the state of whether or not to collapse the detail view controller
  fileprivate var collapseDetailViewController = true
  /// Progress tracking for UI only, loading will not actually be cancelled
  fileprivate var progressCancelled = false
  /// Computed property to check if the search controller is active
  fileprivate var searchControllerActive: Bool {
    return searchController.isActive && searchController.searchBar.text!.characters.count > 0
  }

  // MARK: Feeder related variables
  fileprivate var feeder = Feeder()
  fileprivate var filteredFeeds: [FeedItem] = []
  /// A `FeedItem` object that is pushed from push notifications, automatically
  /// retrieving it from AppDelegate
  fileprivate var pushedFeedItem: FeedItem?

  // MARK: UI
  fileprivate var searchController: UISearchController = {
    let searchCtrl = UISearchController(searchResultsController: nil)
    searchCtrl.hidesNavigationBarDuringPresentation = false
    searchCtrl.dimsBackgroundDuringPresentation = false
    searchCtrl.searchBar.barStyle = .default
    return searchCtrl
  }()
  let pushHud: JGProgressHUD = {
    let hud = JGProgressHUD(style: .dark)!
    hud.interactionType = .blockTouchesOnHUDView
    hud.textLabel.text = "Opening Push Notification..."
    return hud
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize necessary push notification delegates
    // swiftlint:disable:next force_cast
    let splitViewController = self.splitViewController! as! SplitViewController
    splitViewController.pushDelegate = self

    // UI
    splitViewController.delegate = self
    splitViewController.preferredDisplayMode = .automatic

    // Set navigation bar to the search bar and set delegates
    navigationItem.titleView = searchController.searchBar
    //searchController.delegate = self
    searchController.searchResultsUpdater = self
    //searchController.searchBar.delegate = self

    // Add refresh control
    refreshControl = UIRefreshControl()
    // swiftlint:disable:next line_length
    refreshControl?.addTarget(self, action: #selector(refreshTriggered(sender:)), for: .valueChanged)

    // Start loading feeds asynchronously
    feeder.delegate = self
    feeder.getCachedFeeds()
    feeder.requestFeedsAsynchronous()

    // Add peek and pop
    if #available(iOS 9.0, *) {
      if traitCollection.forceTouchCapability == .available {
        registerForPreviewing(with: self, sourceView: view)
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    progressCancelled = true
    navigationController!.cancelSGProgress()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Objective-C selectors and helpers

  fileprivate func displayError(_ error: AnnouncerError) {
    DispatchQueue.main.async {
      let errorHud = JGProgressHUD(style: .dark)!
      errorHud.indicatorView = JGProgressHUDErrorIndicatorView()
      errorHud.interactionType = .blockTouchesOnHUDView
      switch error.errorType {
      case .networkError:
        errorHud.textLabel.text = "Network error occured"
        errorHud.detailTextLabel.text = error.localizedDescription
      case .parseError:
        errorHud.textLabel.text = "Parsing error occured"
      case .unwrapError:
        errorHud.textLabel.text = "Internal error occured"
      default:
        errorHud.textLabel.text = "Unknown error occured"
        let errorMessage = "Feed failed parsing and switched to default case"
        let error = AnnouncerError(type: .unknownError, errorDescription: errorMessage)
        error.relayTelemetry()
      }
      errorHud.show(in: self.splitViewController!.view)
      errorHud.dismiss(afterDelay: 2)
    }
  }

  @objc private func refreshTriggered(sender: Any) {
    feeder.requestFeedsAsynchronous()
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchControllerActive {
      return filteredFeeds.count
    }
    return feeder.feeds.count
  }

  // swiftlint:disable:next line_length
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // swiftlint:disable:next line_length
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath) as? PostTableViewCell else {
      fatalError("Unable to cast tableView's cell as a PostTableViewCell!")
    }

    // Configure the cell...
    var currentFeedObject: FeedItem!
    if searchControllerActive {
      currentFeedObject = filteredFeeds[indexPath.row]
    } else {
      currentFeedObject = feeder.feeds[indexPath.row]
    }

    if currentFeedObject.title.characters.count < 1 {
      cell.titleLabel.text = "<No Title>"
    } else {
      cell.titleLabel.text = currentFeedObject.title
    }
    cell.dateLabel.text = currentFeedObject.date.decodeToTimeAgo()
    cell.descriptionLabel.text = currentFeedObject.strippedHtmlContent
    cell.dateWidthConstraint.constant = cell.dateLabel.intrinsicContentSize.width
    cell.readIndicator.isHidden = currentFeedObject.read

    return cell
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    self.splitViewController?.view.endEditing(false)
    if segue.identifier == "presentPostFromMain" {
      if let navController = segue.destination as? UINavigationController {
        guard let postViewController = navController.topViewController as? PostViewController else {
          fatalError("Unable to unwrap navController topview as PostViewController")
        }
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
          if searchControllerActive {
            let selectedPost = filteredFeeds[selectedIndexPath.row]
            postViewController.feedObject = selectedPost
          } else {
            let selectedPost = feeder.feeds[selectedIndexPath.row]
            postViewController.feedObject = selectedPost
            selectedPost.read = true
            DispatchQueue.main.async {
              self.tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            // Refresh cache as the user has read a post
            feeder.setCachedFeeds()
          }
          // Conditionally pass the current navigation controller to the secondary view
          let viewIsCR = splitViewController!.traitCollection.isCR
          let viewIsCC = splitViewController!.traitCollection.isCC
          if viewIsCR || viewIsCC {
            postViewController.originalNavigationController = navigationController
          }
        }
      }
    }
  }

}

// MARK: - UISplitViewControllerDelegate

extension MainTableViewController: UISplitViewControllerDelegate {

  // swiftlint:disable:next line_length
  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
    return collapseDetailViewController
  }

}

// MARK: - SplitViewControllerPushDelegate

extension MainTableViewController: SplitViewControllerPushDelegate {

  /*
   Please take note: there is a complicated chain of data passing here and I will explain it here

   This is the messaging mechanism for passing data from the push notification to the
   MainTableViewController
   AppDelegate > SplitViewController > SplitViewControllerPushDelegate > MainTableViewController

   Reason: This piece of code is run on a seperate thread that is different from the Main Thread.
   As a result, I cannot synchronously pass the data by setting some global property
   (which is bad practice in the first place)
   As such, a more complex messaging system was devised, based mostly on property observers and
   protocol/delegates was made to ensure relative robustness compaired to a global state.

   Steps:
   1. AppDelegate retrieves the feed item, assigns it as a property of the SplitViewController
   2. SplitViewController has a property observer on pushedFeedItem, which triggers a delegate call
   3. The MainTableViewController receives this delegate call, and initiates the segue <-
   */

  func feedPushed() {
    // swiftlint:disable:next force_cast
    pushedFeedItem = (self.splitViewController as! SplitViewController).pushedFeedItem
    // Show HUD
    pushHud.show(in: self.splitViewController!.view)
    if !feeder.loading {
      // Reload from web just in case
      feeder.requestFeedsAsynchronous()
    }
  }

}

// MARK: - FeederDelegate

extension MainTableViewController: FeederDelegate {

  func feedLoadedPercent(_ percent: Float) {
    if !progressCancelled {
      let percentageInHundred = percent * 100
      DispatchQueue.main.async {
        self.navigationController!.setSGProgressPercentage(percentageInHundred)
      }
    }
  }

  func feedLoadedFromCache() {
  }

  func feedFinishedParsing(withFeedArray feedArray: [FeedItem]?, error: Error?) {
    progressCancelled = false
    DispatchQueue.main.async {
      if self.refreshControl!.isRefreshing {
        self.refreshControl!.endRefreshing()
      }
      if self.pushedFeedItem != nil {
        self.pushHud.dismiss()
      }
    }
    if let error = error as? AnnouncerError {
      // Display error here
      displayError(error)
    } else {
      DispatchQueue.main.async {
        self.tableView.reloadData()
        // Display push notification, if there is a push notification
        if let feedItem = self.pushedFeedItem {
          // Cycle through all feeds to find and select that post
          var successfullyOpenedPush = false
          for (index, element) in self.feeder.feeds.enumerated() {
            if element.link == feedItem.link {
              successfullyOpenedPush = true
              let indexPath = IndexPath(row: index, section: 0)
              self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
              self.performSegue(withIdentifier: "presentPostFromMain", sender: self)
            }
          }
          if !successfullyOpenedPush {
            // Show error
            let errorHud = JGProgressHUD(style: .dark)!
            errorHud.indicatorView = JGProgressHUDErrorIndicatorView()
            errorHud.textLabel.text = "Unable to open push"
            errorHud.interactionType = .blockTouchesOnHUDView
            errorHud.show(in: self.splitViewController!.view)
            errorHud.dismiss(afterDelay: 2)
          }
        }
        self.pushedFeedItem = nil //reset the variable
      }
    }
  }

}

// MARK: - UISearch-related delegates

extension MainTableViewController: UISearchResultsUpdating {

  func updateSearchResults(for searchController: UISearchController) {
    filter(forSearchText: searchController.searchBar.text!)
  }

  private func filter(forSearchText searchText: String) {
    filteredFeeds = feeder.feeds.filter { feed in
      return feed.title.lowercased().contains(searchText.lowercased())
    }
    tableView.reloadData()
  }

}

// MARK: - UIViewcontrollerPreviewingDelegate

@available(iOS 9.0, *) //only available on iOS 9 and above
extension MainTableViewController: UIViewControllerPreviewingDelegate {

  // swiftlint:disable line_length
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
    guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
    guard let detailVcNavController = storyboard!.instantiateViewController(withIdentifier: "PostNavigationController") as? UINavigationController else { return nil }
    guard let detailVc = detailVcNavController.topViewController as? PostViewController else { return nil }
    if searchControllerActive {
      detailVc.feedObject = filteredFeeds[indexPath.row]
    } else {
      detailVc.feedObject = feeder.feeds[indexPath.row]
    }
    let viewIsCR = splitViewController!.traitCollection.isCR
    let viewIsCC = splitViewController!.traitCollection.isCC
    if viewIsCR || viewIsCC {
      detailVc.originalNavigationController = navigationController
    }
    previewingContext.sourceRect = cell.frame
    return detailVcNavController
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }
  // swiftlint:enable line_length

}
