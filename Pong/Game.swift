//
//  Game.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit
import GameplayKit

class Game : NSObject {
    static let sharedInstance = Game()
    
    // TODO: Generate an angle, between 60 to 300 (-60).
    let randomX = GKRandomDistribution(lowestValue: 0, highestValue: 2)
    let randomY = GKRandomDistribution(lowestValue: -250, highestValue: 250)
    
    private var nextPlayer: Player = .Red
    
    private var player1: Paddle!
    private var player2: Paddle!
    private var topWall: Wall!
    private var bottomWall: Wall!
    
    private(set) var gameScene: GameScene?
    
    private var ball: Ball?
    
    override private init() {
        // Hide initializer, for this is a singleton.
    }

    func setup(forScene gameScene: GameScene) {
        self.gameScene = gameScene
        
        let y: CGFloat = gameScene.frame.height / 2
        let offset: CGFloat = 15.0
        
        player1 = Paddle(position: CGPoint(x: offset, y: y), color: SKColor.redColor())
        player2 = Paddle(position: CGPoint(x: gameScene.frame.width - offset, y: y), color: SKColor.blueColor())
        
        let size = CGSize(width: gameScene.frame.width, height: 2.0)
        let topY = gameScene.frame.height - size.height - 60
        topWall = Wall(position: CGPoint(x: 0, y: topY), size: size, color: SKColor.purpleColor())
        bottomWall = Wall(position: CGPoint(x: 0, y: 0), size: size, color: SKColor.purpleColor())
        
        gameScene.physicsWorld.contactDelegate = self
        
        for entity in [player1, player2, topWall, bottomWall] {
            if let vc = entity.componentForClass(VisualComponent) {
                gameScene.addChild(vc.shape)
            }
        }
    }

    func movePaddle(direction: Direction, forPlayer player: Player) {
        let paddle = (player == .Red) ? player1 : player2
        
        guard let vc = paddle.componentForClass(VisualComponent),
            let physicsBody = vc.shape.physicsBody else {
            return
        }

        var velocity: CGVector = CGVector.zero
        let dy: CGFloat = 350
        
        switch direction {
        case .Up: velocity = CGVector(dx: 0, dy: dy)
        case .Down: velocity = CGVector(dx: 0, dy: -dy)
        case .None: break
        }
        
        physicsBody.velocity = velocity
    }
    
    // The main update loop. Called every frame to update game state.
    func update(deltaTime: CFTimeInterval) {
        guard let gameScene = self.gameScene else {
            return
        }
        
        gameScene.didSimulatePhysics()
        
        if let ball = self.ball, let vc_ball = ball.componentForClass(VisualComponent) {
            let origin = vc_ball.shape.position
            let dx = deltaTime * Double(ball.velocity.dx) * 400
            let dy = deltaTime * Double(ball.velocity.dy) * 400
            vc_ball.shape.position = CGPoint(x: origin.x + CGFloat(dx), y: origin.y + CGFloat(dy))

            let ballFrame = vc_ball.shape.frame
            let wallFrame = bottomWall.componentForClass(VisualComponent)!.shape.frame
            
            if CGRectGetMinX(ballFrame) > CGRectGetMaxX(gameScene.frame) ||
                CGRectGetMaxX(ballFrame) < CGRectGetMinX(gameScene.frame) {
                self.ball = nil
                vc_ball.shape.removeFromParent()
            } else if CGRectGetMaxY(ballFrame) < CGRectGetMaxY(wallFrame) {
                self.ball = nil
                vc_ball.shape.removeFromParent()
            }
        } else {
            let y: CGFloat = gameScene.frame.height / 2            
            
            switch nextPlayer {
            case .Red: nextPlayer = .Blue
            case .Blue: nextPlayer = .Red
            }

            let dx = (nextPlayer == .Red) ? -randomX.nextUniform() : randomX.nextUniform()
            let dy = randomY.nextUniform()
            let velocity = CGVector(dx: CGFloat(dx), dy: CGFloat(dy))
            let ball = Ball(position: CGPoint(x: gameScene.frame.width / 2, y: y), velocity: velocity)
            if let vc = ball.componentForClass(VisualComponent) {
                gameScene.addChild(vc.shape)
            }
            
            self.ball = ball
        }

        guard
            let vc_paddle1 = player1.componentForClass(VisualComponent),
            let vc_paddle2 = player2.componentForClass(VisualComponent),
            let vc_topWall = topWall.componentForClass(VisualComponent),
            let vc_bottomWall = bottomWall.componentForClass(VisualComponent) else {
            return
        }
        
        for vc_paddle in [vc_paddle1, vc_paddle2] {
            if CGRectGetMaxY(vc_paddle.shape.frame) >= CGRectGetMinY(vc_topWall.shape.frame) &&
                vc_paddle.shape.physicsBody?.velocity.dy > 0 {
                vc_paddle.shape.physicsBody?.velocity = CGVector.zero
            } else if CGRectGetMinY(vc_paddle.shape.frame) <= CGRectGetMaxY(vc_bottomWall.shape.frame) &&
                vc_paddle.shape.physicsBody?.velocity.dy < 0 {
                vc_paddle.shape.physicsBody?.velocity = CGVector.zero
            }
        }
    }

    private func handleContactBetweenBall(ball: Ball, andPaddle paddle: Paddle) {
        let velocity = ball.velocity
        ball.velocity = CGVector(dx: -velocity.dx, dy: velocity.dy)
    }

    private func handleContactBetweenBall(ball: Ball, andWall wall: Wall) {
        let velocity = ball.velocity
        ball.velocity = CGVector(dx: velocity.dx, dy: -velocity.dy)
    }

    private func handleContactBetweenPaddle(paddle: Paddle, andWall wall: Wall) {
        guard let vc = paddle.componentForClass(VisualComponent) else {
            return
        }
        
        vc.shape.physicsBody?.velocity = CGVector.zero
    }
}

extension Game : SKPhysicsContactDelegate {
    func didEndContact(contact: SKPhysicsContact) {
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        guard
            let bodyA = contact.bodyA.node as? ShapeNode,
            let entity1 = bodyA.entity,
            let bodyB = contact.bodyB.node as? ShapeNode,
            let entity2 = bodyB.entity else {
                return
        }
        
        print("contact: \(entity1), \(entity2)")
        
        switch (entity1, entity2) {
        case (is Paddle, is Wall):
            handleContactBetweenPaddle(entity1 as! Paddle, andWall: entity2 as! Wall)
        case (is Wall, is Paddle):
            handleContactBetweenPaddle(entity2 as! Paddle, andWall: entity1 as! Wall)
        case (is Ball, is Wall):
            handleContactBetweenBall(entity1 as! Ball, andWall: entity2 as! Wall)
        case (is Wall, is Ball):
            handleContactBetweenBall(entity2 as! Ball, andWall: entity1 as! Wall)
        case (is Ball, is Paddle):
            handleContactBetweenBall(entity2 as! Ball, andPaddle: entity1 as! Paddle)
        case (is Paddle, is Ball):
            handleContactBetweenBall(entity2 as! Ball, andPaddle: entity1 as! Paddle)
        default:
            break
        }
    }
}