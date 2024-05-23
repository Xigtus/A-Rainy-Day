//
//  HeartSprite.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 22/05/24.
//

import SpriteKit

public class HeartSprite : SKSpriteNode {
	private let heartRecoilKey = "action_heart_recoil"
	
	public static func newInstance() -> HeartSprite {
		let redHeart = HeartSprite(imageNamed: "heart")
		redHeart.zPosition = 5
		
		return redHeart
	}
	
	public func redHeartRecoil() {
		if action(forKey: heartRecoilKey) == nil {
			let scaleUpAction = SKAction.scale(to: 1.0, duration: 0.1)
			let scaleDownAction = SKAction.scale(to: 0.7, duration: 0.1)
			let scaleSequence = SKAction.sequence([scaleDownAction, scaleUpAction])
			run(scaleSequence)
		}
	}
}
