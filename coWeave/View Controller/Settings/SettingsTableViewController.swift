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
import Localize_Swift

class SettingsTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var actionSheet: UIAlertController!
    let availableLanguages = Localize.availableLanguages()
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var languageButton: UIButton!
    
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

    @IBAction func selectLanguage(_ sender: Any) {
        actionSheet = UIAlertController(title: nil, message: NSLocalizedString("language-switcher", comment: ""), preferredStyle: UIAlertControllerStyle.actionSheet)
        for language in availableLanguages {
            let displayName = Localize.displayNameForLanguage(language)
            let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print(language)
                UserDefaults.standard.set([language], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                Localize.setCurrentLanguage(language)
            })
            if displayName.count > 0 {
                actionSheet.addAction(languageAction)
            }
            
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = languageButton
            popoverController.sourceRect = languageButton.bounds
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
