//
//  Ball.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Ball : Entity {    
    init(position: CGPoint, velocity: CGVector) {
        super.init(position: position)
        
        self.velocity = velocity
        
        let r: CGFloat = 25
        let rect = CGRect(x: 0, y: 0, width: r, height: r)
        let path = CGPathCreateWithEllipseInRect(rect, nil)
        let shape = ShapeNode(path: path, centered: true)
        shape.entity = self
        shape.position = position
        shape.fillColor = SKColor.whiteColor()
        shape.strokeColor = SKColor.whiteColor()
        
        let vc = VisualComponent(shape: shape)
        addComponent(vc)
        
        vc.shape.physicsBody = SKPhysicsBody(circleOfRadius: r / 2)
        vc.shape.physicsBody?.categoryBitMask = EntityCategory.Ball
        vc.shape.physicsBody?.contactTestBitMask = EntityCategory.Paddle | EntityCategory.Wall
        vc.shape.physicsBody?.usesPreciseCollisionDetection = true
    }
}