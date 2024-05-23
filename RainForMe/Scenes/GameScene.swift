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
	private var rainDropSpawnRate : TimeInterval = 1.5
	private var spawnRateAdditionTimer: TimeInterval = 0
	
	private let random = GKARC4RandomSource()
	
	private let background = BackgroundSprite.newInstance()
	private let cloud = CloudSprite.newInstance()
	
	private var red : RedSprite!
	private var redspot : RedSpotSprite!
	private var raindrop : RainDropSprite!
	private var redheart : HeartSprite!
	
	// Set HUD for displaying score and high score
	private let hud = HudNode()
	
	// Set 10 hit points for Red
	private var redHitPointsNode : SKLabelNode!
	private var redHitPoints : Int = 10
	
	// So that Red doesn't move too close to the edge of the screen
	private let redMoveMargin : CGFloat = 100.0
	
	// Set Red's Hit Points
	func showHitPoints() {
		redHitPoints = 10
		
		redHitPointsNode = SKLabelNode(fontNamed: "NicoClean-Regular")
		redHitPointsNode.text = "\(redHitPoints)"
		redHitPointsNode.fontSize = 40
		redHitPointsNode.zPosition = 5
		addChild(redHitPointsNode)
		
		redheart = HeartSprite.newInstance()
		addChild(redheart)
	}
	
	// Call the rain
	func spawnRainDrop() {
		// Declare the rain
		raindrop = RainDropSprite.newInstance()
		
		// Set raindrops to spawn from random position
		let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
		raindrop.position = CGPoint(x: randomPosition, y: size.height)
		raindrop.zPosition = 2
		
		addChild(raindrop)
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
		red.redIsIdle()
		showHitPoints()
		
		// Reset score
		hud.resetPoints()
	}
	
	// Determine the position for Red to move
	func whereToMove() {
		redspot = RedSpotSprite.newInstance()
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
			cloud.cloudRecoil()
			
			// Add score + 1 when cloud is hit
			hud.addPoint()
		default:
			break
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
			self.run(redIsHitSound)
			redheart.redHeartRecoil()
			redHitPoints -= 1
			redHitPointsNode.text = "\(redHitPoints)"
			
			if redHitPoints == 0 {
				hud.resetPoints()
				red.redIsFalling()
				
				// Wait until falling animation is complete, then update Red's Hit Points to 10 and display it
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
			break
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
			red.redIsIdle()
			redSpotBody.node?.removeFromParent()
			redSpotBody.node?.physicsBody = nil
			whereToMove()
		case RainDropCategory:
			fallthrough
		default:
			break
		}
	}

	override func sceneDidLoad() {
		self.lastUpdateTime = 0
		
		self.physicsWorld.contactDelegate = self
		
		// Add HUD
		hud.setup(size: size)
		addChild(hud)
		
		// Declare leaf particles
		if let leafParticles = SKEmitterNode(fileNamed: "LeafParticles") {
			leafParticles.position = CGPoint(x: frame.maxX, y: frame.midY)
			leafParticles.zPosition = 4
			addChild(leafParticles)
		}
		
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
			motionManager.accelerometerUpdateInterval = 0.1
			motionManager.startAccelerometerUpdates()
		}
		
		// Add rain sound
		let ambienceTrack = SoundManager.sharedInstance.startPlaying(soundName: "rain", fileExtension: "mp3")
		ambienceTrack?.volume = 0.3
		
		// Tell Red where to move
		whereToMove()
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
		
		// Gradually increase the spawn rate over 10 seconds
		spawnRateAdditionTimer += dt
		if spawnRateAdditionTimer >= 10 {
			// Gradually increase the spawn rate by 0.1
			let rateAdditionSpeed: Double = 0.1
			rainDropSpawnRate -= rateAdditionSpeed * dt

			// Ensure the spawn rate doesn't go below 0.3
			rainDropSpawnRate = max(0.3, rainDropSpawnRate)
		}
		
		if let accelerometerData = motionManager.accelerometerData {
			// Adjust sensitivity
			let accelerationY = accelerometerData.acceleration.y
			
			// Apply the accelerometer data to move Cloud
			let speed: CGFloat = 20.0
			let deltaY = CGFloat(accelerationY) * speed
			
			// Move Cloud's x position in reverse according to y accelerometer data
			if accelerationY < 0 {
				// Move right when tilted right
				cloud.position.x += abs(deltaY)
			} else {
				// Move left when tilted left
				cloud.position.x -= abs(deltaY)
			}
			
			// Prevent Cloud from going out of screen bounds
			let minX = cloud.size.width / 2
			let maxX = size.width - cloud.size.width / 2
			cloud.position.x = max(minX, min(maxX, cloud.position.x))
		}
		// Make Red move to Red Spot position
		red.update(deltaTime: dt, moveLocation: redspot.position)
		
		// Update Red's Hit Points and Red's Heart position to follow Red only if Red has moved
		if red.hasMoved {
			redHitPointsNode.position = CGPoint(x: red.position.x + 25, y: red.position.y + 80)
			redheart.position = CGPoint(x: redHitPointsNode.position.x - redHitPointsNode.frame.width / 2 - 30, y: redHitPointsNode.position.y + 15)
		}
	}
	
	
}
