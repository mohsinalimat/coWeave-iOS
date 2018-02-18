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
    @NSManaged public var firstPage: Page?
    @NSManaged public var lastPage: Page?
    @NSManaged public var pages: NSOrderedSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for pages

extension Document {

    @objc(insertObject: inPagesAtIndex:)
    @NSManaged public func insertIntoPages(_ value: Page, at idx: Int)

    @objc(removeObjectFromPagesAtIndex:)
    @NSManaged public func removeFromPages(at idx: Int)

    @objc(insertPages: atIndexes:)
    @NSManaged public func insertIntoPages(_ values: [Page], at indexes: NSIndexSet)

    @objc(removePagesAtIndexes:)
    @NSManaged public func removeFromPages(at indexes: NSIndexSet)

    @objc(replaceObjectInPagesAtIndex: withObject:)
    @NSManaged public func replacePages(at idx: Int, with value: Page)

    @objc(replacePagesAtIndexes: withPages:)
    @NSManaged public func replacePages(at indexes: NSIndexSet, with values: [Page])

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: Page)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: Page)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSOrderedSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSOrderedSet)

}
