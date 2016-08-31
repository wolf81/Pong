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

enum Direction {
    case Up
    case Down
    case None
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
