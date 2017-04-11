//
//  ExDeviceMotion.swift
//  ARViewer
//
//  Created by JT Ma on 11/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import SceneKit
import CoreMotion

extension CMDeviceMotion {
    
    func gaze(atOrientation orientation: UIInterfaceOrientation) -> SCNVector4 {
        
        let attitude = self.attitude.quaternion
        let aq = GLKQuaternionMake(Float(attitude.x), Float(attitude.y), Float(attitude.z), Float(attitude.w))
        
        var result: SCNVector4
        
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight:
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(Double.pi / 2), 0, 1, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            result = SCNVector4(x: -q.y, y: q.x, z: q.z, w: q.w)
        case .landscapeLeft:
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(-Double.pi / 2), 0, 1, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            result = SCNVector4(x: q.y, y: -q.x, z: q.z, w: q.w)
        case .portraitUpsideDown:
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(Double.pi / 2), 1, 0, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            result = SCNVector4(x: -q.x, y: -q.y, z: q.z, w: q.w)
        case .unknown:
            
            fallthrough
        case .portrait:
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float(-Double.pi / 2), 1, 0, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            result = SCNVector4(x: q.x, y: q.y, z: q.z, w: q.w)
        }
        
        return result
    }
}
