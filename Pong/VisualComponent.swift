//
//  VisualComponent.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import GameKit
import SpriteKit

class VisualComponent : GKComponent {
    private(set) var sprite: SKSpriteNode
    
    init(sprite: SKSpriteNode) {
        self.sprite = sprite
        
        super.init()
    }
    
    func replaceSprite(newSprite: SKSpriteNode) {
        let parent = sprite.parent
        let position = sprite.position
        let zPosition = sprite.zPosition

        sprite.removeFromParent()
        
        self.sprite = newSprite
        self.sprite.position = position
        self.sprite.zPosition = zPosition
        parent?.addChild(self.sprite)
    }
}
