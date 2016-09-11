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
    
    let cpuControlSystem = GKComponentSystem(componentClass: CpuControlComponent.self)
    
    let randomAngle = GKRandomDistribution(lowestValue: 45, highestValue: 135)
    
    private var nextPlayer: Player = .Red
    
    private var redPaddle: Paddle!
    private var bluePaddle: Paddle!
    
    private var beams = [Beam]()
    private var blocks = [Block]()
    private var walls = [Wall]()
    private var balls = [Ball]()
    private(set) var tracerBalls = [TracerBall]()
    
    private(set) var gameScene: GameScene?
    
    private var entitiesToRemove = [Entity]()
    private var entitiesToAdd = [Entity]()
    
    override private init() {
        // Hide initializer, for this is a singleton.
    }

    func setup(forScene gameScene: GameScene) {
        self.gameScene = gameScene
        
        let y: CGFloat = gameScene.frame.height / 2
        let offset: CGFloat = 15.0
        
        gameScene.backgroundColor = SKColor.lightGrayColor()
        
        redPaddle = Paddle(forPlayer: .Red, withControl: .Human, position: CGPoint(x: offset, y: y), color: SKColor.redColor())
        bluePaddle = Paddle(forPlayer: .Blue, withControl: .Cpu, position: CGPoint(x: gameScene.frame.width - offset, y: y), color: SKColor.blueColor())
        
        let size = CGSize(width: gameScene.frame.width + 20, height: 4.0)
        let topY = gameScene.frame.height - size.height - 60
        
        let x = CGRectGetMidX(gameScene.frame)
        let topWall = Wall(position: CGPoint(x: x, y: topY), size: size, color: SKColor.purpleColor())
        let bottomWall = Wall(position: CGPoint(x: x, y: size.height), size: size, color: SKColor.purpleColor())
        
        gameScene.physicsWorld.contactDelegate = self
        
        let maxX = Int(gameScene.frame.size.width) - 400
        let maxY = Int(gameScene.frame.size.height) - 200
        
        var blocks = [Block]()
        for i in 0 ..< 3 {
            let x = GKRandomSource.sharedRandom().nextIntWithUpperBound(maxX) + 200
            let y = GKRandomSource.sharedRandom().nextIntWithUpperBound(maxY) + 100
            
            let pos = CGPoint(x: x, y: y)
            let block = Block(power: .Repair, position: pos, color: SKColor.orangeColor())
            blocks.append(block)
        }
        
        let entities: [Entity] = blocks + [redPaddle, bluePaddle, topWall, bottomWall]
        entitiesToAdd.appendContentsOf(entities)
    }

    func movePaddle(direction: Direction, forPlayer player: Player) {
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
        let paddle = (player == .Red) ? redPaddle : bluePaddle
        
        let origin = CGPoint(x: paddle.position.x + 80, y: paddle.position.y)
        
        let beam = Beam(position: origin, color: SKColor.purpleColor())
        entitiesToAdd.append(beam)
        
        if let vc = beam.componentForClass(VisualComponent) {
            vc.sprite.physicsBody?.velocity = CGVector(dx: Constants.beamSpeed, dy: 0)
        }
    }
    
    // The main update loop. Called every frame to update game state.
    func update(deltaTime: CFTimeInterval) {
        guard let gameScene = self.gameScene else {
            return
        }
        
        updateEntityLists()
        
        cpuControlSystem.updateWithDeltaTime(deltaTime)
        
        let balls: [Ball] = self.balls + tracerBalls
        for ball in balls {
            if let vc_ball = ball.componentForClass(VisualComponent) {
                let origin = vc_ball.sprite.position
                let dx = deltaTime * Double(ball.velocity.dx)
                let dy = deltaTime * Double(ball.velocity.dy)
                vc_ball.sprite.position = CGPoint(x: origin.x + CGFloat(dx), y: origin.y + CGFloat(dy))
                
                let ballFrame = vc_ball.sprite.frame
                
                if (CGRectGetMinX(ballFrame) > CGRectGetMaxX(gameScene.frame) ||
                    CGRectGetMaxX(ballFrame) < CGRectGetMinX(gameScene.frame)) {
                    
                    entitiesToRemove.append(ball)
                }
            }
        }
        
        if balls.count == 0 {
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
            
            let ball = spawnBall(position, angle: angle, speed: Constants.ballSpeed)
            entitiesToAdd.append(ball)
            
            let tracerBall = spawnTracerBall(forBall: ball, angle: angle, speed: Constants.ballSpeed + 50)
            entitiesToAdd.append(tracerBall)
        }

        for paddle in [redPaddle, bluePaddle] {
            guard let vc_paddle = paddle.componentForClass(VisualComponent) else {
                continue
            }
            
            let dy = deltaTime * Double(paddle.velocity.dy)
            let origin = vc_paddle.sprite.position
            let dx = 0
            vc_paddle.sprite.position = CGPoint(x: origin.x + CGFloat(dx), y: origin.y + CGFloat(dy))
        }
    }

    private func updateEntityLists() {
        guard let gameScene = self.gameScene else {
            return
        }
        
        for entity in entitiesToRemove {
            if let vc = entity.componentForClass(VisualComponent) {
                vc.sprite.removeFromParent()
            }

            switch entity {
            case is Block: blocks.remove(entity as! Block)
            case is TracerBall: tracerBalls.remove(entity as! TracerBall)
            case is Ball: balls.remove(entity as! Ball)
            case is Beam: beams.remove(entity as! Beam)
            case is Wall: walls.remove(entity as! Wall)
            default: break
            }
            entitiesToRemove.removeAll()
        }
        
        for entity in entitiesToAdd {
            switch entity {
            case is Block: blocks.append(entity as! Block)
            case is Wall: walls.append(entity as! Wall)
            case is Beam: beams.append(entity as! Beam)
            case is TracerBall: tracerBalls.append(entity as! TracerBall)
            case is Ball: balls.append(entity as! Ball)
            default: break
            }
            
            if let vc = entity.componentForClass(VisualComponent) {
                assert(vc.sprite.parent == nil, "entity should not have parent: \(entity)")
                
                gameScene.addChild(vc.sprite)
            }

            cpuControlSystem.addComponentWithEntity(entity)

            entitiesToAdd.removeAll()
        }
    }
    
    private func handleContactBetweenBall(ball: Ball, andPaddle paddle: Paddle) {
        var speed = ball.speed
        
        if ball.dynamicType === Ball.self {
            print("ball: \(ball)")
            ball.owner = paddle.player
        }
        
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

        let ball = spawnTracerBall(forBall: ball, angle: Float(angle), speed: speed + 50)
        entitiesToAdd.append(ball)
    }
    
    private func handleContactBetweenBall(ball: Ball, andWall wall: Wall) {
        let velocity = ball.velocity
        ball.velocity = CGVector(dx: velocity.dx, dy: -velocity.dy)
    }
    
    private func handleContactBetweenBall(ball: Ball, andBlock block: Block) {
        let velocity = ball.velocity

        let xOffset = abs(ball.position.x - block.position.x)
        let yOffset = abs(ball.position.y - block.position.y)
        
        if xOffset > yOffset {
            ball.velocity = CGVector(dx: -velocity.dx, dy: velocity.dy)
        } else {
            ball.velocity = CGVector(dx: velocity.dx, dy: -velocity.dy)
        }
        
        if ball.dynamicType === Ball.self {
            guard let player = ball.owner else {
                return
            }

            if let paddle = paddleForPlayer(player) {
                switch block.power {
                case .Repair: paddle.repair()
                default: break
                }
            }

            entitiesToRemove.append(block)
        }
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
    
    private func spawnBall(position: CGPoint, angle: Float, speed: Float) -> Ball {
        var ball: Ball
        
        let dy = cos(angle) * speed
        let dx = sin(angle) * speed
        let velocity = CGVector(dx: CGFloat(dx), dy: CGFloat(dy))
        ball = Ball(position: position, velocity: velocity)
        
        return ball
    }
    
    private func spawnTracerBall(forBall ball: Ball, angle: Float, speed: Float) -> TracerBall {
        var tracerBall: TracerBall
        
        let dy = cos(angle) * speed
        let dx = sin(angle) * speed
        let velocity = CGVector(dx: CGFloat(dx), dy: CGFloat(dy))
        
        tracerBall = TracerBall(forBall: ball, position: ball.position, velocity: velocity)
        
        return tracerBall
    }
    
    private func paddleForPlayer(player: Player) -> Paddle? {
        let paddles = [redPaddle, bluePaddle].flatMap{ $0 }

        let paddle = paddles.filter { paddle -> Bool in
            return paddle.player == player
        }.first
        
        return paddle
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
        case (is Ball, is Block):
            handleContactBetweenBall(entity1 as! Ball, andBlock: entity2 as! Block)
        case (is Block, is Ball):
            handleContactBetweenBall(entity2 as! Ball, andBlock: entity1 as! Block)
        case (is Ball, is Paddle):
            handleContactBetweenBall(entity2 as! Ball, andPaddle: entity1 as! Paddle)
        case (is Paddle, is Ball):
            handleContactBetweenBall(entity2 as! Ball, andPaddle: entity1 as! Paddle)
        default:
            break
        }
    }
}