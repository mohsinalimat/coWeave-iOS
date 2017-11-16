//
//  DocumentsNavigationViewController.swift
//  eduFresh
//
//  Created by Benoît Frisch on 15/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit
import CoreData

class DocumentsNavigationViewController: UINavigationController {
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controller = self.viewControllers[0] as! DocumentsViewController
        controller.managedObjectContext = managedObjectContext
    }
}


