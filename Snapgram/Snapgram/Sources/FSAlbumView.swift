//
//  FSAlbumView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos

<<<<<<< HEAD
public protocol FSAlbumViewDelegate: class {
    // Returns height ratio of crop image. e.g) 4:3 -> 7.5
    func getCropHeightRatio() -> CGFloat
    
    func albumViewCameraRollUnauthorized()
    func albumViewCameraRollAuthorized()
    func albumbSelectionLimitReached()
    func albumShouldEnableDoneButton(isEnabled: Bool)
=======
@objc public protocol FSAlbumViewDelegate: class {
    
    func albumViewCameraRollUnauthorized()
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
}

final class FSAlbumView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver, UIGestureRecognizerDelegate {
    
<<<<<<< HEAD
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageCropView: FSImageCropView!
    @IBOutlet weak var imageCropViewContainer: UIView!
=======
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageCropView: FSImageCropView!
    @IBOutlet weak var imageCropViewContainer: UIView!
    
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    @IBOutlet weak var collectionViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var imageCropViewConstraintTop: NSLayoutConstraint!
    
    weak var delegate: FSAlbumViewDelegate? = nil
<<<<<<< HEAD
    var allowMultipleSelection = false
    var photoSelectionLimit = 1
    var autoSelectFirstImage = false
    
    internal var images: PHFetchResult<PHAsset>!
    internal var imageManager: PHCachingImageManager?
    internal var previousPreheatRect: CGRect = .zero
    internal let cellSize = CGSize(width: 100, height: 100)
    
    var phAsset: PHAsset!
    
    var selectedImages: [UIImage] = []
    var selectedAssets: [PHAsset] = []
    
    // Variables for calculating the position
    enum Direction {
        case scroll
        case stop
        case up
        case down
    }
    
    fileprivate var dragDirection = Direction.up
    
    private let imageCropViewOriginalConstraintTop: CGFloat = 50
    private let imageCropViewMinimalVisibleHeight: CGFloat  = 100
    private var imaginaryCollectionViewOffsetStartPosY: CGFloat = 0.0
    
    private var cropBottomY: CGFloat  = 0.0
    private var dragStartPos: CGPoint = CGPoint.zero
    private let dragDiff: CGFloat     = 20.0
    
