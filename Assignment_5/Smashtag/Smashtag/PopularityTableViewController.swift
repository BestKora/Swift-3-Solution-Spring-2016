//
//  PopularityTableViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 8/11/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PopularityTableViewController: CoreDataTableViewController /*UITableViewController, NSFetchedResultsControllerDelegate */{

    // MARK: Model
    
    var mention: String? { didSet { updateUI() } }
    var moc: NSManagedObjectContext? { didSet { updateUI() } }
    var resultsController: NSFetchedResultsController<Mension>!

    private func updateUI() {
        if let context = moc , mention?.characters.count > 0 {
            let request = NSFetchRequest<Mension>(entityName: "Mension")
            request.predicate = NSPredicate(format: "term.term contains[c] %@ AND count > %@",
                                                                                mention!, "1")
            request.sortDescriptors = [NSSortDescriptor(
                key: "type",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                ), NSSortDescriptor(
                    key: "count",
                    ascending: false
                ),NSSortDescriptor(
                    key: "keyword",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
           resultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "type",
                cacheName: nil
            )
             fetchedResultsController =  resultsController as? NSFetchedResultsController<NSFetchRequestResult>? ?? nil
        } else {
            fetchedResultsController = nil
        }
    }
    
    private struct Storyboard {
        static let CellIdentifier = "PopularMentionsCell"
        static let SegueToMainTweetTableView = "ToMainTweetTableView"
    }
    // MARK: UITableViewDataSource
    
    
     override func tableView(_ tableView: UITableView,
                             cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier,
                                                            for: indexPath)
        var keyword: String?
        var count: String?
        if let mensionM = fetchedResultsController?.object(at: indexPath) as? Mension {
            mensionM.managedObjectContext?.performAndWait {  // asynchronous
                keyword =  mensionM.keyword
                count =  mensionM.count.stringValue
            }
            cell.textLabel?.text = keyword
            cell.detailTextLabel?.text = "tweets.count: " + (count ?? "-")
        }
     return cell
     }
    
    // MARK: View Controller Lifecycle

   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if moc == nil {
            UIManagedDocument.useDocument{ (document) in
                    self.moc =  document.managedObjectContext
            }
        }
    }

    @IBAction fileprivate func toRootViewController(_ sender: UIBarButtonItem) {
        
       _ = navigationController?.popToRootViewController(animated: true)
    }

   
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            
            if identifier == Storyboard.SegueToMainTweetTableView{
                if let ttvc = segue.destination as? TweetTableViewController,
                    let cell = sender as? UITableViewCell,
                    var text = cell.textLabel?.text {
                    if text.hasPrefix("@") {text += " OR from:" + text} 
                    ttvc.searchText = text
                }
                
            }
        }
    }

}
