//
//  FusumaViewController.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos
<<<<<<< HEAD

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

public protocol FusumaDelegate: class {
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode)
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode)
    func fusumaVideoCompleted(withFileURL fileURL: URL)
    func fusumaCameraRollUnauthorized()
    
    // optional
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata)
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode, metaData: [ImageMetadata])
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode)
    func fusumaClosed()
    func fusumaWillClosed()
    func fusumaLimitReached()
}

public extension FusumaDelegate {
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {}
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode, metaData: [ImageMetadata]) {}
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {}
    func fusumaClosed() {}
    func fusumaWillClosed() {}
    func fusumaLimitReached() {}
}

public var fusumaBaseTintColor   = UIColor.hex("#c9c7c8", alpha: 1.0)
public var fusumaTintColor       = UIColor.hex("#424141", alpha: 1.0)
public var fusumaBackgroundColor = UIColor.hex("#FCFCFC", alpha: 1.0)

public var fusumaCheckImage: UIImage?
public var fusumaCloseImage: UIImage?
public var fusumaFlashOnImage: UIImage?
public var fusumaFlashOffImage: UIImage?
public var fusumaFlipImage: UIImage?
public var fusumaShotImage: UIImage?

public var fusumaVideoStartImage: UIImage?
public var fusumaVideoStopImage: UIImage?

public var fusumaCropImage: Bool  = true
public var fusumaSavesImage: Bool = false

public var fusumaCameraRollTitle = "Library"
public var fusumaCameraTitle     = "Photo"
public var fusumaVideoTitle      = "Video"
public var fusumaTitleFont       = UIFont(name: "AvenirNext-DemiBold", size: 15)

public var autoDismiss: Bool = true

@objc public enum FusumaMode: Int {
    case camera
    case library
    case video
    
    static var all: [FusumaMode] {
        return [.camera, .library, .video]
    }
}

public struct ImageMetadata {
    public let mediaType: PHAssetMediaType
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let creationDate: Date?
    public let modificationDate: Date?
    public let location: CLLocation?
    public let duration: TimeInterval
    public let isFavourite: Bool
    public let isHidden: Bool
    public let asset: PHAsset
}

@objc public class FusumaViewController: UIViewController {
    
    public var cropHeightRatio: CGFloat = 1
    public var allowMultipleSelection: Bool = false
    public var photoSelectionLimit: Int = 1
    public var autoSelectFirstImage: Bool = false
    
    internal var mode: FusumaMode = .library
    
    public var availableModes: [FusumaMode] = [.library, .camera]
    public var cameraPosition = AVCaptureDevice.Position.back
    
    @IBOutlet weak var photoLibraryViewerContainer: UIView!
    @IBOutlet weak var cameraShotContainer: UIView!
    @IBOutlet weak var videoShotContainer: UIView!
    
=======
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc public protocol FusumaDelegate: class {
    
    func fusumaImageSelected(_ image: UIImage)
    @objc optional func fusumaDismissedWithImage(_ image: UIImage)
    func fusumaVideoCompleted(withFileURL fileURL: URL)
    func fusumaCameraRollUnauthorized()
    
    @objc optional func fusumaClosed()
}

public var fusumaBaseTintColor   = UIColor.hex("#cccccc", alpha: 1.0)
public var fusumaTintColor       = UIColor.hex("#999999", alpha: 1.0)
public var fusumaBackgroundColor = UIColor.hex("#FFFFFF", alpha: 1.0)

public var fusumaAlbumImage : UIImage? = nil
public var fusumaCameraImage : UIImage? = nil
public var fusumaVideoImage : UIImage? = nil
public var fusumaCheckImage : UIImage? = nil
public var fusumaCloseImage : UIImage? = nil
public var fusumaFlashOnImage : UIImage? = nil
public var fusumaFlashOffImage : UIImage? = nil
public var fusumaFlipImage : UIImage? = nil
public var fusumaShotImage : UIImage? = nil

public var fusumaVideoStartImage : UIImage? = nil
public var fusumaVideoStopImage : UIImage? = nil

public var fusumaCropImage: Bool = true

public var fusumaCameraRollTitle = "Camera Roll"
public var fusumaCameraTitle = "Photo"
public var fusumaVideoTitle = "Video"

public var fusumaTintIcons : Bool = true

public enum FusumaModeOrder {
    case cameraFirst
    case libraryFirst
}

//@objc public class FusumaViewController: UIViewController, FSCameraViewDelegate, FSAlbumViewDelegate {
public final class FusumaViewController: UIViewController {
    
