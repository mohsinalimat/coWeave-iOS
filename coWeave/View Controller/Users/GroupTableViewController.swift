//
//  GroupTableViewController.swift
//  coWeave
//
//  Created by Benoît Frisch on 18/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit
import CoreData

class GroupTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var document : Document? = nil
    
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
        self.navigationItem.title = "Groupes"
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (fetchedResultsController.fetchedObjects!.count==0) {
            return "Pas de groupes disponibles!"
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
        print ("select")
        let alertController = UIAlertController(title: "Ajouter un groupe", message: "", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Ajouter", style: .default) { (_) in
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
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Nom"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print ("select")
        let group = self.fetchedResultsController.object(at: indexPath)
        
        let alertController = UIAlertController(title: "Modify name of group \(group.name!):", message: "", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Modify", style: .default) { (_) in
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
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
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
            let classVc = segue.destination as! UserTableViewController
            classVc.managedObjectContext = self.managedObjectContext
            let group = self.fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            classVc.group = group
            classVc.document = document
        }
    }
}

