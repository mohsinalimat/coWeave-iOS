//
//  ModifyDocumentTableViewController.swift
//  coWeave
//
//  Created by Benoît Frisch on 17/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit
import CoreData

class ModifyDocumentTableViewController: UITableViewController, UITextFieldDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var document: Document!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var templateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Document Settings"
        nameField.text = document.name
        nameField.delegate = self
        templateSwitch.setOn(document.template, animated: true)
        self.hideKeyboardWhenTappedAround()
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
