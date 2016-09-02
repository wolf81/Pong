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
        let shape = ShapeNode(path: path, centered: false)
        shape.entity = self
        shape.fillColor = color
        shape.strokeColor = color
        shape.position = position
        let vc = VisualComponent(shape: shape)
        addComponent(vc)
        
        vc.shape.physicsBody = SKPhysicsBody(polygonFromPath: path)
        vc.shape.physicsBody?.affectedByGravity = false
        vc.shape.physicsBody?.categoryBitMask = EntityCategory.Wall
        vc.shape.physicsBody?.contactTestBitMask = EntityCategory.Nothing
        vc.shape.physicsBody?.collisionBitMask = EntityCategory.Nothing
    }
}