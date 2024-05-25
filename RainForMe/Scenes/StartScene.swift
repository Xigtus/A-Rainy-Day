//
//  StartScene.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 19/05/24.
//

import SpriteKit

class StartScene : SKScene {
	private let playButtonNormal = SKTexture(imageNamed: "play_button_normal")
	private let playButtonPressed = SKTexture(imageNamed: "play_button_pressed")
	private var playButton : SKSpriteNode! = nil
	private var pressedPlayButton : SKSpriteNode?
	
	private let title = SKLabelNode(fontNamed: "NicoClean-Regular")
	
	private let background = BackgroundSprite.newInstance()
	private var red : RedSprite!
	
	override func sceneDidLoad() {
		background.size = CGSize(width: self.size.width, height: self.size.height)
		background.position = CGPoint(x: frame.midX, y: frame.midY)
		background.zPosition = 0
		addChild(background)
		
		title.text = "A Rainy Day"
		title.fontSize = 90
		title.position = CGPoint(x: size.width / 2, y: size.height / 2 + title.frame.height / 2 + 50)
		title.zPosition = 1
		addChild(title)
		
		playButton = SKSpriteNode(texture: playButtonNormal)
		playButton.size =  CGSize(width: playButton.size.width / 1.5, height: playButton.size.height / 1.5)
		playButton.position = CGPoint(x: title.position.x, y: title.position.y - title.frame.height / 2 - playButton.frame.height / 2 - 30)
		playButton.zPosition = 2
		addChild(playButton)
		
		red = RedSprite.newInstance()
		red.position = CGPoint(x: playButton.position.x, y: frame.midY / 3)
		red.zPosition = 3
		addChild(red)
	}
	
	override func didMove(to view: SKView) {
		// Tell Red to stay idle when scene is presented
		red.redIsIdle()
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if pressedPlayButton != nil {
				playButtonPressed(isPressed: false)
			}
			
			if playButton.contains(touch.location(in: self)) {
				pressedPlayButton = playButton
				playButtonPressed(isPressed: true)
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if pressedPlayButton == playButton {
				playButtonPressed(isPressed: playButton.contains(touch.location(in: self)))
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if pressedPlayButton == playButton {
				playButtonPressed(isPressed: false)
				
				if(playButton.contains(touch.location(in: self))) {
					playButtonTapped()
				}
			}
		}
		
		pressedPlayButton = nil
	}
	
	func playButtonPressed(isPressed : Bool) {
		if isPressed {
			playButton.texture = playButtonPressed
		} else {
			playButton.texture = playButtonNormal
		}
	}
	
	func playButtonTapped() {
		let transition = SKTransition.push(with: .left, duration: 0.5)
		let tutorialScene = TutorialScene(size: size)
		tutorialScene.scaleMode = scaleMode
		
		view?.presentScene(tutorialScene, transition: transition)
	}
}
