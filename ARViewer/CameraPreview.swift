//
//  CameraPreview.swift
//  CameraKit
//
//  Created by JT Ma on 14/04/2017.
//  Copyright © 2017 Apple, Inc. All rights reserved.
//

import UIKit
import AVFoundation

public class CameraPreview: UIView {
    
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    public var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override public class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
