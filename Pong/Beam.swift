//
//  Beam.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 02/09/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Beam : Entity {
    init(position: CGPoint, color: SKColor) {
        super.init()
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: Constants.beamHeight)
        let path = CGPathCreateWithRect(rect, nil)
        let shape = ShapeNode(path: path, centered: true)
        shape.entity = self
        shape.fillColor = color
        shape.strokeColor = color
        shape.position = position
        let vc = VisualComponent(shape: shape)
        addComponent(vc)
        
        vc.shape.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        vc.shape.physicsBody?.categoryBitMask = EntityCategory.Beam
        vc.shape.physicsBody?.contactTestBitMask = EntityCategory.Paddle
        vc.shape.physicsBody?.collisionBitMask = EntityCategory.Nothing
    }
}