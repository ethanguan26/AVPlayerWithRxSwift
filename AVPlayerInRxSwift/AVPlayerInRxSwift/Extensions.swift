//
//  Extensions.swift
//  AVPlayerWithRxSwift
//
//  Created by YGuan on 2016/11/22.
//  Copyright © 2016年 YGuan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import AVFoundation

extension Double {
    
    /// convert the doubleValue with formatter
    ///
    /// - Returns: Return the time after formatter (e.g. 00:00:00)
    func toTimeFormatter() -> String {
        let remainingTimeHour: Int = Int(self) / 360
        let remainingTimeMin: Int = (Int(self) - Int(remainingTimeHour * 360)) / 60
        let remainingTimeSec: Int = Int(self) - Int(remainingTimeHour * 360) - Int(remainingTimeMin * 60)
        
        return String(format:"%02d",remainingTimeHour) + ":" +
            String(format:"%02d",remainingTimeMin) + ":" +
            String(format:"%02d",remainingTimeSec)
    }
}


extension AVPlayer {
    
    /// Get current player item duration
    func playerItemDuration() -> CMTime {
        let playerItem: AVPlayerItem = self.currentItem!
        if playerItem.status == .readyToPlay {
            return playerItem.duration
        }
        return kCMTimeInvalid
    }
    
    /// Return the current player playing status
    ///
    /// - Returns: palyer is playing or not
    func isPlaying() -> Bool {
        return self.rate != 0
    }
}

extension Reactive where Base: AVPlayer {
    
    var progress: UIBindingObserver<Base, Float> {
        return UIBindingObserver(UIElement: base) { player, progress in
            let playerDuration: CMTime = player.playerItemDuration()
            let duration: Double  = CMTimeGetSeconds(playerDuration);
            
            let time: Double = duration * Double(progress)
            player.seek(to: CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC)))
        }
    }
    
    var isPlaying: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { player, isPlaying in
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
        }
    }
    
}

extension Reactive where Base: UIButton {

    /// avPlayer's status
    var playing: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { button, playing in
            
            let backgroundImage = playing ? #imageLiteral(resourceName: "btn_stop") : #imageLiteral(resourceName: "btn play")
            button.setBackgroundImage(backgroundImage, for: .normal)
            
        }
    }
}
