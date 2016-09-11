//
//  BallSpawner.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 11/09/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import GameplayKit
import GLKit

class BallSpawner {
    weak var game: Game?

    private(set) var origin = CGPoint(x: 100, y: 100)
    private(set) var speed: Float = 650
    private(set) var randomAngleGenerator: GKRandomDistribution?

    init(forGame game: Game) {
        self.game = game
    }
    
    func configure(origin: CGPoint, minAngle: Int, maxAngle: Int) {
        assert(maxAngle > minAngle, "maxAngle should be larger than minAngle")
        
        self.origin = origin
        
        randomAngleGenerator = GKRandomDistribution(lowestValue: minAngle, highestValue: maxAngle)
    }
    
    func updateWithDeltaTime(deltaTime: CFTimeInterval) {
        guard let game = self.game else {
            return
        }
        
        let ballCount = game.balls.count
        
        if ballCount == 0 {
            spawnBall()
        }
    }
    
    func spawnBall() {
        guard let game = self.game else {
            return
        }

        let angle = randomAngleForCurrentPlayer()
        
        let velocity = velocityForAngle(angle, speed: self.speed)
        let ball = Ball(position: origin, velocity: velocity)
        game.addEntity(ball)

        spawnTracerBallForBall(ball)
    }
    
    func spawnTracerBallForBall(ball: Ball) {
        guard let game = self.game else {
            return
        }
        
        var velocity = ball.velocity
        let dx = Float(velocity.dx)
        let dy = Float(velocity.dy)
        
        let angle = atan2f(dx, dy)
        let speed = sqrtf(powf(dx, 2) + powf(dy, 2))
        
        velocity = velocityForAngle(angle, speed: speed + 50)
        let tracerBall = TracerBall(forBall: ball, position: ball.position, velocity: velocity)
        game.addEntity(tracerBall)
    }
    
    private func randomAngleForCurrentPlayer() -> Float {
        guard let game = self.game, let randomAngleGenerator = self.randomAngleGenerator else {
            return 0
        }
        
        let randomAngle = Float(randomAngleGenerator.nextInt())
        var angle = GLKMathDegreesToRadians(randomAngle)
        
        if game.nextPlayer == .Red {
            angle += Float(M_PI)
        }

        if game.nextPlayer == .Red {
            angle += Float(M_PI)
        }
        
        return angle
    }

    private func velocityForAngle(angle: Float, speed: Float) -> CGVector {
        let dy = cos(angle) * speed
        let dx = sin(angle) * speed
        let velocity = CGVector(dx: CGFloat(dx), dy: CGFloat(dy))

        return velocity
    }
}
