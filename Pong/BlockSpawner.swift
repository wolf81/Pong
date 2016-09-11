//
//  BlockSpawner.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 11/09/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit
import GameplayKit

class BlockSpawner {
    weak var game: Game?
    
    var xRange = 0 ..< 100
    var yRange = 0 ..< 100
    
    init(forGame game: Game) {
        self.game = game
    }
    
    func updateWithDeltaTime(deltaTime: CFTimeInterval) {
        guard let game = self.game else {
            return
        }
        
        let blockCount = game.blocks.count
        
        if blockCount < 3 {
            let pos = randomPosition()
            let color = SKColor.orangeColor()
            let block = Block(power: .Repair, position: pos, color: color)            
            game.addEntity(block)
        }
    }
    
    func spawn() {
    }
    
    private func randomPosition() -> CGPoint {
        let x = GKRandomSource.sharedRandom().nextIntWithUpperBound(xRange.count) + xRange.startIndex
        let y = GKRandomSource.sharedRandom().nextIntWithUpperBound(yRange.count) + yRange.startIndex
        return CGPoint(x: x, y: y)
    }
}