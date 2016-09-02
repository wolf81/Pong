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
        
        self.speed = Constants.paddleSpeed
        
        let rect = CGRect(x: 0, y: 0, width: 10, height: Constants.paddleHeight)
        let path = CGPathCreateWithRect(rect, nil)
        let shape = SKShapeNode(path: path, centered: true)
        shape.fillColor = color
        shape.strokeColor = color

        let convertView = SKView()
        let sprite = SpriteNode(texture: convertView.textureFromNode(shape))
        sprite.entity = self
        sprite.position = position
        
        let vc = VisualComponent(sprite: sprite)
        addComponent(vc)
        
        vc.sprite.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        vc.sprite.physicsBody?.categoryBitMask = EntityCategory.Paddle
        vc.sprite.physicsBody?.contactTestBitMask = EntityCategory.Wall
        vc.sprite.physicsBody?.collisionBitMask = EntityCategory.Nothing
    }
}