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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let urlStr = Bundle.main.path(forResource: "576003d01848e", ofType: "mp4")!
        let url = URL(fileURLWithPath: urlStr)
//        let url = URL(string: "https://player.vimeo.com/external/187856429.m3u8?s=70eca31df2bc0f134331bb230e80dea855c0a8b0")!
        let player = AVPlayer(url: url)
        player.play()
        arView.panoramaVideoPlayer = player
//        arView.panoramaTexture = UIImage(named: "1470302_1272179504")
        arView.controlMode = .motion
        arView.showsStatistics = true
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
