//
//  OpenDocumentsTableViewController.swift
//  coWeave
//
//  Created by Benoît Frisch on 16/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit
import CoreData

class OpenDocumentsTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Document> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        
        // Add Sort Descriptors
        let date = NSSortDescriptor(key: "addedDate", ascending: false)
        let name = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [date, name]
        
        //fetchRequest.predicate = NSPredicate(format: "setupFinished == YES")
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Documents"
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Document", for: indexPath)
        
        let document = self.fetchedResultsController.object(at: indexPath) as Document
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        cell.textLabel?.text = document.name
        cell.detailTextLabel?.text = formatter.string(from: document.addedDate! as Date)
        
        return cell
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
                let alertController = UIAlertController(title: "Supprimer", message: "Voulez-vous vraiment supprimer \(record.name!)? \n\n Vous ne pourrez plus rétablir ces données!", preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Supprimer", style: UIAlertActionStyle.destructive) {
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
                }
                let cancelAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.cancel) {
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
    }
}


