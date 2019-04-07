//
//  FSCameraView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import AVFoundation
<<<<<<< HEAD
import CoreMotion
import Photos
=======
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc

@objc protocol FSCameraViewDelegate: class {
    func cameraShotFinished(_ image: UIImage)
}

final class FSCameraView: UIView, UIGestureRecognizerDelegate {
<<<<<<< HEAD
=======

    @IBOutlet weak var cameraBtnView: UIView!
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var shotButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
<<<<<<< HEAD
    @IBOutlet weak var fullAspectRatioConstraint: NSLayoutConstraint!
    var croppedAspectRatioConstraint: NSLayoutConstraint?
    var initialCaptureDevicePosition: AVCaptureDevice.Position = .back
    
    weak var delegate: FSCameraViewDelegate? = nil
    
    private var session: AVCaptureSession?
    internal var device: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private var imageOutput: AVCaptureStillImageOutput?
    private var videoLayer: AVCaptureVideoPreviewLayer?
    
    internal var focusView: UIView?
    
    internal var flashOffImage: UIImage?
    private var flashOnImage: UIImage?
    
    private var motionManager: CMMotionManager?
    private var currentDeviceOrientation: UIDeviceOrientation?
    private var zoomFactor: CGFloat = 1.0
    
    static func instance() -> FSCameraView {
=======
    @IBOutlet weak var croppedAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullAspectRatioConstraint: NSLayoutConstraint!
    
    weak var delegate: FSCameraViewDelegate? = nil
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput?
    var focusView: UIView?

    var flashOffImage: UIImage?
    var flashOnImage: UIImage?
    
    static func instance() -> FSCameraView {
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        return UINib(nibName: "FSCameraView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! FSCameraView
    }
    
    func initialize() {
<<<<<<< HEAD
        guard session == nil else { return }
=======
        
        if session != nil {
            
            return
        }
        
        cameraBtnView.addBottomBorderWithColor(color: lightGrey, width: 1.0)
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        
        self.backgroundColor = fusumaBackgroundColor
        
        let bundle = Bundle(for: self.classForCoder)
        
        flashOnImage = fusumaFlashOnImage != nil ? fusumaFlashOnImage : UIImage(named: "ic_flash_on", in: bundle, compatibleWith: nil)
        flashOffImage = fusumaFlashOffImage != nil ? fusumaFlashOffImage : UIImage(named: "ic_flash_off", in: bundle, compatibleWith: nil)
        let flipImage = fusumaFlipImage != nil ? fusumaFlipImage : UIImage(named: "ic_loop", in: bundle, compatibleWith: nil)
<<<<<<< HEAD
        let shotImage = fusumaShotImage != nil ? fusumaShotImage : UIImage(named: "ic_shutter", in: bundle, compatibleWith: nil)
        
        flashButton.tintColor = fusumaBaseTintColor
        flipButton.tintColor  = fusumaBaseTintColor
        shotButton.tintColor  = fusumaBaseTintColor
        
        flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        flipButton.setImage(flipImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        shotButton.setImage(shotImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        isHidden = false
=======
        //let shotImage = fusumaShotImage != nil ? fusumaShotImage : UIImage(named: "ic_radio_button_checked", in: bundle, compatibleWith: nil)
        
        shotButton.layer.cornerRadius = shotButton.frame.size.height / 2
        
        if(fusumaTintIcons) {
            flashButton.tintColor = fusumaBaseTintColor
            flipButton.tintColor  = fusumaBaseTintColor
            shotButton.tintColor  = fusumaBaseTintColor
            
            flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            flipButton.setImage(flipImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            //shotButton.setImage(shotImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        } else {
            flashButton.setImage(flashOffImage, for: UIControlState())
            flipButton.setImage(flipImage, for: UIControlState())
            //shotButton.setImage(shotImage, for: UIControlState())
        }

        
        self.isHidden = false
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        
        // AVCapture
        session = AVCaptureSession()
        
<<<<<<< HEAD
        guard let session = session else { return }
        
        for device in AVCaptureDevice.devices() {
            if (device as AnyObject).position == initialCaptureDevicePosition {
                self.device = (device as! AVCaptureDevice)
                
                if !(device as AnyObject).hasFlash {
=======
        for device in AVCaptureDevice.devices() {
            
            if let device = device as? AVCaptureDevice , device.position == AVCaptureDevicePosition.back {
                
                self.device = device
                
                if !device.hasFlash {
                    
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
                    flashButton.isHidden = true
                }
            }
        }
        
<<<<<<< HEAD
        if let device = device, let _videoInput = try? AVCaptureDeviceInput(device: device) {
            videoInput = _videoInput
            session.addInput(videoInput!)
            
            imageOutput = AVCaptureStillImageOutput()
            
            session.addOutput(imageOutput!)
            
            videoLayer = AVCaptureVideoPreviewLayer(session: session)
            videoLayer?.frame = previewViewContainer.bounds
            videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            previewViewContainer.layer.addSublayer(videoLayer!)
            
            session.sessionPreset = AVCaptureSessionPresetPhoto
            
            session.startRunning()
            
            // Focus View
            focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(FSCameraView.focus(_:)))
            tapRecognizer.delegate = self
            previewViewContainer.addGestureRecognizer(tapRecognizer)
        }
        
        flashConfiguration()
        startCamera()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FSCameraView.willEnterForegroundNotification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchToZoom))
        previewViewContainer.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func willEnterForegroundNotification(_ notification: Notification) {
        startCamera()
    }
    
    deinit {
=======
        do {

            if let session = session {

                videoInput = try AVCaptureDeviceInput(device: device)

                session.addInput(videoInput)
                
                imageOutput = AVCaptureStillImageOutput()
                
                session.addOutput(imageOutput)
                
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                videoLayer?.frame = self.previewViewContainer.bounds
                videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                self.previewViewContainer.layer.addSublayer(videoLayer!)
                
                session.sessionPreset = AVCaptureSessionPresetPhoto

                session.startRunning()
                
            }
            
            // Focus View
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action:#selector(FSCameraView.focus(_:)))
            tapRecognizer.delegate = self
            self.previewViewContainer.addGestureRecognizer(tapRecognizer)
            
        } catch {
            
        }
        flashConfiguration()
        
        self.startCamera()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FSCameraView.willEnterForegroundNotification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func willEnterForegroundNotification(_ notification: Notification) {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {
            
            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            
            session?.stopRunning()
        }
    }
    
    deinit {
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        NotificationCenter.default.removeObserver(self)
    }
    
    func startCamera() {
<<<<<<< HEAD
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            session?.startRunning()
            
            motionManager = CMMotionManager()
            motionManager!.accelerometerUpdateInterval = 0.2
            motionManager!.startAccelerometerUpdates(to: OperationQueue()) { [unowned self] (data, _) in
                if let data = data {
                    if abs(data.acceleration.y) < abs(data.acceleration.x) {
                        self.currentDeviceOrientation = data.acceleration.x > 0 ? .landscapeRight : .landscapeLeft
                    } else {
                        self.currentDeviceOrientation = data.acceleration.y > 0 ? .portraitUpsideDown : .portrait
                    }
                }
            }
        case .denied, .restricted:
            stopCamera()
        default:
            break
=======
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {

            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {

            session?.stopRunning()
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        }
    }
    
    func stopCamera() {
        session?.stopRunning()
<<<<<<< HEAD
        motionManager?.stopAccelerometerUpdates()
        currentDeviceOrientation = nil
    }
    
    @IBAction func shotButtonPressed(_ sender: UIButton) {
        guard let imageOutput = imageOutput else {
=======
    }
    
    @IBAction func shotButtonPressed(_ sender: UIButton) {
        
        guard let imageOutput = imageOutput else {
            
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
            return
        }
        
        DispatchQueue.global(qos: .default).async(execute: { () -> Void in
<<<<<<< HEAD
            guard let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo) else { return }
            
            imageOutput.captureStillImageAsynchronously(from: videoConnection) { (buffer, error) -> Void in
                self.stopCamera()
                
                guard let buffer = buffer,
                    let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
                    let image = UIImage(data: data),
                    let cgImage = image.cgImage,
                    let delegate = self.delegate,
                    let videoLayer = self.videoLayer
                    else {
                        return
                }
                
                let rect   = videoLayer.metadataOutputRectOfInterest(for: videoLayer.bounds)
                let width  = CGFloat(cgImage.width)
                let height = CGFloat(cgImage.height)
                
                let cropRect = CGRect(x: rect.origin.x * width,
                                      y: rect.origin.y * height,
                                      width: rect.size.width * width,
                                      height: rect.size.height * height)
                
                guard let img = cgImage.cropping(to: cropRect) else {
                    return
                }
                
                let croppedUIImage = UIImage(cgImage: img, scale: 1.0, orientation: image.imageOrientation)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    delegate.cameraShotFinished(croppedUIImage)
                    
                    self.session       = nil
                    self.videoLayer    = nil
                    self.device        = nil
                    self.imageOutput   = nil
                    self.motionManager = nil
                })
            }
=======

            let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo)

            let orientation: UIDeviceOrientation = UIDevice.current.orientation
            switch (orientation) {
            case .portrait:
                videoConnection?.videoOrientation = .portrait
            case .portraitUpsideDown:
                videoConnection?.videoOrientation = .portraitUpsideDown
            case .landscapeRight:
                videoConnection?.videoOrientation = .landscapeLeft
            case .landscapeLeft:
                videoConnection?.videoOrientation = .landscapeRight
            default:
                videoConnection?.videoOrientation = .portrait
            }

            imageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) -> Void in
                
                self.session?.stopRunning()
                
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                
                if let image = UIImage(data: data!), let delegate = self.delegate {
                    
                    // Image size
                    var iw: CGFloat
                    var ih: CGFloat

                    switch (orientation) {
                    case .landscapeLeft, .landscapeRight:
                        // Swap width and height if orientation is landscape
                        iw = image.size.height
                        ih = image.size.width
                    default:
                        iw = image.size.width
                        ih = image.size.height
                    }
                    
                    // Frame size
                    let sw = self.previewViewContainer.frame.width
                    
                    // The center coordinate along Y axis
                    let rcy = ih * 0.5

                    let imageRef = image.cgImage?.cropping(to: CGRect(x: rcy-iw*0.5, y: 0 , width: iw, height: iw))
                    
                    
                                        
                    DispatchQueue.main.async(execute: { () -> Void in
                        if fusumaCropImage {
                            let resizedImage = UIImage(cgImage: imageRef!, scale: sw/iw, orientation: image.imageOrientation)
                            delegate.cameraShotFinished(resizedImage)
                        } else {
                            delegate.cameraShotFinished(image)
                        }
                        
                        self.session     = nil
                        self.device      = nil
                        self.imageOutput = nil
                        
                    })
                }
                
            })
            
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        })
    }
    
    @IBAction func flipButtonPressed(_ sender: UIButton) {
<<<<<<< HEAD
        guard cameraIsAvailable else { return }
=======

        if !cameraIsAvailable() {

            return
        }
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        
        session?.stopRunning()
        
        do {
<<<<<<< HEAD
            session?.beginConfiguration()
            
            if let session = session {
                for input in session.inputs {
                    session.removeInput(input as! AVCaptureInput)
                }
                
                let position = (videoInput?.device.position == AVCaptureDevice.Position.front) ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front
                
                for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
                    if (device as AnyObject).position == position {
                        videoInput = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                        session.addInput(videoInput!)
                    }
                }
                
            }
            
            session?.commitConfiguration()
        } catch {
=======

            session?.beginConfiguration()

            if let session = session {
                
                for input in session.inputs {
                    
                    session.removeInput(input as? AVCaptureInput)
                }

                let position = (videoInput?.device.position == AVCaptureDevicePosition.front) ? AVCaptureDevicePosition.back : AVCaptureDevicePosition.front

                for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {

                    if let device = device as? AVCaptureDevice , device.position == position {
                 
                        videoInput = try AVCaptureDeviceInput(device: device)
                        session.addInput(videoInput)
                        
                    }
                }

            }
            
            session?.commitConfiguration()

            
        } catch {
            
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        }
        
        session?.startRunning()
    }
    
    @IBAction func flashButtonPressed(_ sender: UIButton) {
<<<<<<< HEAD
        if !cameraIsAvailable { return }
        
        do {
            guard let device = device, device.hasFlash else { return }
            
            try device.lockForConfiguration()
            
            switch device.flashMode {
            case .off:
                device.flashMode = AVCaptureDevice.FlashMode.on
                flashButton.setImage(flashOnImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            case .on:
                device.flashMode = AVCaptureDevice.FlashMode.off
                flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            default:
                break
            }
            
            device.unlockForConfiguration()
        } catch _ {
            flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            
            return
        }
    }
    
    @objc private func handlePinchToZoom(_ pinch: UIPinchGestureRecognizer) {
        guard let device = device else { return }
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(max(factor, 1.0), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                debugPrint(error)
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * zoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            zoomFactor = minMaxZoom(newScaleFactor)
            update(scale: zoomFactor)
        default: break
        }
    }
}

fileprivate extension FSCameraView {
    func saveImageToCameraRoll(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: nil)
    }
    
    @objc func focus(_ recognizer: UITapGestureRecognizer) {
=======

        if !cameraIsAvailable() {

            return
        }

        do {

            if let device = device {
                
                guard device.hasFlash else { return }
            
                try device.lockForConfiguration()
                
                let mode = device.flashMode
                
                if mode == AVCaptureFlashMode.off {
                    
                    device.flashMode = AVCaptureFlashMode.on
                    flashButton.setImage(flashOnImage, for: UIControlState())
                    
                } else if mode == AVCaptureFlashMode.on {
                    
                    device.flashMode = AVCaptureFlashMode.off
                    flashButton.setImage(flashOffImage, for: UIControlState())
                }
                
                device.unlockForConfiguration()

            }

        } catch _ {

            flashButton.setImage(flashOffImage, for: UIControlState())
            return
        }
 
    }
}

extension FSCameraView {
    
