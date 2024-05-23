//
//  TutorialScene.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 22/05/24.
//

import SpriteKit

class TutorialScene : SKScene {
	private let background = BackgroundSprite.newInstance()
	
	private let howToPlay = SKLabelNode(fontNamed: "NicoClean-Regular")
	private let firstStepOne = SKLabelNode(fontNamed: "NicoClean-Regular")
	private let firstStepTwo = SKLabelNode(fontNamed: "NicoClean-Regular")
	private let secondStep = SKLabelNode(fontNamed: "NicoClean-Regular")
	private let tapToStart = SKLabelNode(fontNamed: "NicoClean-Regular")
	
	private let cloud = CloudSprite.newInstance()
	private let red = RedSprite.newInstance()
	
	private let tapActionKey = "action_tap"
	
	override public func sceneDidLoad() {
		background.size = CGSize(width: self.size.width, height: self.size.height)
		background.position = CGPoint(x: frame.midX, y: frame.midY)
		background.zPosition = 0
		addChild(background)
		
		howToPlay.text = "How to Play"
		howToPlay.fontSize = 60
		howToPlay.position = CGPoint(x: size.width / 4 - 50, y: size.height - howToPlay.frame.height / 2 - howToPlay.fontSize - 80)
		howToPlay.zPosition = 1
		addChild(howToPlay)
		
		firstStepOne.text = "TILT the device to control the cloud."
		firstStepOne.fontSize = 30
		firstStepOne.position = CGPoint(x: howToPlay.position.x - howToPlay.frame.width / 2 + firstStepOne.frame.width / 2, y: howToPlay.position.y - howToPlay.frame.height / 2 - firstStepOne.frame.height / 2 - 50)
		firstStepOne.zPosition = 1
		addChild(firstStepOne)
		
		firstStepTwo.text = "COLLECT rainwater to get points."
		firstStepTwo.fontSize = 30
		firstStepTwo.position = CGPoint(x: firstStepOne.position.x - firstStepOne.frame.width / 2 + firstStepTwo.frame.width / 2, y: firstStepOne.position.y - firstStepOne.frame.height / 2 - firstStepTwo.frame.height / 2 - 15)
		firstStepTwo.zPosition = 1
		addChild(firstStepTwo)
	
		secondStep.text = "DON'T let Red get caught in the rain!"
		secondStep.fontSize = 30
		secondStep.position = CGPoint(x: firstStepTwo.position.x - firstStepTwo.frame.width / 2 + secondStep.frame.width / 2, y: firstStepTwo.position.y - firstStepTwo.frame.height / 2 - secondStep.frame.height / 2 - 100)
		secondStep.zPosition = 1
		addChild(secondStep)
		
		tapToStart.text = "Tap anywhere to start"
		tapToStart.fontSize = 30
		tapToStart.position = CGPoint(x: frame.midX, y: frame.minY + 70)
		tapToStart.zPosition = 1
		addChild(tapToStart)
		
		cloud.position = CGPoint(x: firstStepOne.position.x + firstStepOne.frame.width / 2 + cloud.frame.width / 2 + 20, y: firstStepOne.position.y - firstStepOne.frame.height / 2)
		cloud.zPosition = 1
		addChild(cloud)
		
		red.position = CGPoint(x: secondStep.position.x + secondStep.frame.width / 2 + red.frame.width / 2 + 20, y: secondStep.position.y - secondStep.frame.height / 2 + 20)
		red.zPosition = 1
		addChild(red)
	}
	
	override public func didMove(to view: SKView) {
		cloud.cloudMoveTutorial()
		red.redIsRunning()
		animateTapToStart()
	}
	
	func animateTapToStart() {
		if tapToStart.action(forKey: tapActionKey) == nil {
			let scaleUpAction = SKAction.scale(to: 1.1, duration: 0.5)
			let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.5)
			let waitAction = SKAction.wait(forDuration: 0.5)
			let sequenceAction = SKAction.sequence([scaleUpAction, scaleDownAction, waitAction])
			let repeatAction = SKAction.repeatForever(sequenceAction)
			tapToStart.run(repeatAction, withKey: tapActionKey)
		}
	}
	
	func backgroundTapped() {
		let transition = SKTransition.crossFade(withDuration: 1.0)
		let gameScene = GameScene(size: size)
		gameScene.scaleMode = scaleMode
		
		view?.presentScene(gameScene, transition: transition)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if (background.contains(touch.location(in: self))) {
				backgroundTapped()
			}
		}
	}
}
