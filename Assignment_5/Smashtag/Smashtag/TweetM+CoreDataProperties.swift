//
//  TweetM+CoreDataProperties.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 8/10/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TweetM {

    @NSManaged var unique: String?
    @NSManaged var text: String?
    @NSManaged var posted: Date?
    @NSManaged var terms: NSSet?

}
