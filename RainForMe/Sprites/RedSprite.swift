//
//  ManSprite.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 16/05/24.
//

import SpriteKit

public class RedSprite : SKSpriteNode {
	// Set Red's movement speed
	private let movementSpeed : CGFloat = 180
	
	private let runningActionKey = "action_running"
	private let idleActionKey = "action_idle"
	private let fallingActionKey = "action_falling"
	
	private var idleTime : TimeInterval = 4
	private let maxIdleTime : TimeInterval = 4
	
	// Add properties to track movement
	public var hasMoved: Bool = false
	private var previousPosition: CGPoint = .zero
	
	// Frames for idle action
	private let idleFrames: [SKTexture] = (0...1).flatMap { i in
		// When sprite is red_idle0, display the sprite 4 times. Otherwise display twice
		Array(repeating: SKTexture(imageNamed: "red_idle\(i)"), count: i == 0 ? 4 : 2)
	}
	
	// Frames for run action
	private let runFrames: [SKTexture] = (0...7).map {
		SKTexture(imageNamed: "red_run\($0)")
	}
	
	// Frames for fall action
	private let fallFrames: [SKTexture] = (0...7).flatMap { i in
		// When sprite is red_fall7, display the sprite 12 times. Otherwise display once
		Array(repeating: SKTexture(imageNamed: "red_fall\(i)"), count: i == 7 ? 12 : 1)
	}
	
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
	
	// Function to get FallFrames on GameScene class
	public func getFallFrames() -> [SKTexture] {
		return fallFrames
	}
	
	// Check if physicsbody for Red is nil. Otherwise, give physicsbody to Red
	private func setupPhysicsBody() {
		if physicsBody == nil {
			physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width / 2, height: size.height))
			physicsBody?.isDynamic = false
			
			// Put Red into RedCategory and set it's collision to RainDropCategory and RedSpotCategory
			physicsBody?.categoryBitMask = RedCategory
			physicsBody?.contactTestBitMask = RainDropCategory | RedSpotCategory
		}
	}
	
	// Idle action for Red
	public func redIsIdle() {
		idleTime = TimeInterval.random(in: 2.0...4.0)
		removeAction(forKey: runningActionKey)
		removeAction(forKey: fallingActionKey)
		if action(forKey: idleActionKey) == nil {
			let idleAnimationAction = SKAction.repeatForever(
				SKAction.animate(with: idleFrames, timePerFrame: 0.2, resize: false, restore: true))
			run(idleAnimationAction, withKey: idleActionKey)
		}
		
		setupPhysicsBody()
	}
	
	// Running action for Red
	public func redIsRunning() {
		removeAction(forKey: idleActionKey)
		removeAction(forKey: fallingActionKey)
		if action(forKey: runningActionKey) == nil {
			let runningAnimationAction = SKAction.repeatForever(
				SKAction.animate(with: runFrames, timePerFrame: 0.1, resize: false, restore: true))
			run(runningAnimationAction, withKey: runningActionKey)
		}
		
		setupPhysicsBody()
	}
	
	// Falling action for Red
	public func redIsFalling() {
		removeAction(forKey: idleActionKey)
		removeAction(forKey: runningActionKey)
		if action(forKey: fallingActionKey) == nil {
			let fallingAnimationAction = SKAction.animate(with: fallFrames, timePerFrame: 0.2, resize: false, restore: true)
			run(fallingAnimationAction, withKey: fallingActionKey)
		}
		
		physicsBody = nil
	}
	
	public func update(deltaTime : TimeInterval, moveLocation: CGPoint) {
		idleTime += deltaTime
		
		// Check if Red is falling. Otherwise if Red has been idle, tell Red to run
		if action(forKey: fallingActionKey) != nil {
			return
		} else {
			if idleTime >= maxIdleTime {
				redIsRunning()
				
				// Set how Red will move
				// If moveLocation is less than Red's x position, Red face left and move left. Otherwise, Red face right and move right
				let moveDirection: CGFloat = moveLocation.x < position.x ? -1 : 1
				position.x += moveDirection * movementSpeed * CGFloat(deltaTime)
				xScale = moveDirection
			}
		}
		
		// Check if Red has moved
		hasMoved = position != previousPosition
		previousPosition = position
	}
}