    enum Mode {
        case camera
        case library
        case video
    }

    public var hasVideo = true

    var mode: Mode = .camera
    public var modeOrder: FusumaModeOrder = .cameraFirst
    var willFilter = true

    @IBOutlet weak var photoLibraryViewerContainer: UIView!
    @IBOutlet weak var cameraShotContainer: UIView!
    @IBOutlet weak var videoShotContainer: UIView!

>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
<<<<<<< HEAD
=======
    @IBOutlet weak var noImgBtn: UIButton!
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    lazy var albumView  = FSAlbumView.instance()
    lazy var cameraView = FSCameraView.instance()
<<<<<<< HEAD
    lazy var videoView  = FSVideoCameraView.instance()
    
=======
    lazy var videoView = FSVideoCameraView.instance()

>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    fileprivate var hasGalleryPermission: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    public weak var delegate: FusumaDelegate? = nil
    
    override public func loadView() {
<<<<<<< HEAD
=======
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        if let view = UINib(nibName: "FusumaViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            
            self.view = view
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
        
=======
    
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        self.view.backgroundColor = fusumaBackgroundColor
        
        cameraView.delegate = self
        albumView.delegate  = self
<<<<<<< HEAD
        videoView.delegate  = self
        
        libraryButton.setTitle(fusumaCameraRollTitle, for: .normal)
        cameraButton.setTitle(fusumaCameraTitle, for: .normal)
        videoButton.setTitle(fusumaVideoTitle, for: .normal)
        
        menuView.backgroundColor = fusumaBackgroundColor
        menuView.addBottomBorder(UIColor.black, width: 1.0)
        
        albumView.allowMultipleSelection = allowMultipleSelection
        albumView.photoSelectionLimit = photoSelectionLimit
        albumView.autoSelectFirstImage = autoSelectFirstImage
        
        libraryButton.tintColor = fusumaTintColor
        cameraButton.tintColor  = fusumaTintColor
        videoButton.tintColor   = fusumaTintColor
        closeButton.tintColor   = fusumaTintColor
        doneButton.tintColor    = fusumaTintColor
        
        let bundle     = Bundle(for: self.classForCoder)
        let checkImage = fusumaCheckImage != nil ? fusumaCheckImage : UIImage(named: "ic_check", in: bundle, compatibleWith: nil)
        let closeImage = fusumaCloseImage != nil ? fusumaCloseImage : UIImage(named: "ic_close", in: bundle, compatibleWith: nil)
        
        closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        doneButton.setImage(checkImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: .selected)
        doneButton.setImage(checkImage?.withRenderingMode(.alwaysTemplate), for: .selected)
        closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        doneButton.setImage(checkImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
=======
        videoView.delegate = self

        menuView.backgroundColor = .white
        
        let bundle = Bundle(for: self.classForCoder)
        
        // Get the custom button images if they're set
        let albumImage = fusumaAlbumImage != nil ? fusumaAlbumImage : UIImage(named: "camera_roll", in: bundle, compatibleWith: nil)
        let cameraImage = fusumaCameraImage != nil ? fusumaCameraImage : UIImage(named: "camera", in: bundle, compatibleWith: nil)
        
        let videoImage = fusumaVideoImage != nil ? fusumaVideoImage : UIImage(named: "video", in: bundle, compatibleWith: nil)

        
        let checkImage = fusumaCheckImage != nil ? fusumaCheckImage : UIImage(named: "ic_check", in: bundle, compatibleWith: nil)
        let closeImage = fusumaCloseImage != nil ? fusumaCloseImage : UIImage(named: "ic_close", in: bundle, compatibleWith: nil)
        
        if fusumaTintIcons {
            
            libraryButton.setImage(albumImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            libraryButton.setImage(albumImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            libraryButton.setImage(albumImage?.withRenderingMode(.alwaysTemplate), for: .selected)
            libraryButton.tintColor = fusumaTintColor
            libraryButton.adjustsImageWhenHighlighted = false

            cameraButton.setImage(cameraImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            cameraButton.setImage(cameraImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            cameraButton.setImage(cameraImage?.withRenderingMode(.alwaysTemplate), for: .selected)
            cameraButton.tintColor  = fusumaTintColor
            cameraButton.adjustsImageWhenHighlighted  = false
            
            closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            closeButton.tintColor = mainColor
            
            videoButton.setImage(videoImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            videoButton.setImage(videoImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            videoButton.setImage(videoImage?.withRenderingMode(.alwaysTemplate), for: .selected)
            videoButton.tintColor  = fusumaTintColor
            videoButton.adjustsImageWhenHighlighted = false
            
            doneButton.setImage(checkImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            doneButton.tintColor = mainColor
            
        } else {
            
            libraryButton.setImage(albumImage, for: UIControlState())
            libraryButton.setImage(albumImage, for: .highlighted)
            libraryButton.setImage(albumImage, for: .selected)
            libraryButton.tintColor = nil
            
            cameraButton.setImage(cameraImage, for: UIControlState())
            cameraButton.setImage(cameraImage, for: .highlighted)
            cameraButton.setImage(cameraImage, for: .selected)
            cameraButton.tintColor = nil

            videoButton.setImage(videoImage, for: UIControlState())
            videoButton.setImage(videoImage, for: .highlighted)
            videoButton.setImage(videoImage, for: .selected)
            videoButton.tintColor = nil
            
            closeButton.setImage(closeImage, for: UIControlState())
            doneButton.setImage(checkImage, for: UIControlState())
        }
        
        cameraButton.clipsToBounds  = true
        libraryButton.clipsToBounds = true
        videoButton.clipsToBounds = true

        changeMode(Mode.library)
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        
        photoLibraryViewerContainer.addSubview(albumView)
        cameraShotContainer.addSubview(cameraView)
        videoShotContainer.addSubview(videoView)
        
<<<<<<< HEAD
        titleLabel.textColor = fusumaTintColor
        titleLabel.font      = fusumaTitleFont
        
        if availableModes.count == 0 || availableModes.count >= 4 {
            fatalError("the number of items in the variable of availableModes is incorrect.")
        }
        
        if NSOrderedSet(array: availableModes).count != availableModes.count {
            fatalError("the variable of availableModes should have unique elements.")
        }
        
        changeMode(availableModes[0], isForced: true)
        
        var sortedButtons = [UIButton]()
        
        for (i, mode) in availableModes.enumerated() {
            let button = getTabButton(mode: mode)
            
            if i == 0 {
                view.addConstraint(NSLayoutConstraint(
                    item:       button,
                    attribute:  .leading,
                    relatedBy:  .equal,
                    toItem:     self.view,
                    attribute:  .leading,
                    multiplier: 1.0,
                    constant:   0.0
                ))
            } else {
                view.addConstraint(NSLayoutConstraint(
                    item:       button,
                    attribute:  .leading,
                    relatedBy:  .equal,
                    toItem:     sortedButtons[i - 1],
                    attribute:  .trailing,
                    multiplier: 1.0,
                    constant:   0.0
                ))
            }
            
            if i == sortedButtons.count - 1 {
                view.addConstraint(NSLayoutConstraint(
                    item:       button,
                    attribute:  .trailing,
                    relatedBy:  .equal,
                    toItem:     button,
                    attribute:  .trailing,
                    multiplier: 1.0,
                    constant:   0.0
                ))
                
            }
            
            view.addConstraint(NSLayoutConstraint(
                item: button,
                attribute: .width,
                relatedBy: .equal, toItem: nil,
                attribute: .width,
                multiplier: 1.0,
                constant: UIScreen.main.bounds.width / CGFloat(availableModes.count)
            ))
            
            sortedButtons.append(button)
        }
        
        for m in FusumaMode.all {
            if !availableModes.contains(m) {
                getTabButton(mode: m).removeFromSuperview()
            }
        }
        
        if availableModes.count == 1 {
            libraryButton.removeFromSuperview()
            cameraButton.removeFromSuperview()
            videoButton.removeFromSuperview()
        }
        
        if availableModes.contains(.camera) {
            if fusumaCropImage {
                let heightRatio = getCropHeightRatio()
                cameraView.croppedAspectRatioConstraint = NSLayoutConstraint(
                    item: cameraView.previewViewContainer,
                    attribute: NSLayoutAttribute.height,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: cameraView.previewViewContainer,
                    attribute: NSLayoutAttribute.width,
                    multiplier: heightRatio,
                    constant: 0)
                
                cameraView.fullAspectRatioConstraint.isActive     = false
                cameraView.croppedAspectRatioConstraint?.isActive = true
                
            } else {
                cameraView.fullAspectRatioConstraint.isActive     = true
                cameraView.croppedAspectRatioConstraint?.isActive = false
            }
            cameraView.initialCaptureDevicePosition = cameraPosition
        }
        
        doneButton.isEnabled = false
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if availableModes.contains(.library) {
            albumView.frame = CGRect(origin: CGPoint.zero, size: photoLibraryViewerContainer.frame.size)
            albumView.layoutIfNeeded()
            albumView.initialize()
        }
        
        if availableModes.contains(.camera) {
            cameraView.frame = CGRect(origin: CGPoint.zero, size: cameraShotContainer.frame.size)
            cameraView.layoutIfNeeded()
            cameraView.initialize()
        }
        
        if availableModes.contains(.video) {
=======
		titleLabel.textColor = mainColor
		
//        if modeOrder != .LibraryFirst {
//            libraryFirstConstraints.forEach { $0.priority = 250 }
//            cameraFirstConstraints.forEach { $0.priority = 1000 }
//        }
        
        if !hasVideo {
            
            videoButton.removeFromSuperview()
            
            self.view.addConstraint(NSLayoutConstraint(
                item:       self.view,
                attribute:  .trailing,
                relatedBy:  .equal,
                toItem:     cameraButton,
                attribute:  .trailing,
                multiplier: 1.0,
                constant:   0
                )
            )
            
            self.view.layoutIfNeeded()
        }
        
        if fusumaCropImage {
            cameraView.fullAspectRatioConstraint.isActive = false
            cameraView.croppedAspectRatioConstraint.isActive = true
        } else {
            cameraView.fullAspectRatioConstraint.isActive = true
            cameraView.croppedAspectRatioConstraint.isActive = false
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        albumView.frame  = CGRect(origin: CGPoint.zero, size: photoLibraryViewerContainer.frame.size)
        albumView.layoutIfNeeded()
        cameraView.frame = CGRect(origin: CGPoint.zero, size: cameraShotContainer.frame.size)
        cameraView.layoutIfNeeded()

        
        albumView.initialize()
        cameraView.initialize()
        
        if hasVideo {

>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
            videoView.frame = CGRect(origin: CGPoint.zero, size: videoShotContainer.frame.size)
            videoView.layoutIfNeeded()
            videoView.initialize()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
<<<<<<< HEAD
        stopAll()
    }
    
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override public var prefersStatusBarHidden : Bool {
=======
        self.stopAll()
    }

    override public var prefersStatusBarHidden : Bool {
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        return true
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
<<<<<<< HEAD
        self.delegate?.fusumaWillClosed()
        
        self.doDismiss {
            self.delegate?.fusumaClosed()
        }
    }
    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        changeMode(FusumaMode.library)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        changeMode(FusumaMode.camera)
    }
    
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        changeMode(FusumaMode.video)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        allowMultipleSelection ? fusumaDidFinishInMultipleMode() : fusumaDidFinishInSingleMode()
    }
    
    fileprivate func doDismiss(completion: (() -> Void)?) {
        if autoDismiss {
            dismiss(animated: true) {
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    private func fusumaDidFinishInSingleMode() {
        guard let view = albumView.imageCropView else { return }
        
        if fusumaCropImage {
            let normalizedX = view.contentOffset.x / view.contentSize.width
            let normalizedY = view.contentOffset.y / view.contentSize.height
            
            let normalizedWidth  = view.frame.width / view.contentSize.width
            let normalizedHeight = view.frame.height / view.contentSize.height
            
            let cropRect = CGRect(x: normalizedX, y: normalizedY,
                                  width: normalizedWidth, height: normalizedHeight)
            
            requestImage(with: self.albumView.phAsset, cropRect: cropRect) { (asset, image) in
                self.delegate?.fusumaImageSelected(image, source: self.mode)
                self.doDismiss {
                    self.delegate?.fusumaDismissedWithImage(image, source: self.mode)
                }
                
                let metaData = self.getMetaData(asset: asset)
                
                self.delegate?.fusumaImageSelected(image, source: self.mode, metaData: metaData)
            }
        } else {
            delegate?.fusumaImageSelected(view.image, source: mode)
            
            doDismiss {
                self.delegate?.fusumaDismissedWithImage(view.image, source: self.mode)
            }
        }
    }
    
    private func requestImage(with asset: PHAsset, cropRect: CGRect, completion: @escaping (PHAsset, UIImage) -> Void) {
        DispatchQueue.global(qos: .default).async(execute: {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.normalizedCropRect = cropRect
            options.resizeMode = .exact
            
            let targetWidth  = floor(CGFloat(asset.pixelWidth) * cropRect.width)
            let targetHeight = floor(CGFloat(asset.pixelHeight) * cropRect.height)
            let dimensionW   = max(min(targetHeight, targetWidth), 1024 * UIScreen.main.scale)
            let dimensionH   = dimensionW * self.getCropHeightRatio()
            
            let targetSize   = CGSize(width: dimensionW, height: dimensionH)
            
            /*if asset.mediaType == .video {
                PHImageManager.default().requestAVAsset(forVideo: self.albumView.phAsset, options: nil, resultHandler: { (video, audioMix, info) in
                    DispatchQueue.main.async(execute: {
                        let urlAsset = video as! AVURLAsset
                        self.delegate?.fusumaVideoCompleted(withFileURL: urlAsset.url)
                        self.dismiss(animated: true, completion: {
                            
                        })
                    })
                })
            } else { */
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { result, info in
                guard let result = result else { return }
                
                DispatchQueue.main.async(execute: {
                    completion(asset, result)
                })
            }
          //}
        })
    }
    
    private func fusumaDidFinishInMultipleMode() {
        guard let view = albumView.imageCropView else { return }
        
        let normalizedX = view.contentOffset.x / view.contentSize.width
        let normalizedY = view.contentOffset.y / view.contentSize.height
        let normalizedWidth  = view.frame.width / view.contentSize.width
        let normalizedHeight = view.frame.height / view.contentSize.height
        
        let cropRect = CGRect(x: normalizedX,
                              y: normalizedY,
                              width: normalizedWidth,
                              height: normalizedHeight)
        
        var images = [UIImage]()
        var metaData = [ImageMetadata]()
        
        for asset in albumView.selectedAssets {
            requestImage(with: asset, cropRect: cropRect) { asset, result in
                images.append(result)
                metaData.append(self.getMetaData(asset: asset))
                
                if asset == self.albumView.selectedAssets.last {
                    self.doDismiss {
                        self.delegate?.fusumaMultipleImageSelected(images, source: self.mode, metaData: metaData)
                    }
                }
            }
        }
    }
    
    private func getMetaData(asset: PHAsset) -> ImageMetadata {
        let data = ImageMetadata(mediaType: asset.mediaType ,
                                 pixelWidth: asset.pixelWidth,
                                 pixelHeight: asset.pixelHeight,
                                 creationDate: asset.creationDate,
                                 modificationDate: asset.modificationDate,
                                 location: asset.location,
                                 duration: asset.duration,
                                 isFavourite: asset.isFavorite,
                                 isHidden: asset.isHidden,
                                 asset: asset)
        return data
    }
}

extension FusumaViewController: FSAlbumViewDelegate, FSCameraViewDelegate, FSVideoCameraViewDelegate {
    public func albumbSelectionLimitReached() {
        delegate?.fusumaLimitReached()
    }
    
    public func albumShouldEnableDoneButton(isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
    }
    
    public func getCropHeightRatio() -> CGFloat {
        return cropHeightRatio
    }
    
    // MARK: FSCameraViewDelegate
    func cameraShotFinished(_ image: UIImage) {
        delegate?.fusumaImageSelected(image, source: mode)
        doDismiss {
            self.delegate?.fusumaDismissedWithImage(image, source: self.mode)
        }
    }
    
    public func albumViewCameraRollAuthorized() {
        // in the case that we're just coming back from granting photo gallery permissions
        // ensure the done button is visible if it should be
        updateDoneButtonVisibility()
=======
        self.dismiss(animated: false, completion: {
            print("closeButtonPressed")
            selectedCategory = nil
            selectedTags.removeAll()
            self.delegate?.fusumaClosed?()
        })
    }
    
    @IBAction func noImgBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            print("Called when no image is selected for post")
            selectedImg = nil
        })
    }
    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        
        changeMode(Mode.library)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
    
        changeMode(Mode.camera)
    }
    
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        
        changeMode(Mode.video)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let view = albumView.imageCropView
        loadCamera = false

        if fusumaCropImage {
            let normalizedX = (view?.contentOffset.x)! / (view?.contentSize.width)!
            let normalizedY = (view?.contentOffset.y)! / (view?.contentSize.height)!
            
            let normalizedWidth = (view?.frame.width)! / (view?.contentSize.width)!
            let normalizedHeight = (view?.frame.height)! / (view?.contentSize.height)!
            
            let cropRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
            
            DispatchQueue.global(qos: .default).async(execute: {
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                options.normalizedCropRect = cropRect
                options.resizeMode = .exact
                
                let targetWidth = floor(CGFloat(self.albumView.phAsset.pixelWidth) * cropRect.width)
                let targetHeight = floor(CGFloat(self.albumView.phAsset.pixelHeight) * cropRect.height)
                let dimension = max(min(targetHeight, targetWidth), 1024 * UIScreen.main.scale)
                
                let targetSize = CGSize(width: dimension, height: dimension)
                
                PHImageManager.default().requestImage(for: self.albumView.phAsset, targetSize: targetSize,
                contentMode: .aspectFill, options: options) {
                    result, info in
                    
                    DispatchQueue.main.async(execute: {
                        self.delegate?.fusumaImageSelected(result!)
                        
                        self.dismiss(animated: true, completion: {
                            self.delegate?.fusumaDismissedWithImage?(result!)
                        })
                    })
                }
            })
        } else {
            print("no image crop ")
            delegate?.fusumaImageSelected((view?.image)!)
            
            self.dismiss(animated: true, completion: {
                self.delegate?.fusumaDismissedWithImage?((view?.image)!)
            })
        }
    }
    
}

extension FusumaViewController: FSAlbumViewDelegate, FSCameraViewDelegate, FSVideoCameraViewDelegate {
    
    // MARK: FSCameraViewDelegate
    func cameraShotFinished(_ image: UIImage) {
        
        delegate?.fusumaImageSelected(image)
        self.dismiss(animated: true, completion: {
            
            self.delegate?.fusumaDismissedWithImage?(image)
        })
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    }
    
    // MARK: FSAlbumViewDelegate
    public func albumViewCameraRollUnauthorized() {
<<<<<<< HEAD
        updateDoneButtonVisibility()
=======
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        delegate?.fusumaCameraRollUnauthorized()
    }
    
    func videoFinished(withFileURL fileURL: URL) {
        delegate?.fusumaVideoCompleted(withFileURL: fileURL)
<<<<<<< HEAD
        doDismiss(completion: nil)
=======
        self.dismiss(animated: true, completion: nil)
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    }
    
}

private extension FusumaViewController {
<<<<<<< HEAD
    func stopAll() {
        if availableModes.contains(.video) {
            videoView.stopCamera()
        }
        
        if availableModes.contains(.camera) {
            cameraView.stopCamera()
        }
    }
    
    func changeMode(_ mode: FusumaMode, isForced: Bool = false) {
        
        if !isForced && self.mode == mode { return }
        
        switch self.mode {
        case .camera:
            cameraView.stopCamera()
        case .video:
            videoView.stopCamera()
        default:
            break
=======
    
    func stopAll() {
        
        if hasVideo {

            self.videoView.stopCamera()
        }
        
        self.cameraView.stopCamera()
    }
    
    func changeMode(_ mode: Mode) {

        if self.mode == mode {
            return
        }
        
        //operate this switch before changing mode to stop cameras
        switch self.mode {
        case .library:
            break
        case .camera:
            self.cameraView.stopCamera()
        case .video:
            self.videoView.stopCamera()
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        }
        
        self.mode = mode
        
        dishighlightButtons()
<<<<<<< HEAD
        updateDoneButtonVisibility()
=======
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        
        switch mode {
        case .library:
            titleLabel.text = NSLocalizedString(fusumaCameraRollTitle, comment: fusumaCameraRollTitle)
<<<<<<< HEAD
            highlightButton(libraryButton)
            view.bringSubview(toFront: photoLibraryViewerContainer)
        case .camera:
            titleLabel.text = NSLocalizedString(fusumaCameraTitle, comment: fusumaCameraTitle)
            highlightButton(cameraButton)
            view.bringSubview(toFront: cameraShotContainer)
            cameraView.startCamera()
        case .video:
            titleLabel.text = NSLocalizedString(fusumaVideoTitle, comment: fusumaVideoTitle)
            highlightButton(videoButton)
            view.bringSubview(toFront: videoShotContainer)
            videoView.startCamera()
        }
        
        view.bringSubview(toFront: menuView)
    }
    
    func updateDoneButtonVisibility() {
        guard hasGalleryPermission else {
            doneButton.isHidden = true
            return
        }
        
        switch mode {
        case .library:
            doneButton.isHidden = false
        default:
            doneButton.isHidden = true
        }
    }
    
    func dishighlightButtons() {
        cameraButton.setTitleColor(fusumaBaseTintColor, for: .normal)
        if let libraryButton = libraryButton {
            libraryButton.setTitleColor(fusumaBaseTintColor, for: .normal)
        }
        
        if let videoButton = videoButton {
            videoButton.setTitleColor(fusumaBaseTintColor, for: .normal)
        }
    }
    
    func highlightButton(_ button: UIButton) {
        button.setTitleColor(fusumaTintColor, for: .normal)
    }
    
    func getTabButton(mode: FusumaMode) -> UIButton {
        switch mode {
        case .library:
            return libraryButton
        case .camera:
            return cameraButton
        case .video:
            return videoButton
        }
    }
}

=======
            doneButton.isHidden = false
            
            highlightButton(libraryButton)
            self.view.bringSubview(toFront: photoLibraryViewerContainer)
        case .camera:
            titleLabel.text = NSLocalizedString(fusumaCameraTitle, comment: fusumaCameraTitle)
            doneButton.isHidden = true
            
            highlightButton(cameraButton)
            self.view.bringSubview(toFront: cameraShotContainer)
            cameraView.startCamera()
        case .video:
            titleLabel.text = fusumaVideoTitle
            doneButton.isHidden = true
            
            highlightButton(videoButton)
            self.view.bringSubview(toFront: videoShotContainer)
            videoView.startCamera()
        }
        doneButton.isHidden = !hasGalleryPermission
        self.view.bringSubview(toFront: menuView)
    }
    
    
    func dishighlightButtons() {
        cameraButton.tintColor  = fusumaBaseTintColor
        libraryButton.tintColor = fusumaBaseTintColor
        
        if cameraButton.layer.sublayers?.count > 1 {
            
            for layer in cameraButton.layer.sublayers! {
                
                if let borderColor = layer.borderColor , UIColor(cgColor: borderColor) == fusumaTintColor {
                    
                    layer.removeFromSuperlayer()
                }
                
            }
        }
        
        if libraryButton.layer.sublayers?.count > 1 {
            
            for layer in libraryButton.layer.sublayers! {
                
                if let borderColor = layer.borderColor , UIColor(cgColor: borderColor) == fusumaTintColor {
                    
                    layer.removeFromSuperlayer()
                }
                
            }
        }
        
        if let videoButton = videoButton {
            
            videoButton.tintColor = fusumaBaseTintColor
            
            if videoButton.layer.sublayers?.count > 1 {
                
                for layer in videoButton.layer.sublayers! {
                    
                    if let borderColor = layer.borderColor , UIColor(cgColor: borderColor) == fusumaTintColor {
                        
                        layer.removeFromSuperlayer()
                    }
                    
                }
            }
        }
        
    }
    
    func highlightButton(_ button: UIButton) {
        
        button.tintColor = fusumaTintColor
    }
}
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
