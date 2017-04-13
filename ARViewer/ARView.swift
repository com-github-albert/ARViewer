//
//  ARView.swift
//  ARViewer
//
//  Created by JT Ma on 11/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion
import AVFoundation
import SpriteKit

public enum ARControlMode: Int {
    case motion
    case touch
}

public class ARView: SCNView {
    
    public var controlMode: ARControlMode! {
        didSet {
            switchControlMode(to: controlMode)
            resetCameraAngles()
        }
    }
    
    public var panoramaTexture: UIImage? {
        didSet {
            guard let texture = panoramaTexture else { return }
            
            let material = SCNMaterial()
            material.diffuse.contents = texture
            material.diffuse.mipFilter = .nearest
            material.diffuse.magnificationFilter = .nearest
            material.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, 1, 1)
            material.diffuse.wrapS = .repeat
            material.cullMode = .front
            
            let sphere = SCNSphere()
            sphere.radius = 50
            sphere.segmentCount = 300
            sphere.firstMaterial = material
            
            panoramaNode.geometry = sphere
        }
    }
    
    public var panoramaVideoPlayer: AVPlayer? {
        didSet {
            guard let videoPlayer = panoramaVideoPlayer else { return }

            let videoSize = CGSize(width: 1920, height: 960)
            
            let videoNode = SKVideoNode(avPlayer: videoPlayer)
            videoNode.position = videoSize.midPoint
            videoNode.xScale = -1
            videoNode.yScale = -1
            videoNode.size = videoSize
            
            let videoScene = SKScene(size: videoSize)
            videoScene.scaleMode = .aspectFit
            videoScene.addChild(videoNode)
            
            let material = SCNMaterial()
            material.diffuse.contents = videoScene
            material.cullMode = .front
            
            let sphere = SCNSphere()
            sphere.radius = 100
            sphere.segmentCount = 300
            sphere.firstMaterial = material
            
            panoramaNode.geometry = sphere
        }
    }
    
    public var panSpeed: (x: Float, y: Float) = (x: 0.005, y: 0.005)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadScene()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadScene()
    }
    
    deinit {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    public func loadScene() {
        let camera = SCNCamera()
        camera.zFar = 100
        camera.xFov = 60
        camera.yFov = 60
        cameraNode.camera = camera
        
        panoramaNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.position = panoramaNode.position
        
        let scene = SCNScene()
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(panoramaNode)
        
        self.scene = scene
        backgroundColor = UIColor.black
    }
    
    fileprivate let panoramaNode = SCNNode()
    fileprivate let cameraNode = SCNNode()
    fileprivate var prevLocation = CGPoint.zero
    fileprivate var motionManager = CMMotionManager()
}

extension ARView {
    fileprivate func resetCameraAngles() {
        cameraNode.eulerAngles = SCNVector3Make(0, 0, 0)
    }
    
    public func switchControlMode(to mode: ARControlMode) {
        gestureRecognizers?.removeAll()
        
        switch mode {
        case .touch:
            let panGestureRec = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_ :)))
            addGestureRecognizer(panGestureRec)
            if motionManager.isDeviceMotionActive {
                motionManager.stopDeviceMotionUpdates()
            }
        case .motion:
            guard motionManager.isAccelerometerAvailable else { return }
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {[unowned self] (motionData, error) in
                guard let motionData = motionData else {
                    print("\(String(describing: error?.localizedDescription))")
                    self.motionManager.stopGyroUpdates()
                    return
                }
                self.cameraNode.orientation = motionData.gaze()
            })
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if (gesture.state == .began) {
            prevLocation = CGPoint.zero
        } else if (gesture.state == .changed) {
            let location = gesture.translation(in: self)
            let orientation = cameraNode.eulerAngles
            let newOrientation = SCNVector3Make(orientation.x + Float(location.y - prevLocation.y) * panSpeed.x,
                                                orientation.y + Float(location.x - prevLocation.x) * panSpeed.y,
                                                orientation.z)
            
            cameraNode.eulerAngles = newOrientation
            prevLocation = location
        }
    }
}
