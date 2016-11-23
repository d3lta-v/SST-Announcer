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

    fileprivate var feeds: [FeedItem] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        splitViewController!.delegate = self
        splitViewController!.preferredDisplayMode = .allVisible

        // Simulate 10 dummy posts
        // TODO: Remove it!
        for _ in 0..<10 {
            feeds.append(FeedItem(title: "Post Title", link: "", date: "", author: "", content: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit"))
        }
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
        return feeds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath) as? PostTableViewCell else {
            fatalError("Unable to cast tableView's cell as a PostTableViewCell!")
        }

        // Configure the cell...
        let currentFeedObject = feeds[indexPath.row]
        cell.titleLabel.text = currentFeedObject.title
        cell.descriptionLabel.text = currentFeedObject.content

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "presentPostFromMain" {
            print("presented post")
            var postViewController: PostViewController!
            if let navController = segue.destination as? UINavigationController {
                postViewController = navController.topViewController as! PostViewController
                let selectedPost = feeds[tableView.indexPathForSelectedRow!.row]
                postViewController.title = selectedPost.title
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
