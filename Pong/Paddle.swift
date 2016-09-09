 //
//  Paddle.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class Paddle : Entity {
    var paddleRepr = [Int]()
    
//    private var holeRanges = [Range<Int>]()
    
    init(control: Control, position: CGPoint, color: SKColor) {
        super.init()
        
        for _ in 0 ..< Int(Constants.paddleHeight) {
            paddleRepr.append(1)
        }
        
        if control == .Cpu {
            let controlComponent = CpuControlComponent(paddle: self)
            addComponent(controlComponent)
        }
        
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
        
        // STEP 1: Create hole ranges
        //          => hole range intersects existing hole range:
        //              - y: create union
        //              - n: create new hole range
        // STEP 2: Convert hole ranges into paddle ranges
        //          => more or less the inverse when taking into account paddle frame
        // STEP 3: Create sprites for paddle fragments
        
        let hole_y1 = fmin(fmax(y - height / 2, 0), Constants.paddleHeight)
        let hole_y2 = fmax(fmin(y + height / 2, Constants.paddleHeight), 0)

        for i in Int(hole_y1) ..< Int(hole_y2) {
            paddleRepr[i] = 0
        }
        
        var paddleRanges = [Range<Int>]()
        
        var y1 = 0
        var y2 = 0
        var buildPaddleRect = paddleRepr[0] == 1
        for (idx, i) in paddleRepr.enumerate() {
            switch i {
            case 0:
                if buildPaddleRect {
                    buildPaddleRect = false
                    y2 = idx
                    paddleRanges.append(y1 ..< y2)
                }
            default:
                if !buildPaddleRect {
                    buildPaddleRect = true
                    y1 = idx
                }
            }
        }
        
        if paddleRepr[paddleRepr.count - 1] == 1 {
            paddleRanges.append(y1 ..< paddleRepr.count)
        }
        
        var paddleRects = [CGRect]()
        
        let w = Int(Constants.paddleWidth)
        let h = Int(Constants.paddleHeight)
        for range in paddleRanges {
            let h1 = range.endIndex - range.startIndex
            let y1 = range.startIndex + h1 / 2 - (h / 2)
            let rect = CGRect(x: 0, y: y1, width: w, height: h1)
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