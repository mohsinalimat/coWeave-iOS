//
//  Page+CoreDataProperties.swift
//  coWeave
//
//  Created by Benoît Frisch on 18/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//
//

import Foundation
import CoreData


extension Page {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page> {
        return NSFetchRequest<Page>(entityName: "Page")
    }

    @NSManaged public var addedDate: NSDate?
    @NSManaged public var audio: NSData?
    @NSManaged public var id: Int16
    @NSManaged public var modifyDate: NSDate?
    @NSManaged public var number: Int16
    @NSManaged public var title: String?
    @NSManaged public var document: Document?
    @NSManaged public var image: Image?
    @NSManaged public var newRelationship: Document?
    @NSManaged public var newRelationship1: Document?
    @NSManaged public var next: Page?
    @NSManaged public var previous: Page?

}
