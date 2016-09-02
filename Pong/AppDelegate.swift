//
//  AppDelegate.swift
//  Pong
//
//  Created by Wolfgang Schreurs on 28/08/16.
//  Copyright (c) 2016 Wolftrail. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /* Pick a size for the scene */
        let scene = GameScene(size: CGSize(width: 1280, height: 960))
        scene.scaleMode = .AspectFit
        scene.physicsWorld.gravity = CGVector()
        
        if let skView = self.skView {
            skView.presentScene(scene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsDrawCount = true
            skView.showsNodeCount = true
            skView.showsPhysics = false
            skView.asynchronous = false
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
