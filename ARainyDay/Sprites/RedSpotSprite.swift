//
//  MoveRed.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 16/05/24.
//

import SpriteKit

public class RedSpotSprite : SKSpriteNode {
	public static func newInstance() -> RedSpotSprite {
		let redSpot = RedSpotSprite(imageNamed: "redspot")
		redSpot.zPosition = -1
		redSpot.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: 5))
		redSpot.physicsBody?.pinned = true
		redSpot.physicsBody?.allowsRotation = false
		
		// Put Red Spot into RedSpotCategory and set its collision to RainDropCategory and RedCategory
		redSpot.physicsBody?.categoryBitMask = RedSpotCategory
		redSpot.physicsBody?.contactTestBitMask = RainDropCategory | RedCategory
		return redSpot
	}
}
