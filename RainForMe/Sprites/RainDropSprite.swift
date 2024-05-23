//
//  RainDropSprite.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 22/05/24.
//

import SpriteKit

public class RainDropSprite : SKSpriteNode {
	public static func newInstance() -> RainDropSprite {
		let rainDrop = RainDropSprite(imageNamed: "raindrop")
		rainDrop.physicsBody = SKPhysicsBody(rectangleOf: rainDrop.size)
		
		// Put RainDrop into RainDropCategory and set its collision to FloorCategory and RedSpotCategory
		rainDrop.physicsBody?.categoryBitMask = RainDropCategory
		rainDrop.physicsBody?.contactTestBitMask = FloorCategory | RedSpotCategory
		
		return rainDrop
	}
}
