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
    private(set) var shape: SKShapeNode
    
    init(shape: SKShapeNode) {
        self.shape = shape
        
        super.init()
    }
}
