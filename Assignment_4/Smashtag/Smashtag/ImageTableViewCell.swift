//
//  imageTableViewCell.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 7/6/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Public API    
    var imageUrl: URL? {
        didSet {updateUI()}
    }
    
    private func updateUI() {
        if let url = imageUrl {
            spinner?.startAnimating()
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                let contentsOfURL = try? Data(contentsOf: url)
                
                DispatchQueue.main.async {
                    if url == self.imageUrl {
                        if let imageData = contentsOfURL {
                            
                            self.tweetImage?.image = UIImage(data: imageData)
                        }
                        self.spinner?.stopAnimating()
                    }
                }
            }
        }
    }

}
