//
//  CameraSession.swift
//  CameraKit
//
//  Created by JT Ma on 14/04/2017.
//  Copyright © 2017 Apple, Inc. All rights reserved.
//

import AVFoundation

public enum CameraSessionSetupStatus {
    case success
    case notAuthorized
    case configurationFailed
}

public class CameraCapture {

    public let session = AVCaptureSession()
    public var configStatus: CameraSessionSetupStatus = .success
    public var devicePosition: AVCaptureDevicePosition = .back
    public var flashMode: AVCaptureFlashMode = .off {
        didSet {
            guard flashMode != oldValue, configStatus == .success, let device = videoDeviceInput?.device else {
                return
            }
            configFlash(flashMode, device: device)
        }
    }
    public var torchMode: AVCaptureTorchMode = .off {
        didSet {
            guard torchMode != oldValue, configStatus == .success, let device = videoDeviceInput?.device else {
                return
            }
            configTorch(torchMode, device: device)
        }
    }
    public var focusMode: AVCaptureFocusMode = .autoFocus {
        didSet {
            guard focusMode != oldValue, configStatus == .success, let device = videoDeviceInput?.device else {
                return
            }
            configFocus(focusMode, device: device)
        }
    }
    
    fileprivate var videoDeviceInput: AVCaptureDeviceInput?
    fileprivate let sessionQueue = DispatchQueue(label: "com.jt.camera.sessionQueue")
    fileprivate var sessionPreset: String = AVCaptureSessionPresetHigh
    fileprivate var isRunning = false

    public init() {
        prepare()
    }
}

public extension CameraCapture {
    func start() {
        sessionQueue.async {
            guard self.configStatus == .success else {
                return
            }
            self.session.startRunning()
            self.isRunning = self.session.isRunning
        }
    }
    
    func stop() {
        sessionQueue.async {
            guard self.configStatus == .success else {
                return
            }
            self.session.stopRunning()
            self.isRunning = self.session.isRunning
        }
    }
}

fileprivate extension CameraCapture {
    func prepare() {
        authorization()
        sessionQueue.async { [unowned self] in
            self.configSession()
        }
    }
    
    func authorization() {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                          completionHandler: { [unowned self] granted in
                if !granted {
                    self.configStatus = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            configStatus = .notAuthorized
        }
    }
    
    func configSession() {
        guard configStatus == .success else {
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = sessionPreset
        
        do {
            var defaultVideoDevice: AVCaptureDevice?
            if let dualCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDuoCamera,
                                                                    mediaType: AVMediaTypeVideo,
                                                                    position: devicePosition) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                                                           mediaType: AVMediaTypeVideo,
                                                                           position: devicePosition) {
                defaultVideoDevice = backCameraDevice
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                print("Could not add video device input to the session")
                configStatus = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            configStatus = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
}

fileprivate extension CameraCapture {
    func configFocus(_ mode: AVCaptureFocusMode, device: AVCaptureDevice) {
        
    }
    
    func configFlash(_ mode: AVCaptureFlashMode, device: AVCaptureDevice) {
        
    }
    
    func configTorch(_ mode: AVCaptureTorchMode, device: AVCaptureDevice) {
        
    }
    
    func changeCamera() {
        
    }
}
