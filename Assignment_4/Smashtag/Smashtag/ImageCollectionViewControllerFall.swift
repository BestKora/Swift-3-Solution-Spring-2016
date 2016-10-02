//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 7/12/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//
/*
import UIKit
import Twitter

public struct TweetMedia: CustomStringConvertible
{
    var tweet: Tweet
    var media: MediaItem
    
    public var description: String { return "\(tweet): \(media)" }
}

class ImageCollectionViewControllerFall: UICollectionViewController,
                                             CHTCollectionViewDelegateWaterfallLayout
 {

    
    var tweets: [[Tweet]] = [] {
        didSet {
            images = tweets.flatMap({$0})
                .map { tweet in
                    tweet.media.map { TweetMedia(tweet: tweet, media: $0) }}.flatMap({$0})
        }
    }
    
    private var images = [TweetMedia]()
    
    
    private var cache = NSCache()
    
    private var layoutFlow = UICollectionViewFlowLayout()
    private var layoutWaterfall = CHTCollectionViewWaterfallLayout ()
  
    
    private struct Constants {
        static let CellReuseIdentifier = "Image Cell"
        static let SegueIdentifier = "Show Tweet"
        static let SizeSetting = CGSize(width: 120.0, height: 120.0)

        static let ColumnCountWaterfall = 3
        static let minimumColumnSpacing:CGFloat = 2
        static let minimumInteritemSpacing:CGFloat = 2
        
        static let minimumLineSpacing:CGFloat = 2
        static let minimumInteritemSpacingFlow:CGFloat = 2
        static let sectionInset = UIEdgeInsets (top: 2, left: 2, bottom: 2, right: 2)

    }
    
    var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Добавляем правую кнопку для переключения layouts
        let imageButton = UIBarButtonItem(barButtonSystemItem: .Reply,
            target: self,
            action: #selector(ImageCollectionViewController.changeLayout(_:)))
        if let existingButton = navigationItem.rightBarButtonItem {
            navigationItem.rightBarButtonItems = [existingButton, imageButton]
        } else {
            navigationItem.rightBarButtonItem = imageButton
        }
        // Установка Layout
        setupLayout()
        
        self.installsStandardGestureForInteractiveMovement = true
        
        collectionView?.addGestureRecognizer(
            UIPinchGestureRecognizer(target: self, action: #selector(ImageCollectionViewController.zoom(_:))))
    }
    
    func changeLayout(sender: UIBarButtonItem) {
        
        if let currentLayout = collectionView?.collectionViewLayout {
            if currentLayout is CHTCollectionViewWaterfallLayout {
                collectionView?.setCollectionViewLayout(layoutFlow, animated: true)
            }else {
                collectionView?.setCollectionViewLayout(layoutWaterfall, animated: true)
            }
        }
    }

    func zoom(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    //MARK: - Настройка Layout CollectionView
    private func setupLayout(){
        
        // Меняем атрибуты для WaterfallLayout
        
        // зазоры между ячейками и строками и
        // количество столбцов - основной параметр настройки
        
        layoutWaterfall.columnCount = Constants.ColumnCountWaterfall
        layoutWaterfall.minimumColumnSpacing = Constants.minimumColumnSpacing
        layoutWaterfall.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        
        // Меняем атрибуты для FlowLayout
        // зазоры между ячейками и строками и
        // зазоры для секции
        
        layoutFlow.minimumInteritemSpacing = Constants.minimumInteritemSpacingFlow
        layoutFlow.minimumLineSpacing = Constants.minimumLineSpacing
        layoutFlow.sectionInset = Constants.sectionInset
        
        // устанавливаем Waterfall layout нашему collection view
        collectionView?.collectionViewLayout = layoutFlow
    }

    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return images.count
    }
    
    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
                Constants.CellReuseIdentifier, forIndexPath: indexPath) as!  ImageCollectionViewCell
            
            cell.cache = cache
            cell.tweetMedia = images[indexPath.row]
            return cell
    }
    
    override func collectionView(collectionView: UICollectionView,
               canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView,
            moveItemAtIndexPath sourceIndexPath: NSIndexPath,
               toIndexPath destinationIndexPath: NSIndexPath) {
        
        let temp = images[sourceIndexPath.item]
        images[sourceIndexPath.item] = images[destinationIndexPath.item]
        images[destinationIndexPath.item] = temp
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
 
            if collectionView.collectionViewLayout is CHTCollectionViewWaterfallLayout{
                let newColumnNumber = Int(CGFloat(Constants.ColumnCountWaterfall) / scale)
                (collectionView.collectionViewLayout
                    as! CHTCollectionViewWaterfallLayout).columnCount =
                    newColumnNumber < 1 ? 1 :newColumnNumber
            }
            let ratio = CGFloat(images[indexPath.row].media.aspectRatio)
            let maxCellWidth = collectionView.bounds.size.width
            var size = CGSize(width: Constants.SizeSetting.width * scale,
                height: Constants.SizeSetting.height * scale)
            if ratio > 1 {
                size.height /= ratio
            } else {
                size.width *= ratio
            }
            if size.width > maxCellWidth {
                size.width = maxCellWidth
                size.height = size.width / ratio
            }
            return size
    }
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.SegueIdentifier {
            if let ttvc = segue.destinationViewController as? TweetTableViewController {
                if let cell = sender as? ImageCollectionViewCell,
                    let tweetMedia = cell.tweetMedia {
                        ttvc.tweets = [[tweetMedia.tweet]]
                }
            }
        }
    }
 
    
}
 */
