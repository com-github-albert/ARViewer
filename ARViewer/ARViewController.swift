//
//  ARViewController.swift
//  ARViewer
//
//  Created by JT Ma on 11/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit

public class ARViewController: UIViewController {
    
    @IBOutlet weak var arView: ARView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        arView.panoramaTexture = UIImage(named: "spherical")
        arView.controlMode = .motion
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
