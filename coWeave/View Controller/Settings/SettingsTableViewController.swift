//
//  SettingsTableViewController.swift
//  coWeave
//
//  Created by Benoît Frisch on 12/10/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class SettingsTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 55.0
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Settings" as NSObject,
            AnalyticsParameterItemName: "Settings" as NSObject,
            AnalyticsParameterContentType: "settings" as NSObject
            ])
        
        versionLabel.text = "Version \(Bundle.main.releaseVersionNumber!) (\(Bundle.main.buildVersionNumber!))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
