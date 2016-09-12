//
//  Beam.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 02/09/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Beam : Entity {
    init(position: CGPoint, color: SKColor, size: CGFloat) {
        super.init()
        
        let rect = CGRect(x: 0, y: 0, width: 100, height: size)
        let path = CGPathCreateWithRect(rect, nil)
        let shape = SKShapeNode(path: path, centered: true)
        shape.fillColor = color
        shape.strokeColor = color

        let sprite = SpriteNode(texture: shape.texture)
        sprite.entity = self        
        sprite.position = position
        
        let vc = VisualComponent(sprite: sprite)
        vc.sprite.zPosition = EntityLayer.Beam.rawValue
        
        let pBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        pBody.categoryBitMask = EntityCategory.Beam
        pBody.collisionBitMask = EntityCategory.Nothing
        pBody.contactTestBitMask = EntityCategory.Paddle
        pBody.usesPreciseCollisionDetection = true
        vc.sprite.physicsBody = pBody
        
        addComponent(vc)
    }
}