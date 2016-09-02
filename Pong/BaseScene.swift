//
//  BaseScene.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 30/08/16.
//  Copyright © 2016 Wolftrail. All rights reserved.
//

import SpriteKit

class BaseScene : SKScene {

    override init(size: CGSize) {
        super.init(size: size)

        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        name = NSStringFromClass(self.dynamicType)
    }

    
    override func keyDown(theEvent: NSEvent) {
        if let playerAction = playerActionForKeyCode(theEvent.keyCode) {
            switch playerAction.action {
            case .Action: handleActionPress(forPlayer: playerAction.player)
            case .Up: handleUpPress(forPlayer: playerAction.player)
            case .Down: handleDownPress(forPlayer: playerAction.player)
            case .Pause: handlePausePress(forPlayer: playerAction.player)
            default: break
            }
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        if let playerAction = playerActionForKeyCode(theEvent.keyCode) {
            switch playerAction.action {
            case .Action: handleActionRelease(forPlayer: playerAction.player)
            case .Up: handleUpRelease(forPlayer: playerAction.player)
            case .Down: handleDownRelease(forPlayer: playerAction.player)
            case .Pause: handlePausePress(forPlayer: playerAction.player)
            default: break
            }
        }
    }
    
    // MARK: - Public
    
    // Subclasses can override the following methods appropriate for the scene. E.g. in game can
    //  move character up and down. In menu navigate through menu options.
    
    func handlePausePress(forPlayer player: Player) {
    }
    
    func handleUpPress(forPlayer player: Player) {
    }
    
    func handleUpRelease(forPlayer player: Player) {
    }
    
    func handleDownPress(forPlayer player: Player) {
    }
    
    func handleDownRelease(forPlayer player: Player) {
    }
    
    func handleLeftPress(forPlayer player: Player) {
    }
    
    func handleLeftRelease(forPlayer player: Player) {
    }
    
    func handleRightPress(forPlayer player: Player) {
    }
    
    func handleRightRelease(forPlayer player: Player) {
    }
    
    func handleActionPress(forPlayer player: Player) {
    }
    
    func handleActionRelease(forPlayer player: Player) {
    }
    
    // MARK: - Private
    
    private func playerActionForKeyCode(keyCode: UInt16) -> (player: Player, action: Action)? {
        var result: (Player, Action)?
        
        switch keyCode {
        // Player 1
        case 53: result = (.Blue, .Pause)
        case 125: result = (.Blue, .Down)
        case 126: result = (.Blue, .Up)
            
        // Player 2
        case 1: result = (.Red, .Down)
        case 13: result = (.Red, .Up)
        case 49: result = (.Red, .Action)
        default: break
        }
        
        return result
    }

}