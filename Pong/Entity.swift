//
//  Entity.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import GameplayKit

class Entity : GKEntity {
    var velocity: CGVector = CGVector.zero

    var position: CGPoint {
        get {
            var position = CGPoint.zero
            
            if let vc = componentForClass(VisualComponent) {
                position = vc.shape.position
            }
            
            return position
        }
    }
    
    override init() {
        super.init()
    }
}