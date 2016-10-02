//
//  SearchTerm.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 8/10/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData

class SearchTerm: NSManagedObject {
    
    class func termWithTerm(_ term: String,
                            inManagedObjectContext context: NSManagedObjectContext) -> SearchTerm?
    {
        let request = NSFetchRequest<SearchTerm>(entityName: "SearchTerm")
        request.predicate = NSPredicate(format: "term = %@", term)
        if let searchTerm = (try? context.fetch(request))?.first {
            return searchTerm
        } else if let searchTerm = NSEntityDescription.insertNewObject(forEntityName: "SearchTerm",
                                                    into: context) as? SearchTerm {
            searchTerm.term = term
            return  searchTerm
        }
        return nil
    }
}
