//
//  HudNode.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 18/05/24.
//

import Foundation
import SpriteKit

class HudNode : SKNode {
	private let scoreNode = SKLabelNode(fontNamed: "NicoClean-Regular")
	private let highScoreNode = SKLabelNode(fontNamed: "NicoClean-Regular")
	private(set) var score : Int = 0
	private(set) var highScore : Int = 50
	
	public func setup(size: CGSize) {
		scoreNode.text = "\(score)"
		scoreNode.fontSize = 60
		scoreNode.position = CGPoint(x: size.width / 2, y: size.height / 1.6)
		scoreNode.zPosition = 5
		
		highScoreNode.text = "\(highScore)"
		highScoreNode.fontSize = 60
		highScoreNode.position = CGPoint(x: size.width - 100, y: size.height - 100)
		highScoreNode.zPosition = 5

		addChild(scoreNode)
		addChild(highScoreNode)
	}
	
	public func addPoint() {
		score += 1

		if score >= highScore {
			highScore = score
		}

		updateScoreboard()
	}
	
	public func resetPoints() {
		score = 0
		updateScoreboard()
	}
	
	private func updateScoreboard() {
		scoreNode.text = "\(score)"
		highScoreNode.text = "\(highScore)"
	}
}
