//
//  Image+CoreDataProperties.swift
//  coWeave
//
//  Created by Benoît Frisch on 15/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var addedDate: NSDate?
    @NSManaged public var id: Int16
    @NSManaged public var image: NSData?
    @NSManaged public var next: Image?
    @NSManaged public var page: Page?
    @NSManaged public var previous: Image?

}
