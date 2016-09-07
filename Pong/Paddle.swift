 //
//  Paddle.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Paddle : Entity {
    private var holeRects = [CGRect]()
    
    init(position: CGPoint, color: SKColor) {
        super.init()
        
        self.speed = Constants.paddleSpeed
        
        let shape = paddleShapeWithColor(color)
        
        let sprite = SpriteNode(texture: shape.texture)
        sprite.entity = self
        sprite.position = position
        
        let vc = VisualComponent(sprite: sprite)
        vc.sprite.zPosition = EntityLayer.Paddle.rawValue
        addComponent(vc)
        
        vc.sprite.physicsBody = SKPhysicsBody(rectangleOfSize: shape.frame.size)
        vc.sprite.physicsBody?.categoryBitMask = EntityCategory.Paddle
        vc.sprite.physicsBody?.contactTestBitMask = EntityCategory.Wall
        vc.sprite.physicsBody?.collisionBitMask = EntityCategory.Nothing
    }
    
    func addHole(y: CGFloat, height: CGFloat) {
        let y = Constants.paddleHeight - y
        
        let rect = CGRect(x: 0, y: y, width: Constants.paddleWidth, height: height)
        if holeRects.contains(rect) {
            return
        } else {
            holeRects.removeAll()
            holeRects.append(rect)
        }
        
        let hole_y1 = y - height / 2
        let hole_y2 = y + height / 2
        
        print("\naddHole -> y: \(y) height: \(height)\n")

        var paddleRects = [CGRect]()
        
        let h1 = Constants.paddleHeight - hole_y2
        let y1 = (Constants.paddleHeight - h1) / 2
        let rect1 = CGRect(x: 0, y: y1, width: Constants.paddleWidth, height: h1)
        paddleRects.append(rect1)

        let h2 = hole_y1
        let y2: CGFloat = -(Constants.paddleHeight - h2) / 2
        let rect2 = CGRect(x: 0, y: y2, width: Constants.paddleWidth, height: h2)
        paddleRects.append(rect2)
        
        guard let vc = componentForClass(VisualComponent) else {
            return
        }
        
        vc.sprite.removeAllChildren()

        let shape = paddleShapeWithColor(SKColor.yellowColor())
        let sprite = SpriteNode(texture: shape.texture)
        vc.replaceSprite(sprite)
        vc.sprite.physicsBody = nil
        
        for rect in paddleRects {
            print("\(rect)")
            let shape = paddleShapeWithColor(SKColor.blueColor(), size: rect.size)
            let sprite = SpriteNode(texture: shape.texture)
            sprite.zPosition = EntityLayer.PaddleFragment.rawValue
            sprite.position = rect.origin
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: shape.frame.size)
            sprite.physicsBody?.categoryBitMask = EntityCategory.Paddle
            sprite.physicsBody?.contactTestBitMask = EntityCategory.Wall
            sprite.physicsBody?.collisionBitMask = EntityCategory.Nothing
            vc.sprite.addChild(sprite)
        }
    }
    
    private func paddleShapeWithColor(color: SKColor, size: CGSize) -> SKShapeNode {
        var shape: SKShapeNode
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let path = CGPathCreateWithRect(rect, nil)
        shape = SKShapeNode(path: path, centered: true)
        shape.fillColor = color
        shape.strokeColor = color
        
        return shape
    }

    
    private func paddleShapeWithColor(color: SKColor) -> SKShapeNode {
        let size = CGSize(width: Constants.paddleWidth, height: Constants.paddleHeight)
        return paddleShapeWithColor(color, size: size)
    }
}