//
//  EntityCategory.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import Foundation

// zPositions of entities.
enum EntityLayer : CGFloat {
    case Wall = 1
    case Ball
    case Paddle
    case PaddleFragment
    case Beam = 1000
}

struct EntityCategory {
    static let Nothing:     UInt32 = 0
    static let Ball:        UInt32 = 0b1
    static let Paddle:      UInt32 = 0b10
    static let Wall:        UInt32 = 0b100
    static let Beam:        UInt32 = 0b1000
}

struct Constants {
    static let paddleHeight: CGFloat = 200
    static let paddleWidth: CGFloat = 15
    
    static let paddleSpeed: Float = 380
    static let ballSpeed: Float = 650
    static let beamHeight: CGFloat = 30
}

enum Direction: Int {
    case Down = -1
    case None = 0
    case Up = 1
}

enum Player {
    case Red
    case Blue
}

enum Action: Int {
    case None
    case Up
    case Down
    case Action
    case Pause
}
