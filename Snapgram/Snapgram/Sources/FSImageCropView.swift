//
//  FZImageCropView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/16.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit

final class FSImageCropView: UIScrollView, UIScrollViewDelegate {
<<<<<<< HEAD
    var imageView = UIImageView()
    var imageSize: CGSize?
    var image: UIImage! = nil {
        didSet {
            guard image != nil else {
=======
    
    var imageView = UIImageView()
    
    var imageSize: CGSize?
    
    var image: UIImage! = nil {
        
        didSet {
            
            if image != nil {
                
                if !imageView.isDescendant(of: self) {
                    self.imageView.alpha = 1.0
                    self.addSubview(imageView)
                }
                
            } else {
                
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
                imageView.image = nil
                return
            }
            
<<<<<<< HEAD
            if !imageView.isDescendant(of: self) {
                imageView.alpha = 1.0
                addSubview(imageView)
            }
            
            guard fusumaCropImage else {
                imageView.frame = frame
                imageView.contentMode = .scaleAspectFit
                isUserInteractionEnabled = false
                
                imageView.image = image
                return
            }
            
            let imageSize = self.imageSize ?? image.size
            let ratioW = frame.width / imageSize.width // 400 / 1000 => 0.4
            let ratioH = frame.height / imageSize.height // 300 / 500 => 0.6
            
            if ratioH > ratioW {
                imageView.frame = CGRect(
                    origin: CGPoint.zero,
                    size: CGSize(width: imageSize.width  * ratioH, height: frame.height)
                )
            } else {
                imageView.frame = CGRect(
                    origin: CGPoint.zero,
                    size: CGSize(width: frame.width, height: imageSize.height  * ratioW)
                )
            }
            
            contentOffset = CGPoint(
                x: imageView.center.x - center.x,
                y: imageView.center.y - center.y
            )
            
            contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
            
            imageView.image = image
            
            zoomScale = 1.0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        backgroundColor = fusumaBackgroundColor
        frame.size      = CGSize.zero
        clipsToBounds   = true
        
        imageView.alpha = 0.0
        imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        
        maximumZoomScale = 2.0
        minimumZoomScale = 0.8
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator   = false
        bouncesZoom = true
        bounces = true
        scrollsToTop = false
        delegate = self
=======
            if !fusumaCropImage {
                // Disable scroll view and set image to fit in view
                imageView.frame = self.frame
                imageView.contentMode = .scaleAspectFit
                self.isUserInteractionEnabled = false

                imageView.image = image
                return
            }

            let imageSize = self.imageSize ?? image.size
            
            if imageSize.width < self.frame.width || imageSize.height < self.frame.height {
                
                // The width or height of the image is smaller than the frame size
                
                if imageSize.width > imageSize.height {
                    
                    // Width > Height
                    
                    let ratio = self.frame.width / imageSize.width
                    
                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: self.frame.width, height: imageSize.height * ratio)
                    )
                    
                } else {
                    
                    // Width <= Height
                    
                    let ratio = self.frame.height / imageSize.height
                    
                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: imageSize.width * ratio, height: self.frame.size.height)
                    )
                    
                }
                
                imageView.center = self.center
                
            } else {

                // The width or height of the image is bigger than the frame size

                if imageSize.width > imageSize.height {
                    
                    // Width > Height
                    
                    let ratio = self.frame.height / imageSize.height
                    
                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: imageSize.width * ratio, height: self.frame.height)
                    )
                    
                } else {
                    
                    // Width <= Height

                    let ratio = self.frame.width / imageSize.width
                    
                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: self.frame.width, height: imageSize.height * ratio)
                    )
                    
                }
                
                self.contentOffset = CGPoint(
                    x: imageView.center.x - self.center.x,
                    y: imageView.center.y - self.center.y
                )
            }
            
            self.contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
            
            imageView.image = image
            
            self.zoomScale = 1.0
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
        self.backgroundColor = fusumaBackgroundColor
        self.frame.size      = CGSize.zero
        self.clipsToBounds   = true
        self.imageView.alpha = 0.0
        
        imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        
        self.maximumZoomScale = 2.0
        self.minimumZoomScale = 0.8
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator   = false
        self.bouncesZoom = true
        self.bounces = true
        
        self.delegate = self
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    }
    
    
    func changeScrollable(_ isScrollable: Bool) {
<<<<<<< HEAD
        isScrollEnabled = isScrollable
    }
    
    // MARK: UIScrollViewDelegate Protocol
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
=======
        
        self.isScrollEnabled = isScrollable
    }
    
    // MARK: UIScrollViewDelegate Protocol
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView

    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
<<<<<<< HEAD
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
=======
            
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
<<<<<<< HEAD
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
=======
            
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
<<<<<<< HEAD
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
    }
}

=======
        
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        self.contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
    }
    
}
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
