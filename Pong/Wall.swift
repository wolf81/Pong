//
//  Wall.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Wall : Entity {
    init(position: CGPoint, size: CGSize, color: SKColor) {
        super.init()
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = CGPathCreateWithRect(rect, nil)
        let shape = SKShapeNode(path: path, centered: false)
        shape.fillColor = color
        shape.strokeColor = color

        let sprite = SpriteNode(texture: shape.texture)
        sprite.entity = self
        sprite.position = position
        let vc = VisualComponent(sprite: sprite)
        addComponent(vc)
        
        vc.sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        vc.sprite.physicsBody?.affectedByGravity = false
        vc.sprite.physicsBody?.categoryBitMask = EntityCategory.Wall
        vc.sprite.physicsBody?.contactTestBitMask = EntityCategory.Nothing
        vc.sprite.physicsBody?.collisionBitMask = EntityCategory.Nothing
    }
}