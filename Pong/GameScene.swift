//
//  GameScene.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright (c) 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class GameScene : BaseScene {
    private var lastUpdateTime: NSTimeInterval = 0
    
    override func didMoveToView(view: SKView) {
        Game.sharedInstance.setup(forScene: self)
    }
        
    override func update(currentTime: CFTimeInterval) {
        if lastUpdateTime <= 0 {
            lastUpdateTime = currentTime
        } else {
            let deltaTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            Game.sharedInstance.update(deltaTime)
        }
    }
    
    override func handleUpPress(forPlayer player: Player) {
        Game.sharedInstance.movePaddle(.Up, forPlayer: player)
    }
    
    override func handleUpRelease(forPlayer player: Player) {
        Game.sharedInstance.movePaddle(.None, forPlayer: player)
    }
    
    override func handleDownPress(forPlayer player: Player) {
        Game.sharedInstance.movePaddle(.Down, forPlayer: player)
    }
    
    override func handleDownRelease(forPlayer player: Player) {
        Game.sharedInstance.movePaddle(.None, forPlayer: player)        
    }
}
