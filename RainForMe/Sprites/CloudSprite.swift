//
//  BriefcaseSprite.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 14/05/24.
//

import SpriteKit

public class CloudSprite : SKSpriteNode {
	private let cloudDemoKey = "action_cloud_demo"
	private let cloudRecoilKey = "action_cloud_recoil"
	
	public static func newInstance() -> CloudSprite {
		let cloud = CloudSprite(imageNamed: "cloud")
		let cloudSize = CGSize(width: cloud.size.width / 2, height: cloud.size.height / 2)
		cloud.size = cloudSize
		cloud.zPosition = 1
		
		cloud.physicsBody = SKPhysicsBody(rectangleOf: cloudSize)
		cloud.physicsBody?.isDynamic = false
		
		// Put Cloud into CloudCategory and set its collision to RainDropCategory
		cloud.physicsBody?.categoryBitMask = CloudCategory
		cloud.physicsBody?.contactTestBitMask = RainDropCategory
		
		return cloud
	}
	
	// Add scale up and scale down animation when Cloud is hit by Rain Drop
	public func cloudRecoilWhenHit() {
		if action(forKey: cloudRecoilKey) == nil {
			let scaleUpAction = SKAction.scale(to: 1.3, duration: 0.1)
			let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.1)
			let scaleSequence = SKAction.sequence([scaleUpAction, scaleDownAction])
			run(scaleSequence)
		}
	}
	
	// Animation for Cloud on TutorialScene
	public func cloudMoveTutorial() {
		if action(forKey: cloudDemoKey) == nil {
			let waitAction = SKAction.wait(forDuration: 0.5)
			let cloudMoveRight = SKAction.moveTo(x: frame.midX + 150, duration: 1.0)
			let cloudMoveLeft = SKAction.moveTo(x: frame.midX, duration: 1.0)
			let sequenceAction = SKAction.sequence([waitAction, cloudMoveRight, waitAction, cloudMoveLeft])
			let repeatAction = SKAction.repeatForever(sequenceAction)
			run(repeatAction, withKey: cloudDemoKey)
		}
	}
}
