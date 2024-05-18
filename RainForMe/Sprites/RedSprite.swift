//
//  ManSprite.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 16/05/24.
//

import Foundation
import SpriteKit

public class RedSprite : SKSpriteNode {
	// Set Red's movement speed
	private let movementSpeed : CGFloat = 170
	private let runningActionKey = "action_running"
	private let idleActionKey = "action_idle"
	
	private var idleTime : TimeInterval = 4
	private let maxIdleTime : TimeInterval = 4
	
	private let idleFrames = [
		SKTexture(imageNamed: "red_idle0"),
		SKTexture(imageNamed: "red_idle1"),
		SKTexture(imageNamed: "red_idle2"),
		SKTexture(imageNamed: "red_idle3"),
		SKTexture(imageNamed: "red_idle4"),
		SKTexture(imageNamed: "red_idle5"),
		SKTexture(imageNamed: "red_idle6"),
		SKTexture(imageNamed: "red_idle7"),
		SKTexture(imageNamed: "red_idle8")
	]
	
	private let runFrames = [
		SKTexture(imageNamed: "red_run0"),
		SKTexture(imageNamed: "red_run1"),
		SKTexture(imageNamed: "red_run2"),
		SKTexture(imageNamed: "red_run3"),
		SKTexture(imageNamed: "red_run4"),
		SKTexture(imageNamed: "red_run5"),
		SKTexture(imageNamed: "red_run6"),
		SKTexture(imageNamed: "red_run7")
	]
	
	public static func newInstance() -> RedSprite {
		let redSprite = RedSprite(imageNamed: "red_normal")
		redSprite.zPosition = 3
		
		let redSpriteSize = CGSize(width: redSprite.size.width / 2, height: redSprite.size.height / 2)
		redSprite.size = redSpriteSize
		
		redSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: redSprite.size.width / 2, height: redSprite.size.height))
		redSprite.physicsBody?.isDynamic = false
		
		// Put Red into RedCategory and set its collision to RainDropCategory and RedSpotCategory
		redSprite.physicsBody?.categoryBitMask = RedCategory
		redSprite.physicsBody?.contactTestBitMask = RainDropCategory | RedSpotCategory
		
		return redSprite
	}
	
	public func redIsIdle() {
		idleTime = TimeInterval.random(in: 1.0...4.0)
		removeAction(forKey: runningActionKey)
		let idleAnimationAction = SKAction.repeatForever(
			SKAction.animate(with: idleFrames, timePerFrame: 0.2, resize: false, restore: true))
		run(idleAnimationAction, withKey: idleActionKey)
	}
	
	public func redIsRunning() {
		removeAction(forKey: idleActionKey)
		if action(forKey: runningActionKey) == nil {
			let runningAnimationAction = SKAction.repeatForever(
				SKAction.animate(with: runFrames, timePerFrame: 0.1, resize: false, restore: true))
			run(runningAnimationAction, withKey: runningActionKey)
		}
	}
	
	public func update(deltaTime : TimeInterval, moveLocation: CGPoint) {
		idleTime += deltaTime
		
		if idleTime >= maxIdleTime {
			redIsRunning()
			
			// Set how Red will move
			if moveLocation.x < position.x {
				// Red move left
				position.x -= movementSpeed * CGFloat(deltaTime)
				// Rotate Red to face left
				xScale = -1
			} else {
				// Red move right
				position.x += movementSpeed * CGFloat(deltaTime)
				// Rotate Red to face right
				xScale = 1
			}
		}
	}
}
