//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    // MARK: Model
    var moc: NSManagedObjectContext?

    var tweets = [Array<Twitter.Tweet>](){
        didSet {
            tableView.reloadData()
        }
    }
   
    var searchText: String? = RecentSearches.searches.first ?? "#stanford"{
        didSet {
            lastTwitterRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            searchForTweets()
            title = searchText
            RecentSearches.add(searchText!)
        }
    }
    
    // MARK: Fetching Tweets
    
   private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText  , !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 100)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    private var lastTwitterRequest: Twitter.Request?

    @IBAction private func searchForTweets(_ sender: UIRefreshControl?)
    {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                DispatchQueue.main.async {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, at: 0)
                            
                             weakSelf?.updateDatabase(newTweets)
                            
                             weakSelf?.tableView.reloadData()
                            sender?.endRefreshing()
                            }
                    }
                    sender?.endRefreshing()
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    private func updateDatabase(_ newTweets: [Twitter.Tweet]) {
        moc?.perform {
            // более эффективный способ
            
            TweetM.newTweetsWithTwitterInfo(newTweets,
                andSearchTerm: self.searchText!,
                inManagedObjectContext: self.moc!)

            
       /*     for twitterInfo in newTweets {
               TweetM.tweetWithTwitterInfo(twitterInfo,
                                           andSearchTerm: self.searchText!,
                                           inManagedObjectContext: self.moc!)
            }*/
         self.moc?.saveThrows()
        }
        printDatabaseStatistics() 
    }
 
    private func printDatabaseStatistics() {
        moc?.perform {
            if let results = try? self.moc!.fetch(NSFetchRequest(entityName: "TweetM")) {
                print("\(results.count) TweetMs")
            }
            // a more efficient way to count objects ...
            let searchCount = try! self.moc!.count(for: NSFetchRequest(entityName: "SearchTerm"))
            print("\(searchCount) SearchTerms")
            let mensionCount = try! self.moc!.count(for: NSFetchRequest(entityName: "Mension"))
            print("\(mensionCount) Mensions")
        }
     }

    private func searchForTweets () {
        refreshControl?.beginRefreshing()
        searchForTweets(refreshControl)
    }
    
    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count - section)"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    // MARK: Constants
    
   private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let MentionsIdentifier = "Show Mentions"
         static let ImagesIdentifier = "Show Images"
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIdentifier,
                                                                       for: indexPath)

        let tweet = tweets[indexPath.section][indexPath.row]
        
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
    
        return cell
    }
    
    
    // MARK: Outlets

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    
    // MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
 
          if tweets.count == 0 {
             searchForTweets()
        }
        if RecentSearches.searches.first == nil {
             RecentSearches.add(searchText!)
        }
    }
 
    
    func toRootViewController(_ sender: UIBarButtonItem) {
      _ =  navigationController?.popToRootViewController(animated: true)
     
    }
    
    func showImages(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Storyboard.ImagesIdentifier, sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //-------- Stop Button
        
        let imageButton = UIBarButtonItem(barButtonSystemItem: .camera,
                                          target: self,
                                          action: #selector(TweetTableViewController.showImages(_:)))
        navigationItem.rightBarButtonItems = [imageButton]
        if let navCont = navigationController,
               navCont.viewControllers.count > 1 {
            let stopBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                    target: self,
                                                    action: #selector(TweetTableViewController.toRootViewController(_:)))
            
            if let rightBarButtonItem = navigationItem.rightBarButtonItem {
                navigationItem.rightBarButtonItems = [stopBarButtonItem, rightBarButtonItem]
            } else {
                navigationItem.rightBarButtonItem = stopBarButtonItem
            }
            
        }
        //---------
        if moc == nil {
            UIManagedDocument.useDocument{ (document) in
                    self.moc =  document.managedObjectContext
            }
        }
    }

    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String?,
                                                   sender: Any?) -> Bool {
        if identifier == Storyboard.MentionsIdentifier {
            if let tweetCell = sender as? TweetTableViewCell {
                if tweetCell.tweet!.hashtags.count + tweetCell.tweet!.urls.count +
                   tweetCell.tweet!.userMentions.count +
                   tweetCell.tweet!.media.count == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.MentionsIdentifier,
                let mtvc = segue.destination as? MentionsTableViewController,
                let tweetCell = sender as? TweetTableViewCell {
                mtvc.tweet = tweetCell.tweet
                
            } else if identifier == Storyboard.ImagesIdentifier {
                if let icvc = segue.destination as? ImageCollectionViewController {
                    icvc.tweets = tweets
                    icvc.title = "Images: \(searchText!)"
                }
            }
        }
    }
}
