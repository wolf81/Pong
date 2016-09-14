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
        let game = Game.sharedInstance
        let balls: [Ball] = Game.sharedInstance.tracerBalls + Game.sharedInstance.balls
        
        guard
            let paddle = self.paddle where balls.count > 0,
            let gameScene = game.gameScene else {
                return
        }

        if paddle.canAttack {
            let position = paddle.position
            let otherPlayer = game.otherPlayer(forPlayer: paddle.player)
            
            guard let otherPaddle = game.paddleForPlayer(otherPlayer) else {
                return
            }
            
            if otherPaddle.isDestroyed == false {
                let yOffset = Constants.paddleHeight / 2
                let yRange = (position.y - yOffset) ..< (position.y + yOffset)
                
                if yRange.contains(otherPaddle.position.y) {
                    paddle.attack()
                }
            }
        }
        
        if let ball = closestBallForPaddle(paddle, fromBalls: balls) {
            movePaddle(paddle, toBall: ball)
        } else {
            movePaddleToCenter(paddle, forScene: gameScene)
        }
    }
    
    // MARK: - Private
    
    private func closestBallForPaddle(paddle: Paddle, fromBalls balls: [Ball]) -> Ball? {
        let ball = balls.filter { tracerBall -> Bool in
            if tracerBall.position.x < paddle.position.x {
                return tracerBall.velocity.dx > 0
            } else if tracerBall.position.x > paddle.position.x {
                return tracerBall.velocity.dx < 0
            } else {
                return false
            }
        }.sort { (tracerBall1, tracerBall2) -> Bool in
            if tracerBall1.position.x < paddle.position.x {
                return tracerBall1.position.x > tracerBall2.position.x
            } else if tracerBall1.position.x > paddle.position.x {
                return tracerBall1.position.x < tracerBall2.position.x
            } else {
                return false
            }
        }.first
        
        return ball
    }
    
    private func movePaddleToCenter(paddle: Paddle, forScene scene: GameScene) {
        let yOffset = Constants.paddleHeight / 5
        let midY = CGRectGetMidY(scene.frame)
        let range = (midY - yOffset) ..< (midY + yOffset)
        
        if range.contains(paddle.position.y) {
            Game.sharedInstance.movePaddle(Direction.None, forPlayer: paddle.player)
        } else {
            switch paddle.position.y {
            case _ where paddle.position.y > midY:
                Game.sharedInstance.movePaddle(Direction.Down, forPlayer: paddle.player)
            default:
                Game.sharedInstance.movePaddle(Direction.Up, forPlayer: paddle.player)
            }
        }
    }
    
    private func movePaddle(paddle: Paddle, toBall ball: Ball) {
        let yOffset = Constants.paddleHeight / 5
        let yRange = (paddle.position.y - yOffset) ..< (paddle.position.y + yOffset)
        
        if yRange.contains(ball.position.y) == false {
            switch ball.position.y {
            case _ where paddle.position.y > ball.position.y:
                if paddle.velocity.dy >= 0 {
                    Game.sharedInstance.movePaddle(Direction.Down, forPlayer: paddle.player)
                }
            case _ where paddle.position.y < ball.position.y:
                if paddle.velocity.dy <= 0 {
                    Game.sharedInstance.movePaddle(Direction.Up, forPlayer: paddle.player)
                }
            default:
                Game.sharedInstance.movePaddle(Direction.None, forPlayer: paddle.player)
            }
        } else {
            Game.sharedInstance.movePaddle(Direction.None, forPlayer: paddle.player)
        }
    }
}