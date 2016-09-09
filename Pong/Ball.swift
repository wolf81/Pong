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
        let shape = SKShapeNode(path: path, centered: true)
        shape.fillColor = SKColor.whiteColor()
        shape.strokeColor = SKColor.whiteColor()
        if canHitPaddle == false {
            shape.alpha = 0.15
        }

        let sprite = SpriteNode(texture: shape.texture)
        sprite.entity = self
        sprite.position = position
        
        let vc = VisualComponent(sprite: sprite)
        vc.sprite.zPosition = EntityLayer.Ball.rawValue
        addComponent(vc)
        
        vc.sprite.physicsBody = SKPhysicsBody(circleOfRadius: r / 2, center: CGPoint.zero)
        vc.sprite.physicsBody?.categoryBitMask = EntityCategory.Ball
        vc.sprite.physicsBody?.collisionBitMask = EntityCategory.Nothing
        
        if canHitPaddle {
            vc.sprite.physicsBody?.contactTestBitMask = EntityCategory.Paddle | EntityCategory.Wall | EntityCategory.Block
        } else {
            vc.sprite.physicsBody?.contactTestBitMask = EntityCategory.Wall | EntityCategory.Block
        }
        
        vc.sprite.physicsBody?.usesPreciseCollisionDetection = true
    }
}