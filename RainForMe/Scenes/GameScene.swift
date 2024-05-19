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
	
	// Set sound effect for when Red is hit by Rain Drop
	let redIsHitSound = SKAction.playSoundFileNamed("bubble.wav", waitForCompletion: false)
	
	// Randomize rain drops and set interval
	private var currentRainDropSpawnTime : TimeInterval = 0
	private var rainDropSpawnRate : TimeInterval = 0.2
	private let random = GKARC4RandomSource()
	
	private let background = BackgroundSprite.newInstance()
	private let cloud = CloudSprite.newInstance()
	private var red : RedSprite!
	private var redspot : RedSpot!
	
	private let hud = HudNode()
	
	// Set Red to have 10 hit points
	private var redHitPointsNode : SKLabelNode!
	private var redHitPoints : Int = 10
	
	// So that Red doesn't move too close to the edge of the screen
	private let redMoveMargin : CGFloat = 70.0
	
	// Set Red's Hit Points
	func showHitPoints() {
		redHitPoints = 10
		
		redHitPointsNode = SKLabelNode(fontNamed: "NicoClean-Regular")
		redHitPointsNode.text = "\(redHitPoints)"
		redHitPointsNode.fontSize = 40
		redHitPointsNode.zPosition = 5
		
		addChild(redHitPointsNode)
	}
	
	// Call the rain
	func spawnRainDrop() {
		// Declare the rain
		let rainDrop = SKSpriteNode(imageNamed: "raindrop")
		rainDrop.physicsBody = SKPhysicsBody(rectangleOf: rainDrop.size)
		rainDrop.physicsBody?.categoryBitMask = RainDropCategory
		rainDrop.physicsBody?.contactTestBitMask = FloorCategory | RedSpotCategory
		rainDrop.zPosition = 2
		
		// Set raindrops to spawn from random position
		let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
		rainDrop.position = CGPoint(x: randomPosition, y: size.height)
		rainDrop.zPosition = 2
		
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
		red.position = CGPoint(x: frame.midX, y: frame.midY / 3)
		
		addChild(red)
		showHitPoints()
		
		hud.resetPoints()
	}
	
	// Determine the position for Red to move
	func whereToMove() {
		redspot = RedSpot.newInstance()
		var moveToPosition : CGFloat = CGFloat(random.nextInt())
		moveToPosition = moveToPosition.truncatingRemainder(dividingBy: size.width - redMoveMargin * 2)
		moveToPosition = CGFloat(abs(moveToPosition))
		moveToPosition += redMoveMargin
		redspot.position = CGPoint(x: moveToPosition, y: cloud.position.y / 4)
		
		addChild(redspot)
	}
	
	// If Cloud is hit
	func handleCloudCollision(contact: SKPhysicsContact) {
		var otherBody : SKPhysicsBody
		
		if(contact.bodyA.categoryBitMask == CloudCategory) {
			otherBody = contact.bodyB
		} else {
			otherBody = contact.bodyA
		}
		
		switch otherBody.categoryBitMask {
		case RainDropCategory:
//			print("Rain hit Cloud")
			hud.addPoint()
		default:
			print("Something hit Cloud")
		}
	}
	
	// If Red is hit
	func handleRedCollision(contact: SKPhysicsContact) {
		var otherBody : SKPhysicsBody
		
		if(contact.bodyA.categoryBitMask == RedCategory) {
			otherBody = contact.bodyB
		} else {
			otherBody = contact.bodyA
		}
		
		switch otherBody.categoryBitMask {
		case RainDropCategory:
//			print("Rain hit Red")
			self.run(redIsHitSound)
			redHitPoints -= 1
			redHitPointsNode.text = "\(redHitPoints)"
			
			if redHitPoints == 0 {
				hud.resetPoints()
				red.redIsFalling()
				
				let fallFrames = red.getFallFrames()
				let fallingDuration = TimeInterval(fallFrames.count) * 0.2
				let waitAction = SKAction.wait(forDuration: fallingDuration)
				let resetAction = SKAction.run {
					self.redHitPoints = 10
					self.redHitPointsNode.text = "\(self.redHitPoints)"
				}
				let sequenceAction = SKAction.sequence([waitAction, resetAction])
				red.run(sequenceAction)
			}
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
//			print("Red has arrived")
			red.redIsIdle()
			redSpotBody.node?.removeFromParent()
			redSpotBody.node?.physicsBody = nil
			whereToMove()
		case RainDropCategory:
//			print("Rain hit Red Spot")
			break
		default:
			print("Red hasn't arrived")
		}
	}

	override func sceneDidLoad() {
		self.lastUpdateTime = 0
		
		self.physicsWorld.contactDelegate = self
		
		// Add rain SFX
		let ambienceTrack = SoundManager.sharedInstance.startPlaying(soundName: "rain", fileExtension: "mp3")
		ambienceTrack?.volume = 0.3
		
		// Add HUD
		hud.setup(size: size)
		addChild(hud)
		
		// Declare the floor
		let floorNode = SKShapeNode(rectOf: CGSize(width: size.width, height: 5))
		floorNode.position = CGPoint(x: size.width / 2, y: 50)
		
		floorNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width / 2, y: 0), to: CGPoint(x: size.width, y: 0))
		
		// Put floor into FloorCategory and set its collision to RainDropCategory
		floorNode.physicsBody?.categoryBitMask = FloorCategory
		floorNode.physicsBody?.contactTestBitMask = RainDropCategory
		addChild(floorNode)

		background.size = CGSize(width: self.size.width, height: self.size.height)
		background.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(background)
		
		cloud.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(cloud)
		
		spawnRed()
		whereToMove()
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		// Set Rain Drop collision
		if (contact.bodyA.categoryBitMask == RainDropCategory) {
			contact.bodyA.node?.removeFromParent()
			contact.bodyA.node?.physicsBody = nil
		} else if (contact.bodyB.categoryBitMask == RainDropCategory) {
			contact.bodyB.node?.removeFromParent()
			contact.bodyB.node?.physicsBody = nil
		}
		
		// Check what collides with Red Spot
		if contact.bodyA.categoryBitMask == RedSpotCategory || contact.bodyB.categoryBitMask == RedSpotCategory {
			handleArrivedAtLocation(contact: contact)
			
			return
		}
		
		// Check what collides with Cloud
		if contact.bodyA.categoryBitMask == CloudCategory || contact.bodyB.categoryBitMask == CloudCategory {
			handleCloudCollision(contact: contact)
			
			return
		}
		
		// Check what collides with Red
		if contact.bodyA.categoryBitMask == RedCategory || contact.bodyB.categoryBitMask == RedCategory {
			handleRedCollision(contact: contact)
			
			return
		}
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
		  spawnRainDrop()
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
		
		// Update redHitPointsNode position to follow Red only if Red has moved
		if red.hasMoved {
			redHitPointsNode.position = CGPoint(x: red.position.x, y: red.position.y + 80)
		}
	}
}
