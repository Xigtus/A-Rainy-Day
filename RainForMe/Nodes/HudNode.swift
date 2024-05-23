//
//  HudNode.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 18/05/24.
//

import SpriteKit

class HudNode : SKNode {
	private let scoreNode = SKLabelNode(fontNamed: "NicoClean-Regular")
	private let highScoreNode = SKLabelNode(fontNamed: "NicoClean-Regular")
	private let highScoreText = SKLabelNode(fontNamed: "NicoClean-Regular")
	
	private(set) var score : Int = 0
	private(set) var highScore : Int = 80
	
	private let backButtonNormal = SKTexture(imageNamed: "back_button_normal")
	private let backButtonPressed = SKTexture(imageNamed: "back_button_pressed")
	private var backButton : SKSpriteNode!
	private(set) var pressedBackButton = false
	
	var backButtonAction : (() -> ())?
	
	public func setup(size: CGSize) {
		// Set HUD for score
		scoreNode.text = "\(score)"
		scoreNode.fontSize = 70
		scoreNode.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
		scoreNode.zPosition = 5
		addChild(scoreNode)
		
		// Set text for high score
		highScoreText.text = "High Score"
		highScoreText.position = CGPoint(x: size.width - highScoreText.frame.width / 2 - 20, y: size.height - highScoreText.frame.height / 2 - 20)
		highScoreText.zPosition = 5
		addChild(highScoreText)
		
		// Set HUD for high score
		highScoreNode.text = "\(highScore)"
		highScoreNode.fontSize = 65
		highScoreNode.position = CGPoint(x: highScoreText.position.x, y: highScoreText.position.y - highScoreText.frame.height / 2 - highScoreNode.frame.height / 2 - 25)
		highScoreNode.zPosition = 5
		addChild(highScoreNode)
		
		// Set back button
		backButton = SKSpriteNode(texture: backButtonNormal)
		backButton.size = CGSize(width: backButton.size.width / 1.5, height: backButton.size.height / 1.5)
		backButton.position = CGPoint(x: backButton.size.width / 2 + 20, y: size.height - backButton.size.height / 2 - 20)
		backButton.zPosition = 5
		addChild(backButton)
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
	
	func backButtonIsTapped(point : CGPoint) {
		let containsPoint = backButton.contains(point)
		
		if pressedBackButton && !containsPoint {
			pressedBackButton = false
			backButton.texture = backButtonNormal
		} else if containsPoint {
			backButton.texture = backButtonPressed
			pressedBackButton = true
		}
	}
	
	func backButtonIsPressed(point : CGPoint) {
		if pressedBackButton {
			if backButton.contains(point) {
				backButton.texture = backButtonPressed
			} else {
				backButton.texture = backButtonNormal
			}
		}
	}
	
	func backButtonIsReleased(point : CGPoint) {
		if backButton.contains(point) {
			if backButton.contains(point) && backButtonAction != nil {
			  backButtonAction!()
			}
		}
		
		backButton.texture = backButtonNormal
	}
}
