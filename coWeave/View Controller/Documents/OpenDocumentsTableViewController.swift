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

class OpenDocumentsTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!

    lazy var fetchedResultsController: NSFetchedResultsController<Document> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()

        // Add Sort Descriptors
        let date = NSSortDescriptor(key: "modifyDate", ascending: false)
        let name = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [date, name]

        fetchRequest.predicate = NSPredicate(format: "user == nil")

        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("unassigned-doc", comment: "")
        self.tableView.rowHeight = 175.0

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

        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "OpenDocument" as NSObject,
                AnalyticsParameterItemName: "OpenDocument" as NSObject,
                AnalyticsParameterContentType: "open-document" as NSObject
        ])

        Analytics.setUserProperty(String(fetchedResultsController.fetchedObjects!.count), forName: "documents")

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
            return "\(NSLocalizedString("no-documents", comment: ""))\n\n\(NSLocalizedString("documents-info", comment: ""))"
        } else {
            return NSLocalizedString("documents-info", comment: "")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Document", for: indexPath) as? DocumentsTableViewCell else {
            fatalError("The dequeued cell is not an instance of PageTableViewCell.")
        }

        let document = self.fetchedResultsController.object(at: indexPath) as Document

        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"

        cell.pageTitle.text = document.name

        DispatchQueue.main.async(execute: { () -> Void in
            cell.documentImage.image = (document.firstPage?.image != nil) ? UIImage(data: (document.firstPage?.image!.image!)! as Data, scale: 0.01) : nil
        })

        cell.author.isHidden = (document.user == nil) ? true : false
        cell.author.text = (document.user != nil) ? (document.user!.name! + " (" + document.user!.group!.name! + ")") : ""
        if (document.modifyDate != nil) {
            cell.pageDate.text = "\(NSLocalizedString("last-opened", comment: "")):\n\(formatter.string(from: document.modifyDate! as Date))\n" + "\(NSLocalizedString("created", comment: "")):\n\(formatter.string(from: document.addedDate! as Date))"
        } else {
            cell.pageDate.text = "\(NSLocalizedString("created", comment: "")):\n\(formatter.string(from: document.addedDate! as Date))"
        }
        return cell
    }


    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("select")
        let document = self.fetchedResultsController.object(at: indexPath)

        let alertController = UIAlertController(title: NSLocalizedString("modify-title", comment: ""), message: "", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: NSLocalizedString("modify", comment: ""), style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                document.name = field.text
                do {
                    // Save Record
                    try document.managedObjectContext?.save()
                } catch {
                    let saveError = error as NSError
                    print("\(saveError), \(saveError.userInfo)")
                }
                tableView.reloadData()
            } else {
                // user did not fill field
            }
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (_) in
        }

        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("name", comment: "")
            textField.text = document.name
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
            let record = self.fetchedResultsController.object(at: indexPath) as Document
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
                        AnalyticsParameterItemID: "DeleteDocument" as NSObject,
                        AnalyticsParameterItemName: "DeleteDocument" as NSObject,
                        AnalyticsParameterContentType: "open-document" as NSObject
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


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "open") {
            let classVc = segue.destination as! DocumentDetailNavigationViewController
            classVc.managedObjectContext = self.managedObjectContext
            let doc = self.fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            classVc.document = doc
        }
        if (segue.identifier == "users") {
            let classVc = segue.destination as! GroupTableViewController
            classVc.managedObjectContext = self.managedObjectContext
        }
    }
}


