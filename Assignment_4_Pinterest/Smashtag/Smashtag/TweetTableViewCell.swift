//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    struct Palette {
        static let hashtagColor = UIColor.purple
        static let urlColor = UIColor.blue
        static let userColor = UIColor.orange
    }
    
    fileprivate func updateUI()
    {
        // переустанавливаем информацию существующего твита
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // загружаем новую информацию для нашего твита (если он есть)
        if let tweet = self.tweet
        {
            tweetTextLabel?.attributedText  = setTextLabel(tweet)
            tweetScreenNameLabel?.text = "\(tweet.user)"     // tweet.user.description
            setProfileImageView(tweet) // tweetProfileImageView updated asynchronously
            tweetCreatedLabel?.text = setCreatedLabel(tweet)

        }
    }
    
    fileprivate func setTextLabel(_ tweet: Tweet) -> NSMutableAttributedString {
        var tweetText:String = tweet.text
        for _ in tweet.media {tweetText += " 📷"}
        
        let attribText = NSMutableAttributedString(string: tweetText)
        
        attribText.setMensionsColor(tweet.hashtags, color: Palette.hashtagColor)
        attribText.setMensionsColor(tweet.urls, color: Palette.urlColor)
        attribText.setMensionsColor(tweet.userMentions, color: Palette.userColor)
        
        return attribText
    }
    
    fileprivate func setCreatedLabel(_ tweet: Tweet) -> String {
        let formatter = DateFormatter()
        if Date().timeIntervalSince(tweet.created) > 24*60*60 {
            formatter.dateStyle = DateFormatter.Style.short
        } else {
            formatter.timeStyle = DateFormatter.Style.short
        }
        return formatter.string(from: tweet.created)
    }
    
    fileprivate func setProfileImageView(_ tweet: Tweet) {
        if let profileImageURL = tweet.user.profileImageURL {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                
                let contentsOfURL = try? Data(contentsOf: profileImageURL)
                
                DispatchQueue.main.async {
                    
                    if profileImageURL == tweet.user.profileImageURL {
                        if let imageData = contentsOfURL  {
                            self.tweetProfileImageView?.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Расширение

private extension NSMutableAttributedString {
    func setMensionsColor(_ mensions: [Mention], color: UIColor) {
        for mension in mensions {
            addAttribute(NSForegroundColorAttributeName, value: color, range: mension.nsrange)
        }
    }
}
