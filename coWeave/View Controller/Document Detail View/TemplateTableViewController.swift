//
//  TemplateTableViewController.swift
//  coWeave
//
//  Created by Benoît Frisch on 17/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class TemplateTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var document: Document!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Document> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        
        // Add Sort Descriptors
        let date = NSSortDescriptor(key: "addedDate", ascending: false)
        let name = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [date, name]
        
        fetchRequest.predicate = NSPredicate(format: "template == YES")
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("templates", comment: "")
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
            AnalyticsParameterItemID: "TemplateList" as NSObject,
            AnalyticsParameterItemName: "TemplateList" as NSObject,
            AnalyticsParameterContentType: "template" as NSObject
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Document", for: indexPath) as? DocumentsTableViewCell else {
            fatalError("The dequeued cell is not an instance of PageTableViewCell.")
        }
        
        let document = self.fetchedResultsController.object(at: indexPath) as Document
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        cell.pageTitle.text = document.name
        
        cell.documentImage.image = (document.firstPage?.image != nil) ? UIImage(data: (document.firstPage?.image!.image!)! as Data, scale: 1.0) : nil
        cell.author.isHidden = (document.user == nil) ? true : false
        cell.author.text = (document.user != nil) ? document.user?.name : ""
        if (document.modifyDate != nil) {
            cell.pageDate.text = "\(NSLocalizedString("last-opened", comment: "")):\n\(formatter.string(from: document.modifyDate! as Date))\n" + "\(NSLocalizedString("created", comment: "")):\n\(formatter.string(from: document.addedDate! as Date))"
        } else {
            cell.pageDate.text = "\(NSLocalizedString("created", comment: "")):\n\(formatter.string(from: document.addedDate! as Date))"
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0000001
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (fetchedResultsController.fetchedObjects!.count==0) {
            return NSLocalizedString("no-documents", comment: "")
        } else {
            return ""
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "open") {
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "LoadedFromTemplate" as NSObject,
                AnalyticsParameterItemName: "LoadedFromTemplate" as NSObject,
                AnalyticsParameterContentType: "template" as NSObject
                ])
            
            let classVc = segue.destination as! DocumentDetailNavigationViewController
            classVc.managedObjectContext = self.managedObjectContext
            let doc = self.fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            self.document.removeFromPages(self.document.firstPage!)
            self.document.firstPage = nil
            self.document.lastPage = nil
            
            var previous : Page? = nil
            var i = 0;
            for p in doc.pages! {
                let page = p as! Page
                print("\(page.number)")
                
                // Create Entity
                let entity = NSEntityDescription.entity(forEntityName: "Page", in: self.managedObjectContext)
                
                // Initialize Record
                let pageAdd = Page(entity: entity!, insertInto: self.managedObjectContext)
                
                pageAdd.addedDate = NSDate()
                pageAdd.number = page.number
                pageAdd.document = self.document
                pageAdd.previous = previous
                
                if (page.image != nil) {
                    // Create Entity
                    let imageEntity = NSEntityDescription.entity(forEntityName: "Image", in: self.managedObjectContext)
                
                    // Initialize Record
                    let image = Image(entity: imageEntity!, insertInto: self.managedObjectContext)
                
                    image.addedDate = page.image?.addedDate
                    image.image = page.image?.image
                    image.previous = nil
                    image.page = pageAdd
                
                
                    pageAdd.image = image
                }
                
                doc.lastPage = pageAdd
                
                if (previous != nil) {
                    previous!.next = pageAdd
                }
                
                if (i == 0) {
                    self.document.firstPage = pageAdd
                } else if (i == ((doc.pages?.count)! - 1)) {
                    self.document.lastPage = pageAdd
                }
                
                do {
                    // Save Record
                    try pageAdd.managedObjectContext?.save()
                } catch {
                    let saveError = error as NSError
                    print("\(saveError), \(saveError.userInfo)")
                }
                previous = pageAdd
                i = i+1
            }
            classVc.document = self.document
        }
    }
}

