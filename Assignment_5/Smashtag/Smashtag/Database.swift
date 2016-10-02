//
//  Database.swift
//
//  Created by Tatiana Kornilova on 3/18/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit
import CoreData

class MyDocument :UIManagedDocument {
    
    override class var persistentStoreName : String{
        return "Twitter.sqlite"
    }
 
    override func contents(forType typeName: String) throws -> Any {
        print ("Auto-Saving Document")
        return try! super.contents(forType: typeName)
    }
    
    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
        // идея отсюда http://blog.stevex.net/2011/12/uimanageddocument-autosave-troubleshooting/
        print("Ошибка при записи:\(error.localizedDescription)")
        if let userInfo = error._userInfo as? [String:AnyObject],
            let conflicts = userInfo["conflictList"] as? NSArray{
            print("Конфликты при записи:\(conflicts)")
            
        }
    }
}

extension NSManagedObjectContext
{
    public func saveThrows () {
        do {
            try save()
        } catch let error  {
            print("Core Data Error: \(error)")
        }
    }
}

extension UIManagedDocument
{
    class func useDocument (_ completion: @escaping ( _ document: MyDocument) -> Void) {
        let fileManager = FileManager.default
        let doc = "database"
        let urls = FileManager.default.urls(for: .documentDirectory,
                                                                   in: .userDomainMask)
        let url = urls[urls.count-1].appendingPathComponent(doc)
       // print (url)
        let document = MyDocument(fileURL: url)
        document.persistentStoreOptions =
            [ NSMigratePersistentStoresAutomaticallyOption: true,
              NSInferMappingModelAutomaticallyOption: true]
        
        document.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        if let parentContext = document.managedObjectContext.parent{
            parentContext.perform {
                parentContext.mergePolicy =  NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
        
        if !fileManager.fileExists(atPath: url.path) {
            document.save(to: url, for: .forCreating) { (success) -> Void in
                if success {
                  //  print("File создан: Success")
                    completion (document)
                }
            }
        }else  {
            if document.documentState == .closed {
                document.open(){(success:Bool) -> Void in
                    if success {
                     //   print("File существует: Открыт")
                        completion (document)                    }
                }
            } else {
                completion ( document)
            }
        }
    }
}


//NSMergeByPropertyStoreTrumpMergePolicy

