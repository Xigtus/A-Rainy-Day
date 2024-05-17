//
//  GameViewController.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 14/05/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		let sceneNode = GameScene(size: view.frame.size)

		if let view = self.view as! SKView? {
			view.presentScene(sceneNode)
			view.ignoresSiblingOrder = true

			view.showsPhysics = false
			view.showsFPS = false
			view.showsNodeCount = false
		}
		
		SoundManager.sharedInstance.startPlaying()
	}

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
