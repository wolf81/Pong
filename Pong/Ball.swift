//
//  Ball.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Ball : Entity {
    var owner: Player?
    
    init(position: CGPoint, velocity: CGVector) {
        super.init()
        
        self.speed = Constants.ballSpeed
        self.velocity = velocity
        
        let r: CGFloat = 25
        let rect = CGRect(x: 0, y: 0, width: r, height: r)
        let path = CGPathCreateWithEllipseInRect(rect, nil)
        let shape = SKShapeNode(path: path, centered: true)
        shape.fillColor = SKColor.whiteColor()
        shape.strokeColor = SKColor.whiteColor()

        let sprite = SpriteNode(texture: shape.texture)
        sprite.entity = self
        sprite.position = position
        
        let vc = VisualComponent(sprite: sprite)
        vc.sprite.zPosition = EntityLayer.Ball.rawValue
        addComponent(vc)
        
        let pBody = SKPhysicsBody(circleOfRadius: r / 2, center: CGPoint.zero)
        pBody.categoryBitMask = EntityCategory.Ball
        pBody.collisionBitMask = EntityCategory.Nothing
        pBody.usesPreciseCollisionDetection = true
        pBody.restitution = 0
        pBody.friction = 0
        pBody.contactTestBitMask = EntityCategory.Wall | EntityCategory.Block | EntityCategory.Paddle
                
        vc.sprite.physicsBody = pBody
    }
}