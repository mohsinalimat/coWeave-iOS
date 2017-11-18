//
//  ModifyDocumentTableViewController.swift
//  coWeave
//
//  Created by Benoît Frisch on 17/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

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
        self.navigationItem.title = "Document Settings"
        nameField.text = document.name
        nameField.delegate = self
        templateSwitch.setOn(document.template, animated: true)
        self.hideKeyboardWhenTappedAround()
        userLabel.text = (document.user != nil) ? ("Assigned to: " + self.document.user!.name! + " ("+self.document.user!.group!.name!+")") : "Assign to User"
        
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
