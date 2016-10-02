//
//  Mension+CoreDataProperties.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 8/13/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Mension {

    @NSManaged var count: NSNumber?
    @NSManaged var keyword: String?
    @NSManaged var type: String?
    @NSManaged var tweetMs: NSSet?
    @NSManaged var term: SearchTerm?

}
