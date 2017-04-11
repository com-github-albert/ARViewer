//
//  ExFloatingPoint.swift
//  ARViewer
//
//  Created by JT Ma on 11/04/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
    
    func toRadians() -> Self {
        return self * .pi / 180
    }
}
