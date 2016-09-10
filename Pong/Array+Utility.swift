//
//  Array+Utility.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 10/09/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    mutating func remove(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}