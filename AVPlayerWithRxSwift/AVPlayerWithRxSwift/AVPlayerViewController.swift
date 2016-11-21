//
//  AVPlayerViewController.swift
//  AVPlayerWithRxSwift
//
//  Created by YGuan on 2016/11/21.
//  Copyright © 2016年 YGuan. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

class AVPlayerViewController: UIViewController {
    
    ///properties
    var filePath: String?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerContainer: UIView?

    /// IBOutlet vaiables
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avToolsBar: AVPlayerToolsBar!
    
    // MARK: Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        let path = Bundle.main.path(forResource: "Test02", ofType: "m4v")
        initializationPlayer(path: path)
        initializationBindRelationship()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerContainer?.frame = scrollView.bounds
        playerLayer?.frame = (playerContainer?.layer.bounds)!
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    
    // MARK: Private method
    
    /// initialization the cantianer and toolbar to display the media
    ///
    /// - Parameter path: file path
    private func initializationPlayer(path: String?) {
        
        guard path != nil else {
            return
        }
        
        playerContainer = UIView(frame: scrollView.bounds)
        playerContainer?.backgroundColor = UIColor.red
        scrollView.addSubview(playerContainer!)
        scrollView.maximumZoomScale = 3
        
        let asset = AVAsset(url: URL(fileURLWithPath: path!))
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerContainer?.layer.addSublayer(playerLayer!)
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(changePlayerSize)
        )
        playerContainer?.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd(notification:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: self.playerLayer
        )
    }
    
    private func initializationBindRelationship() {
        
        player!.addPeriodicTimeObserver(
            forInterval: CMTimeMake(150, 600),
            queue: DispatchQueue.main
        ) { [weak self] cmTime in
            
            let playerDuration: CMTime = (self?.playerItemDuration())!
            
            if !playerDuration.isValid {
                self?.avToolsBar.progress.value = 0
                return
            }
            
            let duration: Double = CMTimeGetSeconds(playerDuration)
            let currentTime: Double = CMTimeGetSeconds((self?.player!.currentTime())!)
            
            let progress: Float = Float(currentTime/duration)
            self?.avToolsBar.progress.value = progress
            
            
            self?.updateTimeLabel()
            
        }
        
    }
    
    func playerItemDuration() -> CMTime {
        let playerItem: AVPlayerItem = player!.currentItem!
        if playerItem.status == .readyToPlay {
            return playerItem.duration
        }
        return kCMTimeInvalid
    }
    
    func updateTimeLabel() {
        let playerDuration: CMTime = self.playerItemDuration()
        
        if !playerDuration.isValid {
            return
        }
        
        let duration: Double = CMTimeGetSeconds(playerDuration)
        let currentTime: Double = CMTimeGetSeconds(player!.currentTime())
        
        let elapsedTimeMin: Int = Int(currentTime/60)
        let elapsedTimeSec: Int = Int(currentTime) - elapsedTimeMin*60
        
        let remainingTimeMin: Int = Int((duration - currentTime)/60)
        let remainingTimeSec: Int = Int(duration - currentTime) - remainingTimeMin*60
        
//        elapsedTimeLabel.text = (NSString(format:"%02d",elapsedTimeMin) as String) + ":" + (NSString(format:"%02d",elapsedTimeSec) as String)
//        self.remainingTimeLabel.text = "-" + (NSString(format:"%02d",remainingTimeMin) as String) + ":" + (NSString(format:"%02d",remainingTimeSec) as String)
    }

    
    /// Change containers layout
    func changePlayerSize() {
        
    }
    
    // Mark: UIScrollView Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return playerContainer!
    }
    
    // MARK: Notification
    /// Send message when player did finished
    func playerItemDidReachEnd(notification: NSNotification) {
    
    }

}