    @objc func focus(_ recognizer: UITapGestureRecognizer) {
        
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        let point = recognizer.location(in: self)
        let viewsize = self.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
<<<<<<< HEAD
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            return
        }
        
        do {
            try device.lockForConfiguration()
        } catch _ {
            return
        }
        
        if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) == true {
            device.focusMode = AVCaptureDevice.FocusMode.autoFocus
            device.focusPointOfInterest = newPoint
        }
        
        if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.continuousAutoExposure) == true {
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.exposurePointOfInterest = newPoint
        }
        
        device.unlockForConfiguration()
        
        guard let focusView = self.focusView else { return }
        
        focusView.alpha = 0.0
        focusView.center = point
        focusView.backgroundColor = UIColor.clear
        focusView.layer.borderColor = fusumaBaseTintColor.cgColor
        focusView.layer.borderWidth = 1.0
        focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        addSubview(focusView)
        
        UIView.animate(withDuration: 0.8,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations:{
                        focusView.alpha = 1.0
                        focusView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {(finished) in
            focusView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            focusView.removeFromSuperview()
=======
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            
            try device?.lockForConfiguration()
            
        } catch _ {
            
            return
        }
        
        if device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus) == true {

            device?.focusMode = AVCaptureFocusMode.autoFocus
            device?.focusPointOfInterest = newPoint
        }

        if device?.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure) == true {
            
            device?.exposureMode = AVCaptureExposureMode.continuousAutoExposure
            device?.exposurePointOfInterest = newPoint
        }
        
        device?.unlockForConfiguration()
        
        self.focusView?.alpha = 0.0
        self.focusView?.center = point
        self.focusView?.backgroundColor = UIColor.clear
        self.focusView?.layer.borderColor = fusumaBaseTintColor.cgColor
        self.focusView?.layer.borderWidth = 1.0
        self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.addSubview(self.focusView!)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
            initialSpringVelocity: 3.0, options: UIViewAnimationOptions.curveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                self.focusView!.alpha = 1.0
                self.focusView!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: {(finished) in
                self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.focusView!.removeFromSuperview()
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
        })
    }
    
    func flashConfiguration() {
<<<<<<< HEAD
        
        do {
            if let device = device {
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                device.flashMode = AVCaptureDevice.FlashMode.off
                flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
                
                device.unlockForConfiguration()
            }
        } catch _ {
            return
        }
    }
    
    var cameraIsAvailable: Bool {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == AVAuthorizationStatus.authorized {
            return true
        }
        
        return false
    }
}

=======
    
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                device.flashMode = AVCaptureFlashMode.off
                flashButton.setImage(flashOffImage, for: UIControlState())
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            return
        }
    }

    func cameraIsAvailable() -> Bool {

        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)

        if status == AVAuthorizationStatus.authorized {

            return true
        }

        return false
    }
}
>>>>>>> c28dcf5813b8b42094a7e7d5cc8eec304ec093cc
