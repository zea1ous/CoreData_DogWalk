//
//  Walk+CoreDataProperties.swift
//  CoreData_DogWalk
//
//  Created by Alex Kolovatov on 07/07/2019.
//  Copyright © 2019 Alex Kolovatov. All rights reserved.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var dog: Dog?

}
