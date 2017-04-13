//
//  ExSize.swift
//  ARViewer
//
//  Created by JT Ma on 13/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit

extension CGSize {
    var midX: CGFloat {
        return width / 2
    }
    
    var midY: CGFloat {
        return height / 2
    }
    
    var midPoint: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
