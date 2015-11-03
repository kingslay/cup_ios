//
//  UICollectionView.swift
//  Cup
//
//  Created by king on 15/11/3.
//  Copyright © 2015年 king. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import ObjectiveC
public protocol KSArrangeCollectionViewDelegate : NSObjectProtocol {
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void
    func deleteItemAtIndexPath(indexPath : NSIndexPath) -> Void
}

private var bundleAssociationKey: UInt8 = 0
private var deleteButtonAssociationKey: UInt8 = 0

extension UICollectionView: UIGestureRecognizerDelegate {
    class Bundle {
        var offset : CGPoint = CGPointZero
        var sourceCell : UICollectionViewCell
        var representationImageView : UIView
        var currentIndexPath : NSIndexPath
        var deleteButton: UIButton?
        init(offset: CGPoint, sourceCell: UICollectionViewCell, representationImageView:UIView, currentIndexPath: NSIndexPath)
        {
            self.offset = offset
            self.sourceCell = sourceCell
            self.representationImageView = representationImageView
            self.currentIndexPath = currentIndexPath
        }
    }
    
    var bundle : Bundle? {
        get {
            return objc_getAssociatedObject(self, &bundleAssociationKey) as? Bundle
        }
        set(newValue) {
            objc_setAssociatedObject(self, &bundleAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
   
    public func addMoveGestureRecognizerForPan(){
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: "handleGesture:")
        panGestureRecogniser.delegate = self
        self.addGestureRecognizer(panGestureRecogniser)
        
    }
    public func addMoveGestureRecognizerForLongPress(){
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
        longPressGestureRecogniser.delegate = self
        self.addGestureRecognizer(longPressGestureRecogniser)
    }
    // MARK: - UIGestureRecognizerDelegate
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        self.bundle?.deleteButton?.removeFromSuperview()
        self.bundle = nil
        let pointPressedInCollectionView = gestureRecognizer.locationInView(self)
        if let indexPath = self.indexPathForItemAtPoint(pointPressedInCollectionView),cell = self.cellForItemAtIndexPath(indexPath) {

            let representationImage = cell.snapshotViewAfterScreenUpdates(true)
            representationImage.frame = cell.frame
            
            let offset = CGPointMake(pointPressedInCollectionView.x - representationImage.frame.origin.x, pointPressedInCollectionView.y - representationImage.frame.origin.y)
            
            self.bundle = Bundle(offset: offset, sourceCell: cell, representationImageView:representationImage, currentIndexPath: indexPath)
            if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
                self.bundle!.deleteButton = UIButton()
                self.bundle!.deleteButton!.setImage(R.image.tata_close, forState: .Normal)
                self.bundle!.deleteButton!.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 18, 18)
                self.bundle!.deleteButton!.rx_tap.subscribeNext{
                    [unowned self] in
                    self.bundle?.deleteButton?.removeFromSuperview()
                    if let delegate = self.delegate as? KSArrangeCollectionViewDelegate {
                        delegate.deleteItemAtIndexPath(indexPath)
                    }
                    self.deleteItemsAtIndexPaths([indexPath])
                }
                let tapGestureRecogniser = UITapGestureRecognizer()
                self.addGestureRecognizer(tapGestureRecogniser)
                tapGestureRecogniser.rx_event.subscribeNext{_ in
                    self.bundle?.deleteButton?.removeFromSuperview()
                    self.removeGestureRecognizer(tapGestureRecogniser)
                }
            }
        }
        
        return (self.bundle != nil)
    }
    
    
    public func handleGesture(gesture: UIGestureRecognizer) -> Void {
        
        
        if let bundle = self.bundle {
            
            let dragPointOnCollectionView = gesture.locationInView(self)
            
            if gesture.state == UIGestureRecognizerState.Began {
                
                bundle.sourceCell.hidden = true
                self.addSubview(bundle.representationImageView)
                if let deleteButton = bundle.deleteButton {
                    self.addSubview(deleteButton)
                }
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    bundle.representationImageView.alpha = 0.8
                });
            }
            if gesture.state == UIGestureRecognizerState.Changed {
                // Update the representation image
                var imageViewFrame = bundle.representationImageView.frame
                var point = CGPointZero
                point.x = dragPointOnCollectionView.x - bundle.offset.x
                point.y = dragPointOnCollectionView.y - bundle.offset.y
                imageViewFrame.origin = point
                bundle.representationImageView.frame = imageViewFrame
                bundle.deleteButton?.frame = CGRectMake(point.x, point.y, 18, 18)
                
                if let indexPath : NSIndexPath = self.indexPathForItemAtPoint(dragPointOnCollectionView) {
                    
                    if indexPath.isEqual(bundle.currentIndexPath) == false {
                        bundle.deleteButton?.removeFromSuperview()
                        // If we have a collection view controller that implements the delegate we call the method first
                        if let delegate = self.delegate as? KSArrangeCollectionViewDelegate {
                            delegate.moveDataItem(bundle.currentIndexPath, toIndexPath: indexPath)
                        }
                        self.moveItemAtIndexPath(bundle.currentIndexPath, toIndexPath: indexPath)
                        self.bundle!.currentIndexPath = indexPath
                    }
                }
            }
            
            if gesture.state == UIGestureRecognizerState.Ended {
                bundle.sourceCell.hidden = false
                bundle.representationImageView.removeFromSuperview()
                
                if let _ = self.delegate as? KSArrangeCollectionViewDelegate { // if we have a proper data source then we can reload and have the data displayed correctly
                    self.reloadData()
                }
            }
        }
    }
}