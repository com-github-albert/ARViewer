//
//  ARViewController.swift
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

public class ARViewController: UIViewController {
    
    @IBOutlet weak var sceneView: SCNView!
    
    public var controlMode: ARControlMode! {
        didSet {
            switchControlMode(to: controlMode)
        }
    }
    
    fileprivate let cameraNode = SCNNode()
    fileprivate var prevLocation = CGPoint.zero
    fileprivate var motionManager = CMMotionManager()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        loadScene()
        controlMode = .motion
    }
    
    deinit {
        if (motionManager.isGyroActive) {
            motionManager.stopGyroUpdates()
        }
    }
    
    private func loadScene() {
        let camera = SCNCamera()
        camera.zFar = 100
        camera.xFov = 60
        camera.yFov = 60
        cameraNode.camera = camera
        
        let material = SCNMaterial()
        let texture = UIImage(named: "steppe")
        material.diffuse.contents = texture
        material.diffuse.mipFilter = .nearest
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, 1, 1)
        material.diffuse.wrapS = .repeat
        material.cullMode = .front
        
        let sphere = SCNSphere(radius: 50)
        sphere.segmentCount = 300
        sphere.firstMaterial = material
        
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        
        sphereNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.position = sphereNode.position
        
        let scene = SCNScene()
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(sphereNode)
        
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
    }
    
    override public var shouldAutorotate: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ARViewController {
    public func switchControlMode(to mode: ARControlMode) {
        switch mode {
        case .touch:
            let panGestureRec = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_ :)))
            sceneView.addGestureRecognizer(panGestureRec)
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
            let location = gesture.translation(in: sceneView)
            let orientation = cameraNode.eulerAngles
            let newOrientation = SCNVector3Make(orientation.x + Float(location.y - prevLocation.y) * 0.005,
                                                orientation.y + Float(location.x - prevLocation.x) * 0.005,
                                                orientation.z)
            
            cameraNode.eulerAngles = newOrientation
            prevLocation = location
        }
    }
}

