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

public enum ARControlMode: Int {
    case motion
    case touch
}

public class ARView: SCNView {
    public var controlMode: ARControlMode! {
        didSet {
            switchControlMode(to: controlMode)
        }
    }
    
    public var panoramaTexture: UIImage? {
        didSet {
            let material = SCNMaterial()
            material.diffuse.contents = panoramaTexture
            material.diffuse.mipFilter = .nearest
            material.diffuse.magnificationFilter = .nearest
            material.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, 1, 1)
            material.diffuse.wrapS = .repeat
            material.cullMode = .front
            
            let sphere = SCNSphere(radius: 50)
            sphere.segmentCount = 300
            sphere.firstMaterial = material
            
            panoramaNode.geometry = sphere
        }
    }

    fileprivate let panoramaNode = SCNNode()
    fileprivate let cameraNode = SCNNode()
    fileprivate var prevLocation = CGPoint.zero
    fileprivate var motionManager = CMMotionManager()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadScene()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadScene()
    }
    
    deinit {
        if (motionManager.isGyroActive) {
            motionManager.stopGyroUpdates()
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
}

extension ARView {
    public func switchControlMode(to mode: ARControlMode) {
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
                self.cameraNode.orientation = motionData.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
            })
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if (gesture.state == .began) {
            prevLocation = CGPoint.zero
        } else if (gesture.state == .changed) {
            let location = gesture.translation(in: self)
            let orientation = cameraNode.eulerAngles
            let newOrientation = SCNVector3Make(orientation.x + Float(location.y - prevLocation.y) * 0.005,
                                                orientation.y + Float(location.x - prevLocation.x) * 0.005,
                                                orientation.z)
            
            cameraNode.eulerAngles = newOrientation
            prevLocation = location
        }
    }
}
