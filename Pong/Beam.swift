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
        
        let rect = CGRect(x: 0, y: 0, width: 0, height: Constants.beamHeight)
        let path = CGPathCreateWithRect(rect, nil)
        let shape = SKShapeNode(path: path, centered: true)
        shape.fillColor = color
        shape.strokeColor = color

        let convertView = SKView()
        let sprite = SpriteNode(texture: convertView.textureFromNode(shape))
        sprite.entity = self        
        sprite.position = position
        sprite.anchorPoint = CGPoint(x: 0, y: 0.5)
        let vc = VisualComponent(sprite: sprite)
        addComponent(vc)
    }
}