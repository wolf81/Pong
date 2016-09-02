//
//  SKShapeNode+Utility.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 02/09/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

extension SKShapeNode {
    var texture: SKTexture? {
        get {
            var texture: SKTexture?
            
            let converterView = SKView()
            if let shapeTexture = converterView.textureFromNode(self) {
                texture = shapeTexture
            }
            
            return texture
        }
    }
}