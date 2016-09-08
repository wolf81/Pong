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
    private(set) var sprite: SpriteNode
    
    init(sprite: SpriteNode) {
        self.sprite = sprite
        
        super.init()
    }
    
    func replaceSprite(newSprite: SpriteNode) {
        let parent = sprite.parent
        let position = sprite.position
        let zPosition = sprite.zPosition
        let entity = sprite.entity

        sprite.removeFromParent()
        
        self.sprite = newSprite
        self.sprite.position = position
        self.sprite.zPosition = zPosition
        self.sprite.entity = entity
        parent?.addChild(self.sprite)
    }
}
