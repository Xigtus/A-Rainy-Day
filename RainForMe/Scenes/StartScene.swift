//
//  StartScene.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 19/05/24.
//

import SpriteKit

class StartScene : SKScene {
	let playButtonNormal = SKTexture(imageNamed: "play_button_normal")
	let playButtonPressed = SKTexture(imageNamed: "play_button_pressed")
	
	let title = SKLabelNode(fontNamed: "NicoClean-Regular")
	
	var playButton : SKSpriteNode! = nil
	var pressedButton : SKSpriteNode?
	
	private let background = BackgroundSprite.newInstance()
	private var red : RedSprite!
	
	override func sceneDidLoad() {
		background.size = CGSize(width: self.size.width, height: self.size.height)
		background.position = CGPoint(x: frame.midX, y: frame.midY)
		background.zPosition = 0
		addChild(background)
		
		title.text = "A Rainy Day"
		title.fontSize = 90
		title.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
		title.zPosition = 1
		addChild(title)
		
		playButton = SKSpriteNode(texture: playButtonNormal)
		playButton.size =  CGSize(width: playButton.size.width * 1.2, height: playButton.size.height * 1.2)
		playButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
		playButton.zPosition = 2
		addChild(playButton)
		
		red = RedSprite.newInstance()
		red.position = CGPoint(x: frame.midX, y: frame.midY / 3)
		red.zPosition = 3
		red.redIsIdle()
		addChild(red)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if pressedButton != nil {
				playButtonPressed(isPressed: false)
			}
			
			if playButton.contains(touch.location(in: self)) {
				pressedButton = playButton
				playButtonPressed(isPressed: true)
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if pressedButton == playButton {
				playButtonPressed(isPressed: playButton.contains(touch.location(in: self)))
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if pressedButton == playButton {
				playButtonPressed(isPressed: false)
				
				if(playButton.contains(touch.location(in: self))) {
					playButtonTapped()
				}
			}
		}
		
		pressedButton = nil
	}
	
	func playButtonPressed(isPressed : Bool) {
		if isPressed {
			playButton.texture = playButtonPressed
		} else {
			playButton.texture = playButtonNormal
		}
	}
	
	func playButtonTapped() {
		let transition = SKTransition.crossFade(withDuration: 0.7)
		let gameScene = GameScene(size: size)
		gameScene.scaleMode = scaleMode
		
		view?.presentScene(gameScene, transition: transition)
	}
}
