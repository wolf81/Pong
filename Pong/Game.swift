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
    
    let randomAngle = GKRandomDistribution(lowestValue: 45, highestValue: 135)
    
    private var nextPlayer: Player = .Red
    
    private var redPaddle: Paddle!
    private var bluePaddle: Paddle!
    private var topWall: Wall!
    private var bottomWall: Wall!
    
    private var beams = [Beam]()
    
    private(set) var gameScene: GameScene?
    
    private var ball: Ball?
    private var invisBall: Ball?
    
    override private init() {
        // Hide initializer, for this is a singleton.
    }

    func setup(forScene gameScene: GameScene) {
        self.gameScene = gameScene
        
        let y: CGFloat = gameScene.frame.height / 2
        let offset: CGFloat = 15.0
        
        gameScene.backgroundColor = SKColor.lightGrayColor()
        
        redPaddle = Paddle(position: CGPoint(x: offset, y: y), color: SKColor.redColor())
        bluePaddle = Paddle(position: CGPoint(x: gameScene.frame.width - offset, y: y), color: SKColor.blueColor())
        
        let size = CGSize(width: gameScene.frame.width + 10, height: 4.0)
        let topY = gameScene.frame.height - size.height - 60
        
        let x = CGRectGetMidX(gameScene.frame)
        topWall = Wall(position: CGPoint(x: x, y: topY), size: size, color: SKColor.purpleColor())
        bottomWall = Wall(position: CGPoint(x: x, y: size.height), size: size, color: SKColor.purpleColor())
        
        gameScene.physicsWorld.contactDelegate = self
        
        for entity in [redPaddle, bluePaddle, topWall, bottomWall] {
            if let vc = entity.componentForClass(VisualComponent) {
                gameScene.addChild(vc.sprite)
            }
        }
    }

    func movePaddle(direction: Direction, forPlayer player: Player) {
        if player == .Blue {
            return
        }

        let paddle = (player == .Red) ? redPaddle : bluePaddle
        
        let dy: CGFloat = CGFloat(paddle.speed)

        var velocity: CGVector = CGVector.zero
        
        switch direction {
        case .Up: velocity = CGVector(dx: 0, dy: dy)
        case .Down: velocity = CGVector(dx: 0, dy: -dy)
        case .None: break
        }
        
        paddle.velocity = velocity
    }
    
    func fireBeam(forPlayer player: Player) {
        guard let gameScene = self.gameScene else {
            return
        }
        
        let paddle = (player == .Red) ? redPaddle : bluePaddle
        
        let origin = CGPoint(x: paddle.position.x + 80, y: paddle.position.y)
        
        let beam = Beam(position: origin, color: SKColor.purpleColor())
        beams.append(beam)
        
        if let vc = beam.componentForClass(VisualComponent) {
            gameScene.addChild(vc.sprite)
            
            vc.sprite.physicsBody?.velocity = CGVector(dx: Constants.beamSpeed, dy: 0)
        }
    }
    
    // The main update loop. Called every frame to update game state.
    func update(deltaTime: CFTimeInterval) {
        guard let gameScene = self.gameScene else {
            return
        }
        
        if let ball = self.invisBall, let vc_ball = ball.componentForClass(VisualComponent) {
            let origin = vc_ball.sprite.position
            let dx = deltaTime * Double(ball.velocity.dx)
            let dy = deltaTime * Double(ball.velocity.dy)

            var x = Double(origin.x)
            
            if CGFloat(x) > CGRectGetMaxX(gameScene.frame) || x < 0 {
                ball.velocity = CGVector.zero
            } else {
                x = x + dx
            }
            
            vc_ball.sprite.position = CGPoint(x: CGFloat(x), y: origin.y + CGFloat(dy))
        }
        
        if let ball = self.ball, let vc_ball = ball.componentForClass(VisualComponent) {
            let origin = vc_ball.sprite.position
            let dx = deltaTime * Double(ball.velocity.dx)
            let dy = deltaTime * Double(ball.velocity.dy)
            vc_ball.sprite.position = CGPoint(x: origin.x + CGFloat(dx), y: origin.y + CGFloat(dy))

            let ballFrame = vc_ball.sprite.frame
            
            if (CGRectGetMinX(ballFrame) > CGRectGetMaxX(gameScene.frame) ||
                CGRectGetMaxX(ballFrame) < CGRectGetMinX(gameScene.frame)) {

                if destroyBall(ball) {
                    self.ball = nil
                }
                
                if let invisBall = self.invisBall {
                    if destroyBall(invisBall) {
                        self.invisBall = nil
                    }
                }
            }
        } else {
            let y: CGFloat = gameScene.frame.height / 2            
            
            switch nextPlayer {
            case .Red: nextPlayer = .Blue
            case .Blue: nextPlayer = .Red
            }

            let position = CGPoint(x: gameScene.frame.width / 2, y: y)

            var angle = GLKMathDegreesToRadians(Float(randomAngle.nextInt()))
            if nextPlayer == .Red {
                angle += Float(M_PI)
            }
            
            self.ball = spawnBall(forScene: gameScene, position: position, angle: angle, speed: Constants.ballSpeed)
            self.invisBall = spawnBall(forScene: gameScene, position: position, angle: angle, speed: Constants.ballSpeed + 50, canHitPaddle: false)
        }
        
        if let ball = self.invisBall, let cpuPaddle = self.bluePaddle {
            let range = cpuPaddle.position.y - 40 ... cpuPaddle.position.y + 40
            
            if range.contains(ball.position.y) == false {
                if cpuPaddle.position.y > ball.position.y {
                    if cpuPaddle.velocity.dy >= 0 {
                        movePaddle(Direction.Down, forPlayer: .Blue)
                    }
                } else if cpuPaddle.position.y < ball.position.y {
                    if cpuPaddle.velocity.dy <= 0 {
                        movePaddle(Direction.Up, forPlayer: .Blue)
                    }
                } else {
                    movePaddle(Direction.None, forPlayer: .Blue)
                }
            } else {            
                movePaddle(Direction.None, forPlayer: .Blue)
            }
        }
        
        guard
            let vc_topWall = topWall.componentForClass(VisualComponent),
            let vc_bottomWall = bottomWall.componentForClass(VisualComponent) else {
            return
        }
        
        for paddle in [redPaddle, bluePaddle] {
            guard let vc_paddle = paddle.componentForClass(VisualComponent) else {
                continue
            }
            
            if CGRectGetMaxY(vc_paddle.sprite.frame) >= CGRectGetMinY(vc_topWall.sprite.frame) &&
                paddle.velocity.dy > 0 {
                paddle.velocity = CGVector.zero
            } else if CGRectGetMinY(vc_paddle.sprite.frame) <= CGRectGetMaxY(vc_bottomWall.sprite.frame) &&
                paddle.velocity.dy < 0 {
                paddle.velocity = CGVector.zero
            } else {
                let dy = deltaTime * Double(paddle.velocity.dy)
                let origin = vc_paddle.sprite.position
                let dx = 0
                vc_paddle.sprite.position = CGPoint(x: origin.x + CGFloat(dx), y: origin.y + CGFloat(dy))
            }
        }
        
        var beams = [Beam]()
        for beam in self.beams {
            if let vc = beam.componentForClass(VisualComponent) {
                if vc.sprite.parent != nil {
                    beams.append(beam)
                }
            }
        }
        self.beams = beams
    }

    private func handleContactBetweenBall(ball: Ball, andPaddle paddle: Paddle) {
        guard let scene = self.gameScene else {
            return
        }

        var speed = ball.speed
        
        let offset = ball.position.y + (Constants.paddleHeight / 2) - paddle.position.y
        let relativeOffset = fmax(fmin(offset / Constants.paddleHeight, 1), 0)        
        let angleOffset = GLKMathDegreesToRadians(20)
        let reflectAngle = GLKMathDegreesToRadians(140)
        
        var angle: CGFloat
        
        if paddle == redPaddle {
            angle = (1 - relativeOffset) * CGFloat(reflectAngle) + CGFloat(angleOffset)
        } else {
            angle = relativeOffset * CGFloat(reflectAngle) + CGFloat(angleOffset) + CGFloat(M_PI)
        }

        if ((paddle.velocity.dy > 0 && ball.velocity.dy > 0) ||
            (paddle.velocity.dy < 0 && ball.velocity.dy < 0)) {
            print("+ speed")
            speed += 70
        } else if ((paddle.velocity.dy > 0 && ball.velocity.dy < 0) ||
            (paddle.velocity.dy < 0 && ball.velocity.dy > 0)) {
            print("- speed")
            speed -= 70
        }
        
        updateBall(ball, angle: Float(angle), speed: speed)
        
        if let invisBall = self.invisBall where destroyBall(invisBall) == true {
            self.invisBall = nil
        }
        
        self.invisBall = spawnBall(forScene: scene, position: ball.position, angle: Float(angle), speed: speed + 50, canHitPaddle: false)
    }
    
    private func handleContactBetweenBall(ball: Ball, andWall wall: Wall) {
        let velocity = ball.velocity
        ball.velocity = CGVector(dx: velocity.dx, dy: -velocity.dy)
    }
    
    private func handleContactBetweenPaddle(paddle: Paddle, andBeam beam: Beam) {
        guard
            let gameScene = self.gameScene,
            let beamVc = beam.componentForClass(VisualComponent),
            let paddleVc = paddle.componentForClass(VisualComponent) else {
            return
        }
        
        var origin = paddleVc.sprite.convertPoint(beamVc.sprite.position, fromNode: gameScene)
        origin.y += Constants.paddleHeight / 2
        origin.y = Constants.paddleHeight - origin.y
        paddle.addHole(origin.y, height: Constants.beamHeight)
    }
    
    private func handleContactBetweenPaddle(paddle: Paddle, andWall wall: Wall) {
        paddle.velocity = CGVector.zero
    }
    
    private func updateBall(ball: Ball, angle: Float, speed: Float) {
        let dy = cos(angle) * speed
        let dx = sin(angle) * speed
        let velocity = CGVector(dx: CGFloat(dx), dy: CGFloat(dy))
        
        ball.speed = speed
        ball.velocity = velocity
    }
    
    private func spawnBall(forScene scene: SKScene, position: CGPoint, angle: Float, speed: Float, canHitPaddle: Bool = true) -> Ball {
        var ball: Ball
        
        let dy = cos(angle) * speed
        let dx = sin(angle) * speed
        let velocity = CGVector(dx: CGFloat(dx), dy: CGFloat(dy))
        
        ball = Ball(position: position, velocity: velocity, canHitPaddle: canHitPaddle)
        
        if let vc = ball.componentForClass(VisualComponent) {
            scene.addChild(vc.sprite)
        }
        
        return ball
    }
    
    private func destroyBall(ball: Ball) -> Bool {
        var success = false
        
        if let vc = ball.componentForClass(VisualComponent) {
            vc.sprite.removeFromParent()
            success = true
        }
        
        return success
    }
}

extension Game : SKPhysicsContactDelegate {
    func didEndContact(contact: SKPhysicsContact) {
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        guard
            let bodyA = contact.bodyA.node as? SpriteNode,
            let entity1 = bodyA.entity,
            let bodyB = contact.bodyB.node as? SpriteNode,
            let entity2 = bodyB.entity else {
                return
        }
        
//        print("contact: \(entity1), \(entity2)")
        
        switch (entity1, entity2) {
        case (is Paddle, is Wall):
            handleContactBetweenPaddle(entity1 as! Paddle, andWall: entity2 as! Wall)
        case (is Wall, is Paddle):
            handleContactBetweenPaddle(entity2 as! Paddle, andWall: entity1 as! Wall)
        case (is Paddle, is Beam):
            handleContactBetweenPaddle(entity1 as! Paddle, andBeam: entity2 as! Beam)
        case (is Beam, is Paddle):
            handleContactBetweenPaddle(entity2 as! Paddle, andBeam: entity1 as! Beam)
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