//
//  Paddle.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Paddle : Entity {
    init(position: CGPoint, color: SKColor) {
        super.init()
        
        let rect = CGRect(x: 0, y: 0, width: 10, height: Constants.paddleHeight)
        let path = CGPathCreateWithRect(rect, nil)
        let shape = ShapeNode(path: path, centered: true)
        shape.entity = self
        shape.fillColor = color
        shape.strokeColor = color
        shape.position = position
        let vc = VisualComponent(shape: shape)
        addComponent(vc)
        
        vc.shape.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        vc.shape.physicsBody?.affectedByGravity = false
        vc.shape.physicsBody?.categoryBitMask = EntityCategory.Paddle
        vc.shape.physicsBody?.contactTestBitMask = EntityCategory.Wall
        vc.shape.physicsBody?.collisionBitMask = EntityCategory.Nothing
    }
}