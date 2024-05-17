//
//  SoundManager.swift
//  RainForMe
//
//  Created by Gusti Rizky Fajar on 17/05/24.
//

import AVFoundation

class SoundManager : NSObject, AVAudioPlayerDelegate {
	static let sharedInstance = SoundManager()
	
	var audioPlayer : AVAudioPlayer?
	
	public func startPlaying() {
		if audioPlayer == nil || audioPlayer?.isPlaying == false {
			let soundURL = Bundle.main.url(forResource: "calm", withExtension: "mp3")
			
			do {
				audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
				audioPlayer?.delegate = self
			} catch {
				print("Audio player failed to load")

				startPlaying()
			}
			
			audioPlayer?.prepareToPlay()

			audioPlayer?.play()
		} else {
			print("Audio player is already playing")
		}
	}
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		startPlaying()
	}
}
