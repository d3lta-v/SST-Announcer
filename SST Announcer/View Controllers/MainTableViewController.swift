//
//  MainTableViewController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 22/11/16.
//  Copyright © 2016 FourierIndustries. All rights reserved.
//

import UIKit
import SGNavigationProgress

class MainTableViewController: UITableViewController {

  // MARK: - Variables

  fileprivate var collapseDetailViewController = true //When selected, this should turn false

  fileprivate var feeder = Feeder()
  fileprivate var filteredFeeds: [FeedItem] = []
  /// A `FeedItem` object that is pushed from push notifications
  fileprivate var pushedFeedItem: FeedItem?

  fileprivate var searchController: UISearchController = {
    let searchCtrl = UISearchController(searchResultsController: nil)
    searchCtrl.hidesNavigationBarDuringPresentation = false
    searchCtrl.dimsBackgroundDuringPresentation = false
    searchCtrl.searchBar.barStyle = .default
    return searchCtrl
  }()

  /// Progress tracking for UI only, loading will not actually be cancelled
  fileprivate var progressCancelled = false

  /// Computed property to check if the search controller is active
  fileprivate var searchControllerActive: Bool {
    return searchController.isActive && searchController.searchBar.text!.characters.count > 0
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    splitViewController!.delegate = self
    splitViewController!.preferredDisplayMode = .automatic

    // Set navigation bar to the search bar and set delegates
    navigationItem.titleView = searchController.searchBar
    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.delegate = self

    // Start loading feeds asynchronously
    feeder.delegate = self
    feeder.requestFeedsAsynchronous()

    // Add peek and pop
    if #available(iOS 9.0, *) {
      if traitCollection.forceTouchCapability == .available {
        registerForPreviewing(with: self, sourceView: view)
      }
    } else {
      // Fallback on earlier versions
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

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
          }
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

  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
    return collapseDetailViewController
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

  func feedFinishedParsing(withFeedArray feedArray: [FeedItem]?, error: Error?) {
    progressCancelled = false
    if let error = error {
      // Parse error here
      switch error {
      case AnnouncerError.networkError:
        print("Network error occured")
      default:
        print("Error occured")
      }
    } else {
      // No error occured
      DispatchQueue.main.async {
        self.tableView.reloadData()
        // Display push notification, if there is a push notification
        if let feedItem = self.pushedFeedItem {
          // Cycle through all events to find and select that item
          for (index, element) in self.feeder.feeds.enumerated() {
            if element.title == feedItem.title {
              let indexPath = IndexPath(row: index, section: 0)
              self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
          }
        }
      }
    }
  }

}

// MARK: - UISearch-related delegates

extension MainTableViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

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
    let viewIsCR = traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular
    let viewIsCC = traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .compact
    if viewIsCR || viewIsCC {
      detailVc.originalNavigationController = navigationController
    }
    previewingContext.sourceRect = cell.frame
    return detailVcNavController
  }

  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }

}
