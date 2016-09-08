 //
//  Paddle.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Paddle : Entity {
    private var paddleRanges = [Range<Int>]()
    
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

        let hole_y1 = fmin(fmax(y - height / 2, 0), Constants.paddleHeight)
        let hole_y2 = fmax(fmin(y + height / 2, Constants.paddleHeight), 0)

        paddleRanges.removeAll()
        
        if hole_y1 == 0 {
            paddleRanges.append(Int(hole_y2) ..< Int(Constants.paddleHeight))
        } else if hole_y2 == Constants.paddleHeight {
            paddleRanges.append(Int(0) ... Int(hole_y1))
        } else {
            paddleRanges.append(Int(0) ... Int(hole_y1))
            paddleRanges.append(Int(hole_y2) ..< Int(Constants.paddleHeight))
        }

        print("\n")
        for range in paddleRanges {
            print("range: \(range)")
        }
        
        var paddleRects = [CGRect]()
        
        for range in paddleRanges {
            let h1 = range.endIndex - range.startIndex
            let y1 = range.startIndex + h1 / 2 - (Int(Constants.paddleHeight) / 2)
            let rect = CGRect(x: 0, y: y1, width: Int(Constants.paddleWidth), height: h1)
            paddleRects.append(rect)
        }
        
        guard let vc = componentForClass(VisualComponent) else {
            return
        }
        
        vc.sprite.removeAllChildren()

        let shape = paddleShapeWithColor(SKColor.clearColor())
        let sprite = SpriteNode(texture: shape.texture)
        vc.replaceSprite(sprite)

        var pBodies = [SKPhysicsBody]()
        for rect in paddleRects {
            let shape = paddleShapeWithColor(SKColor.blueColor(), size: rect.size)
            let sprite = SpriteNode(texture: shape.texture)
            sprite.zPosition = EntityLayer.PaddleFragment.rawValue
            sprite.position = rect.origin

            vc.sprite.addChild(sprite)
            
            let pBody = SKPhysicsBody(rectangleOfSize: shape.frame.size, center: rect.origin)
            pBodies.append(pBody)
        }
        
        let pBody = SKPhysicsBody(bodies: pBodies)
        pBody.collisionBitMask = EntityCategory.Nothing
        pBody.contactTestBitMask = EntityCategory.Wall
        pBody.categoryBitMask = EntityCategory.Paddle

        vc.sprite.physicsBody = pBody
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