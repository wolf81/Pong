//
//  Ball.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Ball : Entity {    
    init(position: CGPoint, velocity: CGVector, canHitPaddle: Bool = true) {
        super.init()
        
        self.speed = Constants.ballSpeed
        self.velocity = velocity
        
        let r: CGFloat = 25
        let rect = CGRect(x: 0, y: 0, width: r, height: r)
        let path = CGPathCreateWithEllipseInRect(rect, nil)
        let shape = ShapeNode(path: path, centered: true)
        shape.entity = self
        shape.position = position
        
        if canHitPaddle == false {
            shape.alpha = 0.15
        }
        
        shape.fillColor = SKColor.whiteColor()
        shape.strokeColor = SKColor.whiteColor()
        
        let vc = VisualComponent(shape: shape)
        addComponent(vc)
        
        vc.shape.physicsBody = SKPhysicsBody(circleOfRadius: r / 2)
        vc.shape.physicsBody?.categoryBitMask = EntityCategory.Ball
        vc.shape.physicsBody?.collisionBitMask = EntityCategory.Nothing
        
        if canHitPaddle {
            vc.shape.physicsBody?.contactTestBitMask = EntityCategory.Paddle | EntityCategory.Wall
        } else {
            vc.shape.physicsBody?.contactTestBitMask = EntityCategory.Wall
        }
        
        vc.shape.physicsBody?.usesPreciseCollisionDetection = true
    }
}