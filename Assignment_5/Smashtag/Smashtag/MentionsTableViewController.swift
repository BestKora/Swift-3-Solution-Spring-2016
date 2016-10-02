//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 7/6/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import Twitter
import SafariServices

class MentionsTableViewController: UITableViewController {

    // MARK: - Public API

    var tweet: Twitter.Tweet? {
        
        didSet {
            title = tweet?.user.screenName
            if let media = tweet?.media  , media.count > 0 {
                mentionSections.append(MentionSection(type: "Images",
                    mentions: media.map { MentionItem.image($0.url, $0.aspectRatio) }))
            }
            if let urls = tweet?.urls  , urls.count > 0 {
                mentionSections.append(MentionSection(type: "URLs",
                    mentions: urls.map { MentionItem.keyword($0.keyword) }))
            }
            if let hashtags = tweet?.hashtags , hashtags.count > 0 {
                mentionSections.append(MentionSection(type: "Hashtags",
                    mentions: hashtags.map { MentionItem.keyword($0.keyword) }))
            }
            if let users = tweet?.userMentions {
                var userItems = [MentionItem]()
        //------- Extra Credit 1 -------------
                if let screenName = tweet?.user.screenName {
                    userItems += [MentionItem.keyword("@" + screenName)]
                }
        //------------------------------------------------
                if users.count > 0 {
                    userItems += users.map { MentionItem.keyword($0.keyword) }
                }
                if userItems.count > 0 {
                    mentionSections.append(MentionSection(type: "Users", mentions: userItems))
                }
            }
        }
    }
    
    // MARK: - Внутренняя структура данных
    
    fileprivate var mentionSections: [MentionSection] = []
    
    fileprivate struct MentionSection: CustomStringConvertible
    {
        var type: String
        var mentions: [MentionItem]
        var description: String { return "\(type): \(mentions)" }
    }
    
    fileprivate enum MentionItem: CustomStringConvertible
    {
        case keyword(String)
        case image(URL, Double)
        
        var description: String {
            switch self {
            case .keyword(let keyword): return keyword
            case .image(let url, _): return url.path
            }
        }
    }
    
    // MARK: - UITableViewControllerDataSource
    
    fileprivate struct Storyboard {
        static let KeywordCell = "Keyword Cell"
        static let ImageCell = "Image Cell"
        
        static let KeywordSegue = "From Keyword"
        static let ImageSegue = "Show Image"
        static let WebSegue = "Show URL"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentionSections.count
    }
    
    override func tableView(_ tableView: UITableView,
                                  numberOfRowsInSection section: Int) -> Int {
        return mentionSections[section].mentions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt
                                  indexPath: IndexPath) -> UITableViewCell {
        
        let mention = mentionSections[(indexPath as NSIndexPath).section].mentions[(indexPath as NSIndexPath).row]
        
        switch mention {
        case .keyword(let keyword):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.KeywordCell,
                                                                 for: indexPath)
            cell.textLabel?.text = keyword
            return cell
            
        case .image(let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ImageCell,
                                                               for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
              imageCell.imageUrl = url
            }
             return cell
        }
    }
    
    override func tableView(_ tableView: UITableView,
                      heightForRowAt indexPath: IndexPath) -> CGFloat {
                            
        let mention = mentionSections[(indexPath as NSIndexPath).section].mentions[(indexPath as NSIndexPath).row]
        switch mention {
        case .image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView,
                                  titleForHeaderInSection section: Int) -> String? {
        return mentionSections[section].type
    }
    
    
    // MARK: - Navitation
    
    @IBAction fileprivate func toRootViewController(_ sender: UIBarButtonItem) {
        
       _ = navigationController?.popToRootViewController(animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?,
                                                   sender: Any?) -> Bool {
        if identifier == Storyboard.KeywordSegue {
            if let cell = sender as? UITableViewCell,
               let indexPath =  tableView.indexPath(for: cell)
                         , mentionSections[(indexPath as NSIndexPath).section].type == "URLs" {
                /*    if let urlString = cell.textLabel?.text,
                         let url = NSURL(string:urlString) {
                             let safariVC = SFSafariViewController(URL: url)
                             presentViewController(safariVC, animated: true, completion: nil)
                } */
                performSegue(withIdentifier: Storyboard.WebSegue, sender: sender)
                return false
            }
        }
        return true
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            
            if identifier == Storyboard.KeywordSegue {
                if let ttvc = segue.destination as? TweetTableViewController,
                   let cell = sender as? UITableViewCell,
                   var text = cell.textLabel?.text {
                    if text.hasPrefix("@") {text += " OR from:" + text} //  Extra Credit 2
                    ttvc.searchText = text
                }
                
            } else if identifier == Storyboard.ImageSegue {
                if let ivc = segue.destination as? ImageViewController,
                    let cell = sender as? ImageTableViewCell {
                    
                    ivc.imageURL = cell.imageUrl
                    ivc.title = title
                    
                }
            }else if identifier == Storyboard.WebSegue {
                if let wvc = segue.destination as? WebViewController {
                    if let cell = sender as? UITableViewCell {
                        if let url = cell.textLabel?.text {
                            
                            wvc.URL = URL(string: url)
                        }
                    }
                }
            }

        }
    }
    
}
