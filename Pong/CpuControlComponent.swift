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
            let cpuPaddle = self.paddle where Game.sharedInstance.tracerBalls.count > 0 else {
                return
        }
        
        if cpuPaddle.canAttack {
            let position = cpuPaddle.position
            let otherPlayer = Game.sharedInstance.otherPlayer(forPlayer: cpuPaddle.player)
            
            guard let otherPaddle = Game.sharedInstance.paddleForPlayer(otherPlayer) else {
                return
            }
            
            let yOffset = Constants.paddleHeight / 2
            let yRange = position.y - yOffset ..< position.y + yOffset
            
            if yRange.contains(otherPaddle.position.y) {
                cpuPaddle.attack()
            }
        }
        
        // find closest ball in direction of paddle
        
        let balls = Game.sharedInstance.tracerBalls.filter { tracerBall -> Bool in
            if tracerBall.position.x < cpuPaddle.position.x {
                return tracerBall.velocity.dx > 0
            } else if tracerBall.position.x > cpuPaddle.position.x {
                return tracerBall.velocity.dx < 0
            } else {
                return false
            }
        }.sort { (tracerBall1, tracerBall2) -> Bool in
            if tracerBall1.position.x < cpuPaddle.position.x {
                return tracerBall1.position.x > tracerBall2.position.x
            } else if tracerBall1.position.x > cpuPaddle.position.x {
                return tracerBall1.position.x < tracerBall2.position.x
            } else {
                return false
            }
        }

        guard let ball = balls.first else {
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