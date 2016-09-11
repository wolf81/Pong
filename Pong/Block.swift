//
//  Block.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 09/09/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

/*
 Blocks have power-ups:
 - ImproveLaser
 - Shield
 - MultiBall
 - Mines
 - Heal
 - SpeedUp (1 ball)
 - SlowDown (1 ball)
 
 P.S/: Balls can be 'owned' for power-ups
 */

class Block : Entity {
    var power: Power
    
    var didTrigger = false
    
    init(power: Power, position: CGPoint, color: SKColor) {
        self.power = power
        
        super.init()
        
        let l = 34
        let rect = CGRect(x: 0, y: 0, width: l, height: l)
        
        let shape = SKShapeNode(rect: rect)
        shape.fillColor = color
        shape.strokeColor = color
        
        let sprite = SpriteNode(texture: shape.texture)
        sprite.entity = self
        sprite.position = position
        
        let vc = VisualComponent(sprite: sprite)
        vc.sprite.zPosition = EntityLayer.Block.rawValue
        addComponent(vc)
        
        let pBody = SKPhysicsBody(rectangleOfSize: rect.size)
        pBody.collisionBitMask = EntityCategory.Nothing
        pBody.contactTestBitMask = EntityCategory.Nothing
        pBody.categoryBitMask = EntityCategory.Block
        vc.sprite.physicsBody = pBody
    }
}