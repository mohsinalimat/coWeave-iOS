//
//  Document+CoreDataProperties.swift
//  coWeave
//
//  Created by Benoît Frisch on 15/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var addedDate: NSDate?
    @NSManaged public var author: String?
    @NSManaged public var id: Int16
    @NSManaged public var modifyDate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var template: Bool
    @NSManaged public var pages: NSSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for pages
extension Document {

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: Page)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: Page)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSSet)

}
