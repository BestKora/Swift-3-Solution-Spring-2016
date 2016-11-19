//
//  RecentsTableViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 7/19/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class RecentsTableViewController: UITableViewController {

    // MARK: Model
    
    var recentSearches: [String] {
        return RecentSearches.searches
    }
    
    // MARK: View
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        tableView.reloadData()
    }
    
    private struct Storyboard {
        static let RecentCell = "Recent Cell"
        static let TweetsSegue = "Show Tweets from Recent"
        static let PopularSegueIdentifier = "Recent to Popular"
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 }
    
    override func tableView(_ tableView: UITableView,
                                  numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count}

    
    override func tableView(_ tableView: UITableView,
             cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.RecentCell,
                                          for: indexPath) as UITableViewCell
        cell.textLabel?.text = recentSearches[(indexPath as NSIndexPath).row]
        return cell
    }
    
    // Переопределяем поддержку редактирования table view.
    
    override func tableView(_ tableView: UITableView,
      commit editingStyle: UITableViewCellEditingStyle,
          forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // уничтожаем строку из data source
            
            RecentSearches.removeAtIndex((indexPath as NSIndexPath).row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier , identifier == Storyboard.TweetsSegue,
            let cell = sender as? UITableViewCell,
            let ttvc = segue.destination as? TweetTableViewController
        {
            ttvc.searchText = cell.textLabel?.text
        }
        
    }

   }
