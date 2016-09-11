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
    
    private var blockSpawner: BlockSpawner!
    private var ballSpawner: BallSpawner!
    
    private(set) var nextPlayer: Player = .Red
    
    private var paddles = [Paddle]()
    private var beams = [Beam]()
    private var walls = [Wall]()
    private(set) var balls = [Ball]()
    private(set) var tracerBalls = [TracerBall]()
    private(set) var blocks = [Block]()
    
    private(set) var gameScene: GameScene?
    
    private var entitiesToRemove = [Entity]()
    private var entitiesToAdd = [Entity]()
    
    // Hide initializer, for this is a singleton.
    override private init() {
        super.init()
        
        blockSpawner = BlockSpawner(forGame: self)
        ballSpawner = BallSpawner(forGame: self)
    }

    func setup(forScene gameScene: GameScene) {
        self.gameScene = gameScene
        
        let midY = CGRectGetMidY(gameScene.frame)
        let midX = CGRectGetMidX(gameScene.frame)
        let offset: CGFloat = 15.0
        
        gameScene.backgroundColor = SKColor.lightGrayColor()
        
        let paddle_p1 = Paddle(forPlayer: .Red, withControl: .Human, position: CGPoint(x: offset, y: midY), color: SKColor.redColor())
        let paddle_p2 = Paddle(forPlayer: .Blue, withControl: .Cpu, position: CGPoint(x: gameScene.frame.width - offset, y: midY), color: SKColor.blueColor())
        
        let size = CGSize(width: gameScene.frame.width + 20, height: 4.0)
        let topY = gameScene.frame.height - size.height - 60
        
        let topWall = Wall(position: CGPoint(x: midX, y: topY), size: size, color: SKColor.purpleColor())
        let bottomWall = Wall(position: CGPoint(x: midX, y: size.height), size: size, color: SKColor.purpleColor())
        
        gameScene.physicsWorld.contactDelegate = self
        
        for entity in [paddle_p1, paddle_p2, topWall, bottomWall] {
            addEntity(entity)
        }

        configureBlockSpawnerForScene(gameScene, xOffset: 250, yOffset: 100)
        configureBallSpawnerForScene(gameScene, minAngle: 35, maxAngle: 135)
    }

    func movePaddle(direction: Direction, forPlayer player: Player) {
        guard let paddle = paddleForPlayer(player) else {
            return
        }
        
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
        guard let paddle = paddleForPlayer(player) else {
            return
        }
        
        let origin = CGPoint(x: paddle.position.x + 80, y: paddle.position.y)
        
        let beam = Beam(position: origin, color: SKColor.purpleColor())
        addEntity(beam)
        
        if let vc = beam.componentForClass(VisualComponent) {
            vc.sprite.physicsBody?.velocity = CGVector(dx: Constants.beamSpeed, dy: 0)
        }
    }
    
    func removeEntity(entity: Entity) {
        entitiesToRemove.append(entity)
    }

    func addEntity(entity: Entity) {
        entitiesToAdd.append(entity)
    }
    
    // The main update loop. Called every frame to update game state.
    func update(deltaTime: CFTimeInterval) {
        guard let gameScene = self.gameScene else {
            return
        }
        
        updateEntityLists()
        
        cpuControlSystem.updateWithDeltaTime(deltaTime)
        
        blockSpawner.updateWithDeltaTime(deltaTime)
        ballSpawner.updateWithDeltaTime(deltaTime)
        
        let balls: [Ball] = self.balls + self.tracerBalls
        for ball in balls {
            if let vc_ball = ball.componentForClass(VisualComponent) {
                let origin = vc_ball.sprite.position
                let dx = deltaTime * Double(ball.velocity.dx)
                let dy = deltaTime * Double(ball.velocity.dy)
                vc_ball.sprite.position = CGPoint(x: origin.x + CGFloat(dx), y: origin.y + CGFloat(dy))
                
                let ballFrame = vc_ball.sprite.frame
                
                if (CGRectGetMinX(ballFrame) > CGRectGetMaxX(gameScene.frame) ||
                    CGRectGetMaxX(ballFrame) < CGRectGetMinX(gameScene.frame)) {
                    removeEntity(ball)
                }
            }
        }
        
        for paddle in paddles {
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
            case is Paddle: paddles.remove(entity as! Paddle)
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
            case is Paddle: paddles.append(entity as! Paddle)
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
        if ball.dynamicType === Ball.self {
            ball.owner = paddle.player
        }
        
        let offset = ball.position.y + (Constants.paddleHeight / 2) - paddle.position.y
        let relativeOffset = fmax(fmin(offset / Constants.paddleHeight, 1), 0)        
        let angleOffset = GLKMathDegreesToRadians(20)
        let reflectAngle = GLKMathDegreesToRadians(140)
        
        var angle: CGFloat
        
        switch paddle.player {
        case .Blue:
            angle = relativeOffset * CGFloat(reflectAngle) + CGFloat(angleOffset) + CGFloat(M_PI)
        case .Red:
            angle = (1 - relativeOffset) * CGFloat(reflectAngle) + CGFloat(angleOffset)
        }
        
        updateBall(ball, angle: Float(angle), speed: ball.speed)

        ballSpawner.spawnTracerBallForBall(ball)
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
            if block.didTrigger == true {
                return
            }
            
            block.didTrigger = true
            
            guard let player = ball.owner else {
                return
            }

            if let paddle = paddleForPlayer(player) {
                switch block.power {
                case .Repair: paddle.repair()
                case .MultiBall:
                    ballSpawner.spawnBall(block.position)
                    ballSpawner.spawnBall(block.position)
                    ballSpawner.spawnBall(block.position)
                default: break
                }
            }
            
            removeEntity(block)
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
    
    private func configureBallSpawnerForScene(scene: SKScene, minAngle: Int, maxAngle: Int) {
        let midX = CGRectGetMidX(scene.frame)
        let midY = CGRectGetMidY(scene.frame)
        let origin = CGPoint(x: midX, y: midY)
        ballSpawner.configure(origin, minAngle: minAngle, maxAngle: maxAngle)
    }
    
    private func configureBlockSpawnerForScene(scene: SKScene, xOffset: Int, yOffset: Int) {
        let maxX = Int(scene.frame.size.width) - (xOffset * 2)
        let maxY = Int(scene.frame.size.height) - (yOffset * 2)
        blockSpawner.configure(xOffset ..< maxX, yRange: yOffset ..< maxY)
    }
    
    private func paddleForPlayer(player: Player) -> Paddle? {
        var paddle: Paddle?
        
        paddle = paddles.filter { testPaddle -> Bool in
            testPaddle.player == player
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