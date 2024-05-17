//
//  GameScene.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 14/05/24.
//

import SpriteKit
import CoreMotion
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	private var lastUpdateTime : TimeInterval = 0
	
	let motionManager = CMMotionManager()
	
	// Randomize rain drops and set interval
	private var currentRainDropSpawnTime : TimeInterval = 0
	private var rainDropSpawnRate : TimeInterval = 0.4
	private let random = GKARC4RandomSource()
	
	private let cloud = CloudSprite.newInstance()
	private var red : RedSprite!
	private var redspot : RedSpot!
	
	// So that Red doesn't move too close to the edge of the screen
	private let redMoveMargin : CGFloat = 50.0
	
	// Call the rain
	func spawnRaindrop() {
		// Declare the rain
		let rainDrop = SKShapeNode(rectOf: CGSize(width: 3, height: 30))
		rainDrop.position = CGPoint(x: size.width / 2, y:  size.height / 2)
		rainDrop.fillColor = SKColor.black
		rainDrop.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 3, height: 30))
		
		// Set raindrops to spawn from random position
		let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
		rainDrop.position = CGPoint(x: randomPosition, y: size.height)
		rainDrop.zPosition = 2
		
		// Put raindrop into RainDropCategory and set its collision to FloorCategory
		rainDrop.physicsBody?.categoryBitMask = RainDropCategory
		rainDrop.physicsBody?.contactTestBitMask = FloorCategory
		
		addChild(rainDrop)
	}
	
	// Call Red
	func spawnRed() {
		//Check if Red exists on screen
		if let currentRed = red, children.contains(currentRed) {
			red.removeFromParent()
			red.removeAllActions()
			red.physicsBody = nil
		}
		
		red = RedSprite.newInstance()
		red.position = CGPoint(x: cloud.position.x, y: cloud.position.y / 3)
		
		addChild(red)
	}
	
	// Determine the position for Red to move
	func whereToMove() {
		redspot = RedSpot.newInstance()
		var moveToPosition : CGFloat = CGFloat(random.nextInt())
		moveToPosition = moveToPosition.truncatingRemainder(dividingBy: size.width - redMoveMargin * 2)
		moveToPosition = CGFloat(abs(moveToPosition))
		moveToPosition += redMoveMargin
		redspot.position = CGPoint(x: moveToPosition, y: cloud.position.y / 3)
		
		addChild(redspot)
	}
	
	// Check raindrop collision
	func didBegin(_ contact: SKPhysicsContact) {
		if (contact.bodyA.categoryBitMask == RainDropCategory) {
			contact.bodyA.node?.removeFromParent()
			contact.bodyA.node?.physicsBody = nil
			contact.bodyA.node?.removeAllActions()
		} else if (contact.bodyB.categoryBitMask == RainDropCategory) {
			contact.bodyB.node?.removeFromParent()
			contact.bodyB.node?.physicsBody = nil
			contact.bodyB.node?.removeAllActions()
		}
		
		// Check what collides with Red Spot
		if contact.bodyA.categoryBitMask == RedSpotCategory || contact.bodyB.categoryBitMask == RedSpotCategory {
		  handleArrivedAtLocation(contact: contact)
			
		  return
		}
		
		// Check what collides with Red
		if contact.bodyA.categoryBitMask == RedCategory || contact.bodyB.categoryBitMask == RedCategory {
			handleRedCollision(contact: contact)

			return
		}
	}
	
	// If Red is hit
	func handleRedCollision(contact: SKPhysicsContact) {
	  var otherBody : SKPhysicsBody

	  if contact.bodyA.categoryBitMask == RedCategory {
		otherBody = contact.bodyB
	  } else {
		otherBody = contact.bodyA
	  }

	  switch otherBody.categoryBitMask {
	  case RainDropCategory:
		  print("Rain hit Red")
	  default:
		  print("Something hit Red")
	  }
	}
	
	// If Red Spot is hit
	func handleArrivedAtLocation(contact: SKPhysicsContact) {
		var otherBody : SKPhysicsBody
		var redSpotBody : SKPhysicsBody
		
		if(contact.bodyA.categoryBitMask == RedSpotCategory) {
			otherBody = contact.bodyB
			redSpotBody = contact.bodyA
		} else {
			otherBody = contact.bodyA
			redSpotBody = contact.bodyB
		}
		
		switch otherBody.categoryBitMask {
		case RedCategory:
			print("Red has arrived")
			red.redIsIdle()
			fallthrough
		case FloorCategory:
			redSpotBody.node?.removeFromParent()
			redSpotBody.node?.physicsBody = nil
			contact.bodyA.node?.removeAllActions()
			whereToMove()
		default:
			print("Red hasn't arrived")
		}
	}

	override func sceneDidLoad() {
		self.lastUpdateTime = 0
		
		self.physicsWorld.contactDelegate = self
		
		// Declare the floor
		let floorNode = SKShapeNode(rectOf: CGSize(width: size.width, height: 5))
		floorNode.position = CGPoint(x: size.width / 2, y: 50)
		
		floorNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width / 2, y: 0), to: CGPoint(x: size.width, y: 0))
		
		// Put floor into FloorCategory and set its collision to RainDropCategory
		floorNode.physicsBody?.categoryBitMask = FloorCategory
		floorNode.physicsBody?.contactTestBitMask = RainDropCategory
		
		addChild(floorNode)
		
		// Declare background
		let background = SKSpriteNode(imageNamed: "background")
		background.position = CGPoint(x: frame.midX, y: frame.midY)
		background.zPosition = 0
		background.size = CGSize(width: self.size.width, height: self.size.height)

		addChild(background)
		
		cloud.position = CGPoint(x: frame.midX, y: frame.midY)
		
		addChild(cloud)
		
		spawnRed()
		whereToMove()
	}
	
	override func didMove(to view: SKView) {
		// Start accelerometer updates
		if motionManager.isAccelerometerAvailable {
			motionManager.startAccelerometerUpdates()
		}
	}
	
	override func willMove(from view: SKView) {
		// Stop accelerometer updates
		motionManager.stopAccelerometerUpdates()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
	}

	override func update(_ currentTime: TimeInterval) {
		// Initialize _lastUpdateTime if it has not already been
		if (self.lastUpdateTime == 0) {
			self.lastUpdateTime = currentTime
		}

		// Calculate time since last update
		let dt = currentTime - self.lastUpdateTime
		self.lastUpdateTime = currentTime
		
		// Update the Spawn Timer
		currentRainDropSpawnTime += dt

		if currentRainDropSpawnTime > rainDropSpawnRate {
		  currentRainDropSpawnTime = 0
		  spawnRaindrop()
		}
		
		if let accelerometerData = motionManager.accelerometerData {
			// Adjust sensitivity
			let accelerationY = accelerometerData.acceleration.y
			
			// Apply the accelerometer data to move the sprite
			let speed: CGFloat = 20.0
			let deltaY = CGFloat(accelerationY) * speed
			
			// Move cloud's x position in reverse according to y accelerometer data
			if accelerationY < 0 {
				// Move right when tilted right
				cloud.position.x += abs(deltaY)
			} else {
				// Move left when tilted left
				cloud.position.x -= abs(deltaY)
			}
			
			// Prevent cloud from going out of screen bounds
			let minX = cloud.size.width / 2
			let maxX = size.width - cloud.size.width / 2
			cloud.position.x = max(minX, min(maxX, cloud.position.x))
		}
		// Make Red move to Red Spot position
		red.update(deltaTime: dt, moveLocation: redspot.position)
	}
}
