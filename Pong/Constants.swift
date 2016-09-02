//
//  EntityCategory.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import Foundation

struct EntityCategory {
    static let Nothing:     UInt32 = 0
    static let Ball:        UInt32 = 0b1
    static let Paddle:      UInt32 = 0b10
    static let Wall:        UInt32 = 0b100
}

struct Constants {
    static let paddleHeight: CGFloat = 100
    static let paddleSpeed: Float = 380
    static let ballSpeed: Float = 650
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
