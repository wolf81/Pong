//
//  TracerBall.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 10/09/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class TracerBall : Ball {
    weak var ball: Ball?
    
    init(forBall ball: Ball, position: CGPoint, velocity: CGVector) {
        self.ball = ball
        
        super.init(position: position, velocity: velocity)
        
        if let vc = componentForClass(VisualComponent) {
            vc.sprite.alpha = 0.15
            
            if let pBody = vc.sprite.physicsBody {
                pBody.contactTestBitMask = EntityCategory.Wall | EntityCategory.Block
            }
        }
    }
}
