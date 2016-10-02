//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 7/12/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    var cache: NSCache<AnyObject, AnyObject>?
    var tweetMedia: TweetMedia? {
        didSet {
            imageURL = tweetMedia?.media.url
            fetchImage()
        }
    }
    
    fileprivate var imageURL: URL?
    fileprivate var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            spinner?.stopAnimating()
        }
    }
    
    fileprivate func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating()
            let imageData = cache?.object(forKey: url as AnyObject) as? Data
            guard imageData == nil else {image = UIImage(data: imageData!); return}
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async  {
                let contentsOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData)
                            self.cache?.setObject(imageData as AnyObject, forKey: url as AnyObject,
                                                        cost: imageData.count / 1024)
                        }
                    }
                }
            }
        }
    }
    
    
}
