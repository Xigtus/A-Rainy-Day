//
//  BackgroundSprite.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 17/05/24.
//

import SpriteKit

public class BackgroundSprite : SKSpriteNode {
	public static func newInstance() -> BackgroundSprite {
		let background = BackgroundSprite(imageNamed: "background")
		background.zPosition = 0
		
		return background
	}
}
