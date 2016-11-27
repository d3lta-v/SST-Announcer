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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        splitViewController!.delegate = self
        splitViewController!.preferredDisplayMode = .automatic

        // Start loading feeds asynchronously
        feeder.delegate = self
        feeder.requestFeedsAsynchronous()
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
        return self.feeder.feeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath) as? PostTableViewCell else {
            fatalError("Unable to cast tableView's cell as a PostTableViewCell!")
        }

        // Configure the cell...
        let currentFeedObject = self.feeder.feeds[indexPath.row]
        cell.titleLabel.text = currentFeedObject.title
        cell.descriptionLabel.text = currentFeedObject.strippedHtmlContent

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentPostFromMain" {
            var postViewController: PostViewController!
            if let navController = segue.destination as? UINavigationController {
                postViewController = navController.topViewController as! PostViewController
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                    let selectedPost = self.feeder.feeds[selectedIndexPath.row]
                    postViewController.title = selectedPost.title
                    postViewController.feedObject = selectedPost
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
