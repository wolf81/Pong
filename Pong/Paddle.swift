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
        
        let rect = CGRect(x: 0, y: 0, width: Constants.paddleWidth, height: Constants.paddleHeight)
        let path = CGPathCreateWithRect(rect, nil)
        let shape = SKShapeNode(path: path, centered: true)
        shape.fillColor = color
        shape.strokeColor = color
        
        let sprite = SpriteNode(texture: shape.texture)
        sprite.entity = self
        sprite.position = position
        
        let vc = VisualComponent(sprite: sprite)
        vc.sprite.zPosition = EntityLayer.Paddle.rawValue
        addComponent(vc)
        
        vc.sprite.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        vc.sprite.physicsBody?.categoryBitMask = EntityCategory.Paddle
        vc.sprite.physicsBody?.contactTestBitMask = EntityCategory.Wall
        vc.sprite.physicsBody?.collisionBitMask = EntityCategory.Nothing
    }
    
    func addHole(rect: CGRect) {
        holeRects.removeAll()
        holeRects.append(rect)
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, Constants.paddleWidth, 0)
        CGPathAddLineToPoint(path, nil, Constants.paddleWidth, Constants.paddleHeight)
        CGPathAddLineToPoint(path, nil, 0, Constants.paddleHeight)
        CGPathCloseSubpath(path)
        
        let shape = SKShapeNode(path: path, centered: true)
        shape.fillColor = SKColor.orangeColor()
        shape.strokeColor = SKColor.grayColor()
        
        let sprite = SpriteNode(texture: shape.texture)
        sprite.entity = self
        sprite.position = position

        
        guard let oldVc = componentForClass(VisualComponent),
            let gameScene = oldVc.sprite.parent as? GameScene else {
                return
        }
        
        let vc = VisualComponent(sprite: sprite)
        
        vc.sprite.zPosition = EntityLayer.Paddle.rawValue
        addComponent(vc)

        vc.sprite.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        vc.sprite.physicsBody?.categoryBitMask = EntityCategory.Paddle
        vc.sprite.physicsBody?.contactTestBitMask = EntityCategory.Wall
        vc.sprite.physicsBody?.collisionBitMask = EntityCategory.Nothing
        
        
        oldVc.sprite.removeFromParent()
        gameScene.addChild(vc.sprite)
        
//        let y: CGFloat = fmin(fmax(rect.origin.y, 0), Constants.paddleHeight)
//        var newHoleRect = CGRectMake(0, y, Constants.paddleWidth, rect.height)
//        
//        var newHoleRects = [CGRect]()
//        
//        for holeRect in holeRects {
//            if CGRectIntersectsRect(holeRect, newHoleRect) {
//                newHoleRect = CGRectUnion(holeRect, newHoleRect)
//            } else {
//                newHoleRects.append(holeRect)
//            }
//        }
//
//        newHoleRects.append(newHoleRect)
//
//        newHoleRects = newHoleRects.sort({ $0.origin.y < $1.origin.y })
//        
//        holeRects = newHoleRects
        
        print("\(holeRects.count):\n \(holeRects)")
    }
}