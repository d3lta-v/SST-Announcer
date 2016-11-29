//
//  MainTableViewController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 22/11/16.
//  Copyright © 2016 Pan Ziyue. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    // MARK: - Variables

    fileprivate var collapseDetailViewController = true //When selected, this should turn false

    fileprivate var feeder = Feeder()

    fileprivate var filteredFeeds: [FeedItem] = []

    fileprivate var searchController: UISearchController = {
        let searchCtrl = UISearchController(searchResultsController: nil)
        searchCtrl.hidesNavigationBarDuringPresentation = false
        searchCtrl.dimsBackgroundDuringPresentation = false
        searchCtrl.searchBar.barStyle = .default
        return searchCtrl
    }()

    /// Computed property to check if the search controller is active
    private var searchControllerActive: Bool {
        return self.searchController.isActive && self.searchController.searchBar.text!.characters.count > 0
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        splitViewController!.delegate = self
        splitViewController!.preferredDisplayMode = .automatic

        // Start loading feeds asynchronously
        feeder.delegate = self
        feeder.requestFeedsAsynchronous()

        // Set navigation bar to the search bar and set delegates
        self.navigationItem.titleView = self.searchController.searchBar
        self.searchController.delegate = self
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
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
        if self.searchControllerActive {
            return self.filteredFeeds.count
        }
        return self.feeder.feeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath) as? PostTableViewCell else {
            fatalError("Unable to cast tableView's cell as a PostTableViewCell!")
        }

        // Configure the cell...
        if self.searchControllerActive {
            let currentFeedObject = self.filteredFeeds[indexPath.row]
            cell.titleLabel.text = currentFeedObject.title
            cell.descriptionLabel.text = currentFeedObject.strippedHtmlContent
        } else {
            let currentFeedObject = self.feeder.feeds[indexPath.row]
            cell.titleLabel.text = currentFeedObject.title
            cell.descriptionLabel.text = currentFeedObject.strippedHtmlContent
        }

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPostFromMain" {
            if let navController = segue.destination as? UINavigationController {
                guard let postViewController = navController.topViewController as? PostViewController else {
                    fatalError("Unable to unwrap navController topview as PostViewController")
                }
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                    if self.searchControllerActive {
                        let selectedPost = self.filteredFeeds[selectedIndexPath.row]
                        postViewController.title = selectedPost.title
                        postViewController.feedObject = selectedPost
                    } else {
                        let selectedPost = self.feeder.feeds[selectedIndexPath.row]
                        postViewController.title = selectedPost.title
                        postViewController.feedObject = selectedPost
                    }
                } else {
                    // The application initiated the segue from a push notification
                    //TODO: Implement push-based segue
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

    func feedLoadedPercent(_ percent: Double) {
        print("Feed loaded percent: \(percent*100)")
    }

    func feedFinishedParsing(withFeedArray feedArray: [FeedItem]?, error: Error?) {
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
            }
        }
    }

}

// MARK: - UISearch-related delegates

extension MainTableViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        self.filter(forSearchText: searchController.searchBar.text!)
    }

    private func filter(forSearchText searchText: String) {
        self.filteredFeeds = self.feeder.feeds.filter { feed in
            return feed.title.lowercased().contains(searchText.lowercased())
        }

        self.tableView.reloadData()
    }

}
