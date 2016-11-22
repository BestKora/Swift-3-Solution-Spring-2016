//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 7/12/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import Twitter

public struct TweetMedia: CustomStringConvertible
{
    var tweet: Twitter.Tweet
    var media: MediaItem
    
    public var description: String { return "\(tweet): \(media)" }
}

class ImageCollectionViewController: UICollectionViewController {

    var tweets: [[Tweet]] = [] {
        didSet {
            images = tweets.flatMap({$0})
                .map { tweet in
                    tweet.media.map { TweetMedia(tweet: tweet, media: $0) }}
                .flatMap({$0})
        }
    }
    
    private var images = [TweetMedia]()
    private var cache = NSCache<AnyObject, AnyObject>()
    
    var predefinedWidth:CGFloat {return floor(((collectionView?.bounds.width)! -
        FlowLayout.minimumColumnSpacing * (FlowLayout.ColumnCount - 1.0 ) -
        FlowLayout.sectionInset.right * 2.0) / FlowLayout.ColumnCount)}
    
    var sizePredefined:CGSize {return CGSize(width: predefinedWidth, height: predefinedWidth) }
    
    private struct FlowLayout {
        static let MinImageCellWidth: CGFloat = 60
        
        static let ColumnCount:CGFloat = 3
        
        static let minimumColumnSpacing:CGFloat = 2
        static let minimumInteritemSpacing:CGFloat = 2
        static let sectionInset = UIEdgeInsets (top: 2, left: 2, bottom: 2, right: 2)

    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Image Cell"
        static let SegueIdentifier = "Show Tweet"
     }

    var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self,
                          action: #selector(ImageCollectionViewController.zoom(_:))))
       installsStandardGestureForInteractiveMovement = true

    }
   
    func zoom(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    //MARK: - Настройка Layout CollectionView
    private func setupLayout(){
        let layoutFlow = UICollectionViewFlowLayout()
        
        // Меняем атрибуты для FlowLayout
        layoutFlow.minimumInteritemSpacing = FlowLayout.minimumInteritemSpacing
        layoutFlow.minimumLineSpacing = FlowLayout.minimumColumnSpacing
        layoutFlow.sectionInset = FlowLayout.sectionInset
        
        layoutFlow.itemSize = sizePredefined
        
        collectionView?.collectionViewLayout = layoutFlow
    }

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView:
                                                   UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
                              withReuseIdentifier: Storyboard.CellReuseIdentifier,for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {

            imageCell.cache = cache
            imageCell.tweetMedia = images[indexPath.row]
        }
            return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                  canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                  moveItemAt sourceIndexPath: IndexPath,
                           to destinationIndexPath: IndexPath) {
        
        let temp = images[destinationIndexPath.row]
        images[destinationIndexPath.row] = images[sourceIndexPath.row]
        images[sourceIndexPath.row] = temp
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
        func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let ratio = CGFloat(images[indexPath.row].media.aspectRatio)
        var sizeSetting =  sizePredefined
        if let layoutFlow = collectionViewLayout as? UICollectionViewFlowLayout {
            let maxCellWidth = collectionView.bounds.size.width  -
                                              layoutFlow.minimumInteritemSpacing * 2.0 -
                                              layoutFlow.sectionInset.right * 2.0
            sizeSetting = layoutFlow.itemSize
            
            let size = CGSize(width: sizeSetting.width * scale, height: sizeSetting.height * scale)
            
            let cellWidth = min (max (size.width , FlowLayout.MinImageCellWidth),maxCellWidth)
            
            return (CGSize(width: cellWidth, height: cellWidth / ratio))
        }
        return CGSize(width: sizeSetting.width * scale, height: sizeSetting.height * scale)
        
    }
   
    // MARK: - Navigation
    
    @IBAction private func toRootViewController(_ sender: UIBarButtonItem) {
       _ = navigationController?.popToRootViewController(animated: true)
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.SegueIdentifier {
            if let ttvc = segue.destination as? TweetTableViewController {
                if let cell = sender as? ImageCollectionViewCell,
                    let tweetMedia = cell.tweetMedia {
                    ttvc.tweets = [[tweetMedia.tweet]]
                }
            }
        }
    }

 }
