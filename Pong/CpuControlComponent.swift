//
//  CpuControlComponent.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 09/09/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import GameplayKit

class CpuControlComponent : GKComponent {
    weak var paddle: Paddle?
    
    init(paddle: Paddle) {
        self.paddle = paddle
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        guard
            let ball = Game.sharedInstance.invisBall,
            let cpuPaddle = self.paddle else {
                return
        }
        
        let game = Game.sharedInstance
        
        let yOffset = Constants.paddleHeight / 5
        let range = cpuPaddle.position.y - yOffset ... cpuPaddle.position.y + yOffset
        
        if range.contains(ball.position.y) == false {
            if cpuPaddle.position.y > ball.position.y {
                if cpuPaddle.velocity.dy >= 0 {
                    game.movePaddle(Direction.Down, forPlayer: cpuPaddle.player)
                }
            } else if cpuPaddle.position.y < ball.position.y {
                if cpuPaddle.velocity.dy <= 0 {
                    game.movePaddle(Direction.Up, forPlayer: cpuPaddle.player)
                }
            } else {
                game.movePaddle(Direction.None, forPlayer: cpuPaddle.player)
            }
        } else {
            game.movePaddle(Direction.None, forPlayer: cpuPaddle.player)
        }
    }
}