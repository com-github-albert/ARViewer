//
//  ARViewController.swift
//  ARViewer
//
//  Created by JT Ma on 11/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit
import AVFoundation

public class ARViewController: UIViewController {
    
    @IBOutlet weak var arView: ARView!
    
    let preview = CameraPreview()
    let camera = CameraCapture()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
//        setupARGame()
        setupCamera()
    }
    
    func setupARGame() {
        let urlStr = Bundle.main.path(forResource: "576003d01848e", ofType: "mp4")!
        let url = URL(fileURLWithPath: urlStr)
        let player = AVPlayer(url: url)
        player.play()
        arView.panoramaVideoPlayer = player
//        arView.panoramaTexture = UIImage(named: "1470302_1272179504")
        arView.controlMode = .motion
        arView.showsStatistics = true
    }
    
    func setupCamera() {
        view.add(view: preview)
        preview.session = camera.session
        camera.start()
    }
}

extension ARViewController {
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

fileprivate extension UIView {
    func add(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let views = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
}
