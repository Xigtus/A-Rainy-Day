//
//  BriefcaseSprite.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 14/05/24.
//

import SpriteKit

public class CloudSprite : SKSpriteNode {
	public static func newInstance() -> CloudSprite {
		let cloud = CloudSprite(imageNamed: "cloud")
		let cloudSize = CGSize(width: cloud.size.width / 2, height: cloud.size.height / 2)
		cloud.size = cloudSize
		cloud.zPosition = 5
		
		cloud.physicsBody = SKPhysicsBody(rectangleOf: cloudSize)
		cloud.physicsBody?.isDynamic = false
		
		// Put Cloud into CloudCategory and set its collision to RainDropCategory
		cloud.physicsBody?.categoryBitMask = CloudCategory
		cloud.physicsBody?.contactTestBitMask = RainDropCategory
		
		return cloud
	}
}
