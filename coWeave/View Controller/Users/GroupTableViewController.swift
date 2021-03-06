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

class GroupTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var document: Document? = nil

    lazy var fetchedResultsController: NSFetchedResultsController<Group> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()

        // Add Sort Descriptors
        let name = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [name]

        //fetchRequest.predicate = NSPredicate(format: "setupFinished == YES")

        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("groups", comment: "")
        self.tableView.rowHeight = 55.0

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }

        Analytics.setUserProperty(String(fetchedResultsController.fetchedObjects!.count), forName: "groups")


        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "GroupList" as NSObject,
                AnalyticsParameterItemName: "GroupList" as NSObject,
                AnalyticsParameterContentType: "users" as NSObject
        ])


        self.tableView.reloadData()
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
        return fetchedResultsController.fetchedObjects!.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (fetchedResultsController.fetchedObjects!.count == 0) {
            return NSLocalizedString("no-groups", comment: "")
        } else {
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Group", for: indexPath)

        let group = self.fetchedResultsController.object(at: indexPath) as Group

        cell.textLabel?.text = group.name
        cell.detailTextLabel?.text = "\(group.users!.count)"

        return cell
    }

    @IBAction func addGroup(_ sender: Any) {
        print("select")
        let alertController = UIAlertController(title: NSLocalizedString("add-group", comment: ""), message: "", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: NSLocalizedString("add", comment: ""), style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // Create Entity
                let entity = NSEntityDescription.entity(forEntityName: "Group", in: self.managedObjectContext)

                // Initialize Record
                let group = Group(entity: entity!, insertInto: self.managedObjectContext)

                group.name = field.text

                do {
                    // Save Record
                    try group.managedObjectContext?.save()
                } catch {
                    let saveError = error as NSError
                    print("\(saveError), \(saveError.userInfo)")
                }

                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("\(fetchError), \(fetchError.userInfo)")
                }
                self.tableView.reloadData()

                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterItemID: "AddGroup" as NSObject,
                        AnalyticsParameterItemName: "AddGroup" as NSObject,
                        AnalyticsParameterContentType: "users" as NSObject
                ])
            } else {
                // user did not fill field
            }
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (_) in
        }

        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("name", comment: "")
        }

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("select")
        let group = self.fetchedResultsController.object(at: indexPath)

        let alertController = UIAlertController(title: "\(NSLocalizedString("modify-group", comment: "")) \(group.name!):", message: "", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: NSLocalizedString("modify", comment: ""), style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                group.name = field.text
                do {
                    // Save Record
                    try group.managedObjectContext?.save()
                } catch {
                    let saveError = error as NSError
                    print("\(saveError), \(saveError.userInfo)")
                }
                tableView.reloadData()

                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterItemID: "ModifyGroup" as NSObject,
                        AnalyticsParameterItemName: "ModifyGroup" as NSObject,
                        AnalyticsParameterContentType: "users" as NSObject
                ])
            } else {
                // user did not fill field
            }
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (_) in
        }

        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("name", comment: "")
            textField.text = group.name

        }

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0000001
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Fetch Record
            let record = self.fetchedResultsController.object(at: indexPath) as Group

            if (record.users!.count > 0) {
                // Create the alert controller
                let alertController = UIAlertController(title: NSLocalizedString("delete", comment: ""), message: NSLocalizedString("delete-error-users", comment: ""), preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("close", comment: ""), style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                    NSLog("Cancel Pressed")
                }
                alertController.addAction(cancelAction)

                // Present the controller
                self.present(alertController, animated: true, completion: nil)

            } else {
                // Create the alert controller
                let alertController = UIAlertController(title: NSLocalizedString("delete", comment: ""), message: "\(NSLocalizedString("delete-warning-1", comment: "")) \(record.name!)? \n\n \(NSLocalizedString("delete-warning-2", comment: ""))", preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: UIAlertActionStyle.destructive) {
                    UIAlertAction in
                    NSLog("Supprimer Pressed")

                    // Delete Record
                    self.managedObjectContext.delete(record)
                    do {
                        try self.fetchedResultsController.performFetch()
                    } catch {
                        let fetchError = error as NSError
                        print("\(fetchError), \(fetchError.userInfo)")
                    }
                    do {
                        // Save Record
                        try self.managedObjectContext?.save()
                    } catch {
                        let saveError = error as NSError
                        print("\(saveError), \(saveError.userInfo)")
                    }
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)

                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                            AnalyticsParameterItemID: "DeleteGroup" as NSObject,
                            AnalyticsParameterItemName: "DeleteGroup" as NSObject,
                            AnalyticsParameterContentType: "users" as NSObject
                    ])
                }
                let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                    NSLog("Cancel Pressed")
                }

                alertController.addAction(deleteAction)
                alertController.addAction(cancelAction)

                // Present the controller
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "open") {
            let classVc = segue.destination as! UserTableViewController
            classVc.managedObjectContext = self.managedObjectContext
            let group = self.fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            classVc.group = group
            classVc.document = document
        }
    }
}