    static func instance() -> FSAlbumView {
=======
    
    var images: PHFetchResult<PHAsset>!
    var imageManager: PHCachingImageManager?
    var previousPreheatRect: CGRect = .zero
    let cellSize = CGSize(width: 100, height: 100)
    var phAsset: PHAsset!
    
    // Variables for calculating the position
//    enum Direction {
//        case scroll
//        case stop
//        case up
//        case down
//    }
//    let imageCropViewOriginalConstraintTop: CGFloat = 50
//    let imageCropViewMinimalVisibleHeight: CGFloat  = 100
//    var dragDirection = Direction.up
//    var imaginaryCollectionViewOffsetStartPosY: CGFloat = 0.0
//
//    var cropBottomY: CGFloat  = 0.0
//    var dragStartPos: CGPoint = CGPoint.zero
//    let dragDiff: CGFloat     = 20.0
    
    static func instance() -> FSAlbumView {
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        return UINib(nibName: "FSAlbumView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! FSAlbumView
    }
    
    func initialize() {
<<<<<<< HEAD
        guard images == nil else { return }
        
        isHidden = false
        
        // Set Image Crop Ratio
        if let heightRatio = delegate?.getCropHeightRatio() {
            imageCropViewContainer.addConstraint(
                NSLayoutConstraint(item: imageCropViewContainer,
                                   attribute: NSLayoutAttribute.height,
                                   relatedBy: NSLayoutRelation.equal,
                                   toItem: imageCropViewContainer,
                                   attribute: NSLayoutAttribute.width,
                                   multiplier: heightRatio,
                                   constant: 0))
            layoutSubviews()
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(FSAlbumView.panned(_:)))
        panGesture.delegate = self
        
        addGestureRecognizer(panGesture)
        
        collectionViewConstraintHeight.constant = self.frame.height - imageCropViewContainer.frame.height - imageCropViewOriginalConstraintTop
        imageCropViewConstraintTop.constant = 50
        dragDirection = Direction.up
        
        imageCropViewContainer.layer.shadowColor   = UIColor.black.cgColor
        imageCropViewContainer.layer.shadowRadius  = 30.0
        imageCropViewContainer.layer.shadowOpacity = 0.9
        imageCropViewContainer.layer.shadowOffset  = CGSize.zero
        
        collectionView.register(UINib(nibName: "FSAlbumViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "FSAlbumViewCell")
        collectionView.backgroundColor = fusumaBackgroundColor
        collectionView.allowsMultipleSelection = allowMultipleSelection
        
=======
        
        if images != nil {
            
            return
        }
        
        mainView.addBottomBorder(lightGrey, width: 1.0)
		
		self.isHidden = false
        
        collectionViewConstraintHeight.constant = (collectionView.frame.width - 3) / 4
        
//        let panGesture      = UIPanGestureRecognizer(target: self, action: #selector(FSAlbumView.panned(_:)))
//        panGesture.delegate = self
//        self.addGestureRecognizer(panGesture)
        

//        imageCropViewConstraintTop.constant = 50
//        dragDirection = Direction.up
        
        
        collectionView.register(UINib(nibName: "FSAlbumViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "FSAlbumViewCell")
		collectionView.backgroundColor = fusumaBackgroundColor
		
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        // Never load photos Unless the user allows to access to photo album
        checkPhotoAuth()
        
        // Sorting condition
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
<<<<<<< HEAD
        images = PHAsset.fetchAssets(with: options)
        
        if images.count > 0 {
            if autoSelectFirstImage == true {
                changeImage(images[0])
                collectionView.reloadData()
                collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
            } else {
                updateImageViewOnly(images[0])
                collectionView.reloadData()
            }
        }
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
=======
        images = PHAsset.fetchAssets(with: .image, options: options)
        
        if images.count > 0 {
            
            changeImage(images[0])
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
        
        PHPhotoLibrary.shared().register(self)
        
    }
    
    deinit {
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }
    
<<<<<<< HEAD
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func panned(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let view    = sender.view
            let loc     = sender.location(in: view)
            let subview = view?.hitTest(loc, with: nil)
            
            if subview == imageCropView && imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop {
                
                return
            }
            
            dragStartPos = sender.location(in: self)
            cropBottomY = imageCropViewContainer.frame.origin.y + self.imageCropViewContainer.frame.height
            
            // Move
            if dragDirection == Direction.stop {
                dragDirection = (imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop) ? Direction.up : Direction.down
            }
            
            // Scroll event of CollectionView is preferred.
            if (dragDirection == Direction.up   && dragStartPos.y < cropBottomY + dragDiff) ||
                (dragDirection == Direction.down && dragStartPos.y > cropBottomY) {
                dragDirection = Direction.stop
                imageCropView.changeScrollable(false)
            } else {
                imageCropView.changeScrollable(true)
            }
        } else if sender.state == UIGestureRecognizerState.changed {
            let currentPos = sender.location(in: self)
            
            if dragDirection == Direction.up && currentPos.y < cropBottomY - dragDiff {
                imageCropViewConstraintTop.constant = max(imageCropViewMinimalVisibleHeight - imageCropViewContainer.frame.height, currentPos.y + dragDiff - imageCropViewContainer.frame.height)
                
                collectionViewConstraintHeight.constant = min(frame.height - imageCropViewMinimalVisibleHeight, frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
            } else if dragDirection == Direction.down && currentPos.y > cropBottomY {
                imageCropViewConstraintTop.constant = min(imageCropViewOriginalConstraintTop, currentPos.y - imageCropViewContainer.frame.height)
                
                collectionViewConstraintHeight.constant = max(frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height, frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
            } else if dragDirection == Direction.stop && collectionView.contentOffset.y < 0 {
                dragDirection = Direction.scroll
                imaginaryCollectionViewOffsetStartPosY = currentPos.y
            } else if dragDirection == Direction.scroll {
                imageCropViewConstraintTop.constant = imageCropViewMinimalVisibleHeight - imageCropViewContainer.frame.height + currentPos.y - imaginaryCollectionViewOffsetStartPosY
                
                collectionViewConstraintHeight.constant = max(frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height, frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
            }
        } else {
            imaginaryCollectionViewOffsetStartPosY = 0.0
            if sender.state == UIGestureRecognizerState.ended &&
                dragDirection == Direction.stop {
                
                imageCropView.changeScrollable(true)
                return
            }
            
            let currentPos = sender.location(in: self)
            
            if currentPos.y < cropBottomY - dragDiff &&
                imageCropViewConstraintTop.constant != imageCropViewOriginalConstraintTop {
                // The largest movement
                imageCropView.changeScrollable(false)
                imageCropViewConstraintTop.constant = imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height
                
                collectionViewConstraintHeight.constant = self.frame.height - imageCropViewMinimalVisibleHeight
                
                UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               options: UIViewAnimationOptions.curveEaseOut,
                               animations: { self.layoutIfNeeded() },
                               completion: nil)
                
                dragDirection = Direction.down
            } else {
                
                // Get back to the original position
                imageCropView.changeScrollable(true)
                
                imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
                collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
                
                UIView.animate(withDuration: 0.3,
                               delay: 0.0,
                               options: UIViewAnimationOptions.curveEaseOut,
                               animations: { self.layoutIfNeeded() },
                               completion: nil)
                
                dragDirection = Direction.up
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
=======
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        return true
//    }
    
//    func panned(_ sender: UITapGestureRecognizer) {
//
//        if sender.state == UIGestureRecognizerState.began {
//
//            let view    = sender.view
//            let loc     = sender.location(in: view)
//            let subview = view?.hitTest(loc, with: nil)
//
//            if subview == imageCropView && imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop {
//
//                return
//            }
//
//            dragStartPos = sender.location(in: self)
//
//            cropBottomY = self.imageCropViewContainer.frame.origin.y + self.imageCropViewContainer.frame.height
//
//            // Move
//            if dragDirection == Direction.stop {
//
//                dragDirection = (imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop) ? Direction.up : Direction.down
//            }
//
//            // Scroll event of CollectionView is preferred.
//            if (dragDirection == Direction.up   && dragStartPos.y < cropBottomY + dragDiff) ||
//                (dragDirection == Direction.down && dragStartPos.y > cropBottomY) {
//
//                    dragDirection = Direction.stop
//
//                    imageCropView.changeScrollable(false)
//
//            } else {
//
//                imageCropView.changeScrollable(true)
//            }
//
//        } else if sender.state == UIGestureRecognizerState.changed {
//
//            let currentPos = sender.location(in: self)
//
//            if dragDirection == Direction.up && currentPos.y < cropBottomY - dragDiff {
//
//                imageCropViewConstraintTop.constant = max(imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height, currentPos.y + dragDiff - imageCropViewContainer.frame.height)
//
//                collectionViewConstraintHeight.constant = min(self.frame.height - imageCropViewMinimalVisibleHeight, self.frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
//
//            } else if dragDirection == Direction.down && currentPos.y > cropBottomY {
//
//                imageCropViewConstraintTop.constant = min(imageCropViewOriginalConstraintTop, currentPos.y - imageCropViewContainer.frame.height)
//
//                collectionViewConstraintHeight.constant = max(self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height, self.frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
//
//            } else if dragDirection == Direction.stop && collectionView.contentOffset.y < 0 {
//
//                dragDirection = Direction.scroll
//                imaginaryCollectionViewOffsetStartPosY = currentPos.y
//
//            } else if dragDirection == Direction.scroll {
//
//                imageCropViewConstraintTop.constant = imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height + currentPos.y - imaginaryCollectionViewOffsetStartPosY
//
//                collectionViewConstraintHeight.constant = max(self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height, self.frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
//
//            }
//
//        } else {
//
//            imaginaryCollectionViewOffsetStartPosY = 0.0
//
//            if sender.state == UIGestureRecognizerState.ended && dragDirection == Direction.stop {
//
//                imageCropView.changeScrollable(true)
//                return
//            }
//
//            let currentPos = sender.location(in: self)
//
//            if currentPos.y < cropBottomY - dragDiff && imageCropViewConstraintTop.constant != imageCropViewOriginalConstraintTop {
//
//                // The largest movement
//                imageCropView.changeScrollable(false)
//
//                imageCropViewConstraintTop.constant = imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height
//
//                collectionViewConstraintHeight.constant = self.frame.height - imageCropViewMinimalVisibleHeight
//
//                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
//
//                    self.layoutIfNeeded()
//
//                    }, completion: nil)
//
//                dragDirection = Direction.down
//
//            } else {
//
//                // Get back to the original position
//                imageCropView.changeScrollable(true)
//
//                imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
//                collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
//
//                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
//
//                    self.layoutIfNeeded()
//
//                    }, completion: nil)
//
//                dragDirection = Direction.up
//
//            }
//        }
//
//
//    }
    
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FSAlbumViewCell", for: indexPath) as! FSAlbumViewCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
<<<<<<< HEAD
        let asset = images[(indexPath as NSIndexPath).item]
        
        imageManager?.requestImage(for: asset,
                                   targetSize: cellSize,
                                   contentMode: .aspectFill,
                                   options: nil) { (result, info) in
                                    if cell.tag == currentTag {
                                        cell.image = result
                                    }
=======
        let asset = self.images[(indexPath as NSIndexPath).item]
        self.imageManager?.requestImage(for: asset,
            targetSize: cellSize,
            contentMode: .aspectFill,
            options: nil) {
                result, info in
                
                if cell.tag == currentTag {
                    cell.image = result
                }
                
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
<<<<<<< HEAD
=======
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
<<<<<<< HEAD
        return images == nil ? 0 : images.count
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
=======
        
        return images == nil ? 0 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        let width = (collectionView.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
<<<<<<< HEAD
        if !allowMultipleSelection {
            selectedImages.removeAll()
            selectedAssets.removeAll()
        }
        
        if photoSelectionLimit > 0 && selectedImages.count + 1 <= photoSelectionLimit {
            changeImage(images[(indexPath as NSIndexPath).row])
            
            imageCropView.changeScrollable(true)
            
            imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
            collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
            
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: { self.layoutIfNeeded() },
                           completion: nil)
            
            dragDirection = Direction.up
            delegate?.albumShouldEnableDoneButton(isEnabled: true)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        } else {
            delegate?.albumbSelectionLimitReached()
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let asset = images[(indexPath as NSIndexPath).item]
        let selectedAsset = selectedAssets.enumerated().filter ({ $1 == asset }).first
        
        if let selected = selectedAsset {
            selectedImages.remove(at: selected.offset)
            selectedAssets.remove(at: selected.offset)
        }
        
        if selectedImages.count > 0 {
            delegate?.albumShouldEnableDoneButton(isEnabled: true)
        } else {
            delegate?.albumShouldEnableDoneButton(isEnabled: false)
        }
        
        return true
=======
        
        changeImage(images[(indexPath as NSIndexPath).row])
        
        imageCropView.changeScrollable(true)
        
//        imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            self.layoutIfNeeded()
            
            }, completion: nil)
        
//        dragDirection = Direction.up
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    }
    
    
    // MARK: - ScrollViewDelegate
<<<<<<< HEAD
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            updateCachedAssets()
        }
    }
    
    //MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            guard let collectionChanges = changeInstance.changeDetails(for: self.images) else {
                return
            }
            
            self.selectedImages.removeAll()
            self.selectedAssets.removeAll()
            
            self.images = collectionChanges.fetchResultAfterChanges
            
            let collectionView = self.collectionView!
            
            if !collectionChanges.hasIncrementalChanges ||
                collectionChanges.hasMoves {
                collectionView.reloadData()
            } else {
                collectionView.performBatchUpdates({
                    if let removedIndexes = collectionChanges.removedIndexes, removedIndexes.count != 0 {
                        collectionView.deleteItems(at: removedIndexes.aapl_indexPathsFromIndexesWithSection(0))
                    }
                    
                    if let insertedIndexes = collectionChanges.insertedIndexes, insertedIndexes.count != 0 {
                        collectionView.insertItems(at: insertedIndexes.aapl_indexPathsFromIndexesWithSection(0))
                    }
                    
                    if let changedIndexes = collectionChanges.changedIndexes, changedIndexes.count != 0 {
                        collectionView.reloadItems(at: changedIndexes.aapl_indexPathsFromIndexesWithSection(0))
                    }
                }, completion: nil)
            }
            
            self.resetCachedAssets()
=======
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collectionView {
            self.updateCachedAssets()
        }
    }
    
    
    //MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.async {
            
            let collectionChanges = changeInstance.changeDetails(for: self.images)
            if collectionChanges != nil {
                
                self.images = collectionChanges!.fetchResultAfterChanges
                
                let collectionView = self.collectionView!
                
                if !collectionChanges!.hasIncrementalChanges || collectionChanges!.hasMoves {
                    
                    collectionView.reloadData()
                    
                } else {
                    
                    collectionView.performBatchUpdates({
                        let removedIndexes = collectionChanges!.removedIndexes
                        if (removedIndexes?.count ?? 0) != 0 {
                            collectionView.deleteItems(at: removedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        let insertedIndexes = collectionChanges!.insertedIndexes
                        if (insertedIndexes?.count ?? 0) != 0 {
                            collectionView.insertItems(at: insertedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        let changedIndexes = collectionChanges!.changedIndexes
                        if (changedIndexes?.count ?? 0) != 0 {
                            collectionView.reloadItems(at: changedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        }, completion: nil)
                }
                
                self.resetCachedAssets()
            }
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        }
    }
}

internal extension UICollectionView {
<<<<<<< HEAD
    func aapl_indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)
        if (allLayoutAttributes?.count ?? 0) == 0 {return []}
        
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(allLayoutAttributes!.count)
        
=======
    
    func aapl_indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)
        if (allLayoutAttributes?.count ?? 0) == 0 {return []}
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(allLayoutAttributes!.count)
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
<<<<<<< HEAD
        
=======
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        return indexPaths
    }
}

internal extension IndexSet {
<<<<<<< HEAD
    func aapl_indexPathsFromIndexesWithSection(_ section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(self.count)
        
        (self as NSIndexSet).enumerate({idx, stop in
            indexPaths.append(IndexPath(item: idx, section: section))
        })
        
=======
    
    func aapl_indexPathsFromIndexesWithSection(_ section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(self.count)
        (self as NSIndexSet).enumerate({idx, stop in
            indexPaths.append(IndexPath(item: idx, section: section))
        })
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        return indexPaths
    }
}

private extension FSAlbumView {
<<<<<<< HEAD
    func changeImage(_ asset: PHAsset) {
        imageCropView.image = nil
        phAsset = asset
        
        DispatchQueue.global(qos: .default).async(execute: {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.imageManager?.requestImage(for: asset,
                                            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                            contentMode: .aspectFill,
                                            options: options) {
                                                result, info in
                                                
                                                DispatchQueue.main.async(execute: {
                                                    
                                                    self.imageCropView.imageSize = CGSize(width: asset.pixelWidth,
                                                                                          height: asset.pixelHeight)
                                                    self.imageCropView.image = result
                                                    
                                                    if let result = result,
                                                        !self.selectedAssets.contains(asset) {
                                                        
                                                        self.selectedAssets.append(asset)
                                                        self.selectedImages.append(result)
                                                    }
                                                })
            }
        })
    }
    
    func updateImageViewOnly(_ asset: PHAsset) {
        imageCropView.image = nil
        
        DispatchQueue.global(qos: .default).async(execute: {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.imageManager?.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { result, info in
                DispatchQueue.main.async(execute: {
                    self.imageCropView.imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                    self.imageCropView.image = result
                })
=======
    
    func changeImage(_ asset: PHAsset) {
        
        self.imageCropView.image = nil
        self.phAsset = asset
        
        DispatchQueue.global(qos: .default).async(execute: {
            
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.imageManager?.requestImage(for: asset,
                targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                contentMode: .aspectFill,
                options: options) {
                    result, info in
                    
                    DispatchQueue.main.async(execute: {
                        
                        self.imageCropView.imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                        self.imageCropView.image = result
                    })
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
            }
        })
    }
    
    // Check the status of authorization for PHPhotoLibrary
    func checkPhotoAuth() {
<<<<<<< HEAD
=======
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .authorized:
                self.imageManager = PHCachingImageManager()
<<<<<<< HEAD
                
                if let images = self.images, images.count > 0 {
                    self.changeImage(images[0])
                }
                
                DispatchQueue.main.async {
                    self.delegate?.albumViewCameraRollAuthorized()
                }
            case .restricted, .denied:
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate?.albumViewCameraRollUnauthorized()
=======
                if self.images != nil && self.images.count > 0 {
                    
                    self.changeImage(self.images[0])
                }
                
            case .restricted, .denied:
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.delegate?.albumViewCameraRollUnauthorized()
                    
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
                })
            default:
                break
            }
        }
    }
<<<<<<< HEAD
    
    // MARK: - Asset Caching
    
    func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    
    func updateCachedAssets() {
        guard let collectionView = self.collectionView else { return }
        
        var preheatRect = collectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        
        if delta > collectionView.bounds.height / 3.0 {
            var addedIndexPaths: [IndexPath]   = []
            var removedIndexPaths: [IndexPath] = []
            
            self.computeDifferenceBetweenRect(
                self.previousPreheatRect,
                andRect: preheatRect,
                removedHandler: { removedRect in
                    let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(removedRect)
                    removedIndexPaths += indexPaths
            },
                addedHandler: { addedRect in
                    let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(addedRect)
                    addedIndexPaths += indexPaths
            }
            )
            
            let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths)
            
            imageManager?.startCachingImages(for: assetsToStartCaching,
                                             targetSize: cellSize,
                                             contentMode: .aspectFill,
                                             options: nil)
            
            imageManager?.stopCachingImages(for: assetsToStopCaching,
                                            targetSize: cellSize,
                                            contentMode: .aspectFill,
                                            options: nil)
            
            previousPreheatRect = preheatRect
        }
    }
    
    func computeDifferenceBetweenRect(_ oldRect: CGRect, andRect newRect: CGRect, removedHandler: (CGRect) -> Void, addedHandler: (CGRect) -> Void) {
=======

    // MARK: - Asset Caching
    
    func resetCachedAssets() {
        
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
 
    func updateCachedAssets() {
        
        var preheatRect = self.collectionView!.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        if delta > self.collectionView!.bounds.height / 3.0 {
            
            var addedIndexPaths: [IndexPath] = []
            var removedIndexPaths: [IndexPath] = []
            
            self.computeDifferenceBetweenRect(self.previousPreheatRect, andRect: preheatRect, removedHandler: {removedRect in
                let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(removedRect)
                removedIndexPaths += indexPaths
                }, addedHandler: {addedRect in
                    let indexPaths = self.collectionView.aapl_indexPathsForElementsInRect(addedRect)
                    addedIndexPaths += indexPaths
            })
            
            let assetsToStartCaching = self.assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = self.assetsAtIndexPaths(removedIndexPaths)
            
            self.imageManager?.startCachingImages(for: assetsToStartCaching,
                targetSize: cellSize,
                contentMode: .aspectFill,
                options: nil)
            self.imageManager?.stopCachingImages(for: assetsToStopCaching,
                targetSize: cellSize,
                contentMode: .aspectFill,
                options: nil)
            
            self.previousPreheatRect = preheatRect
        }
    }
    
    func computeDifferenceBetweenRect(_ oldRect: CGRect, andRect newRect: CGRect, removedHandler: (CGRect)->Void, addedHandler: (CGRect)->Void) {
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        if newRect.intersects(oldRect) {
            let oldMaxY = oldRect.maxY
            let oldMinY = oldRect.minY
            let newMaxY = newRect.maxY
            let newMinY = newRect.minY
<<<<<<< HEAD
            
=======
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
<<<<<<< HEAD
            
=======
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
<<<<<<< HEAD
            
=======
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
<<<<<<< HEAD
            
=======
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
        if indexPaths.count == 0 { return [] }
        
        var assets: [PHAsset] = []
        assets.reserveCapacity(indexPaths.count)
<<<<<<< HEAD
        
        for indexPath in indexPaths {
            let asset = images[(indexPath as NSIndexPath).item]
            assets.append(asset)
        }
        
        return assets
    }
}

=======
        for indexPath in indexPaths {
            let asset = self.images[(indexPath as NSIndexPath).item]
            assets.append(asset)
        }
        return assets
    }
}
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
