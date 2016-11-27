//
//  PostViewController.swift
//  SST Announcer
//
//  Created by Pan Ziyue on 22/11/16.
//  Copyright © 2016 Pan Ziyue. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
