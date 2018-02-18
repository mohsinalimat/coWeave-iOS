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
    @NSManaged public var docLast: Document?
    @NSManaged public var docFirst: Document?
    @NSManaged public var next: Page?
    @NSManaged public var previous: Page?

}
