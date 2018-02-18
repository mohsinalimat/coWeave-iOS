/**
 * This file is part of coWeave-iOS.
 *
 * Copyright (c) 2017-2018 Benoît FRISCH
 *
 * coWeave-iOS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * coWeave-iOS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with coWeave-iOS If not, see <http://www.gnu.org/licenses/>.
 */

import UIKit
import CoreData
import Firebase

class ModifyDocumentTableViewController: UITableViewController, UITextFieldDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var document: Document!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var templateSwitch: UISwitch!
    @IBOutlet var userLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("document-settings", comment: "")
        nameField.text = document.name
        nameField.delegate = self
        templateSwitch.setOn(document.template, animated: true)
        self.hideKeyboardWhenTappedAround()
        userLabel.text = (document.user != nil) ? ("\(NSLocalizedString("assigned-to", comment: "")): " + self.document.user!.name! + " (" + self.document.user!.group!.name! + ")") : NSLocalizedString("assign-to", comment: "")

        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "ModifyPage" as NSObject,
                AnalyticsParameterItemName: "ModifyPage" as NSObject,
                AnalyticsParameterContentType: "document-settings" as NSObject
        ])

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func updateName(_ sender: Any) {
        document.name = nameField.text
        do {
            // Save Record
            try document.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }

        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "UpdateName" as NSObject,
                AnalyticsParameterItemName: "UpdateName" as NSObject,
                AnalyticsParameterContentType: "document-settings" as NSObject
        ])
    }

    @IBAction func setTemplate(_ sender: Any) {
        document.template = templateSwitch.isOn
        do {
            // Save Record
            try document.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }

        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "SetTemplate\(templateSwitch.isOn)" as NSObject,
                AnalyticsParameterItemName: "SetTemplate\(templateSwitch.isOn)" as NSObject,
                AnalyticsParameterContentType: "document-settings" as NSObject
        ])
    }

    func textFieldShouldReturn(_ nameField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loadTemplate") {
            let classVc = segue.destination as! TemplateTableViewController
            classVc.managedObjectContext = self.managedObjectContext
            classVc.document = self.document
        }
        if (segue.identifier == "userAssign") {
            let classVc = segue.destination as! GroupTableViewController
            classVc.managedObjectContext = self.managedObjectContext
            classVc.document = self.document
        }
    }

}
