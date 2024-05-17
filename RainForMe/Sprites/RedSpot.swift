//
//  MoveRed.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 16/05/24.
//

import Foundation
import SpriteKit

public class RedSpot : SKSpriteNode {
	public static func newInstance() -> RedSpot {
		let redSpot = RedSpot(imageNamed: "redspot")
		redSpot.zPosition = -1
		redSpot.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: 5))
		redSpot.physicsBody?.affectedByGravity = false
		redSpot.physicsBody?.allowsRotation = false
		
		// Put Red Spot into RedSpotCategory and set its collision to RedCategory
		redSpot.physicsBody?.categoryBitMask = RedSpotCategory
		redSpot.physicsBody?.contactTestBitMask = RedCategory
		return redSpot
	}
}
