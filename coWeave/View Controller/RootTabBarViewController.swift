//
//  RootTabBarViewController.swift
//  eduFresh
//
//  Created by Benoît Frisch on 15/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit
import CoreData

class RootTabBarViewController: UITabBarController {
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pass managedObjectcontext to viewcontrollers
        let documentsController = self.viewControllers![0] as! DocumentsNavigationViewController
        documentsController.managedObjectContext = managedObjectContext
        
        // pass managedObjectcontext to viewcontrollers
        let userController = self.viewControllers![1] as! UserNavigationViewController
        userController.managedObjectContext = managedObjectContext
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

