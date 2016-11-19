//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 7/06/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import Twitter

public struct TweetMedia: CustomStringConvertible
{
    var tweet: Tweet
    var media: MediaItem
    
    public var description: String { return "\(tweet): \(media)" }
}

class ImageCollectionViewController: UICollectionViewController,
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
    private var cache = NSCache<AnyObject, AnyObject>()
    
    private var layoutFlow = UICollectionViewFlowLayout()
    private var layoutWaterfall = CHTCollectionViewWaterfallLayout ()
    
    var predefinedWidth:CGFloat {return floor(((collectionView?.bounds.width)! -
        Constants.MinimumColumnSpacing * (Constants.ColumnCountFlowLayout - 1.0 ) -
        Constants.SectionInset.right * 2.0) / Constants.ColumnCountFlowLayout)}
    
    var sizePredefined:CGSize {return CGSize(width: predefinedWidth, height: predefinedWidth) }
    
    private struct Constants {
        
        static let MinImageCellWidth: CGFloat = 60
        static let SizeSetting = CGSize(width: 120.0, height: 120.0)
        
        static let ColumnCountWaterfall = 3
        static let ColumnCountWaterfallMax = 8
        static let ColumnCountWaterfallMin = 1
        
        static let ColumnCountFlowLayout: CGFloat = 3
        
        static let MinimumColumnSpacing:CGFloat = 2
        static let MinimumInteritemSpacing:CGFloat = 2
        static let SectionInset = UIEdgeInsets (top: 2, left: 2, bottom: 2, right: 2)
        
        static let FlowLayoutIcon = UIImage(named: "ico_flow_layout")
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
        
        // Добавляем правую кнопку для переключения layouts
        let imageButton = UIBarButtonItem(image: Constants.FlowLayoutIcon,
                    style: UIBarButtonItemStyle.plain, target: self,
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
            UIPinchGestureRecognizer(target: self,
                action: #selector(ImageCollectionViewController.zoom(_:))))
    }
    
    func changeLayout(_ sender: UIBarButtonItem) {
        
        if let layout = collectionView?.collectionViewLayout {
            if layout is CHTCollectionViewWaterfallLayout {
                collectionView?.setCollectionViewLayout(layoutFlow, animated: true)
            }else {
                collectionView?.setCollectionViewLayout(layoutWaterfall, animated: true)
            }
        }
    }
    
    func zoom(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    //MARK: - Настройка Layout CollectionView
    private func setupLayout(){
        
        // WaterfallLayout
        
        layoutWaterfall.columnCount = Constants.ColumnCountWaterfall
        layoutWaterfall.minimumColumnSpacing = Constants.MinimumColumnSpacing
        layoutWaterfall.minimumInteritemSpacing = Constants.MinimumInteritemSpacing
        
        // FlowLayout
        
        layoutFlow.minimumInteritemSpacing = Constants.MinimumInteritemSpacing
        layoutFlow.minimumLineSpacing = Constants.MinimumColumnSpacing
        layoutFlow.sectionInset = Constants.SectionInset
        layoutFlow.itemSize = sizePredefined
        
        // устанавливаем Waterfall layout нашему collection view
        collectionView?.collectionViewLayout = layoutWaterfall
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Storyboard.CellReuseIdentifier, for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            
            imageCell .cache = cache
            imageCell .tweetMedia = images[(indexPath as NSIndexPath).row]
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
        
        let temp = images[(destinationIndexPath as NSIndexPath).row]
        images[(destinationIndexPath as NSIndexPath).row] = images[(sourceIndexPath as NSIndexPath).row]
        images[(sourceIndexPath as NSIndexPath).row] = temp
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        ajusthWaterfallColumnCount(collectionView)
        
        let ratio = CGFloat(images[(indexPath as NSIndexPath).row].media.aspectRatio)
        var sizeSetting =  sizePredefined
        var maxCellWidth = collectionView.bounds.size.width
        
        let layoutFlow = collectionViewLayout as? UICollectionViewFlowLayout
        let layoutWaterFall = collectionViewLayout as? CHTCollectionViewWaterfallLayout
        
        if let layout = layoutFlow {
            maxCellWidth = collectionView.bounds.size.width  -
                layout.minimumInteritemSpacing * 2.0 -
                layout.sectionInset.right * 2.0
            sizeSetting = layout.itemSize
        }
        if let layout = layoutWaterFall {
            maxCellWidth = collectionView.bounds.size.width  -
                layout.minimumInteritemSpacing * 2.0 -
                layout.sectionInset.right * 2.0
        }
        let size = CGSize(width: sizeSetting.width * scale,
                          height: sizeSetting.height * scale)
        let cellWidth = min (max (size.width , Constants.MinImageCellWidth),maxCellWidth)
        return (CGSize(width: cellWidth, height: cellWidth / ratio))
        
    }
    
    private func ajusthWaterfallColumnCount(_ collectionView: UICollectionView) {
        if let waterfallLayout =
            collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            
            let newColumnNumber = Int(CGFloat(Constants.ColumnCountWaterfall) / scale)
            
            // Управляем крличеством колонок с помощью min и max значений
            waterfallLayout.columnCount =
                min (max (newColumnNumber,Constants.ColumnCountWaterfallMin),
                     Constants.ColumnCountWaterfallMax)
            
        }
    }
    
    // MARK: - Navigation
    
    @IBAction private func toRootViewController(_ sender: UIBarButtonItem) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
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

