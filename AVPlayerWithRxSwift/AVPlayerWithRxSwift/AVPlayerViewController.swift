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
    
    /// Properties
    var filePath: String?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerContainer: UIView?
    private var viewModel: MediaViewModel?
    
    /// Consts
    private let disposeBag = DisposeBag()
    
    /// Bingding variable
    private let currentTimeVariable = Variable(0.0)
    private let totalTimeVariable = Variable(0.0)
    
    /// IBOutlet variable
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
        avToolsBar.isPlaying = true
    }

    
    // MARK: Private method
    
    /// initialization the cantianer and toolbar to display the media
    ///
    /// - Parameter path: doucument path
    private func initializationPlayer(path: String?) {
        
        guard path != nil else {
            return
        }
        
        playerContainer = UIView(frame: scrollView.bounds)
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
            object: nil
            
        )
    }
    
    private func isPlaying() -> Bool {
        return self.player!.rate != 0
    }
    
    private func initializationBindRelationship() {

        let event = avToolsBar.playButton.rx.tap
            .map { [weak self] _ -> Bool in
            return (self?.isPlaying())!
        }
        .scan(player!, accumulator: { (player, isPlaying) -> AVPlayer in
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
            return player
        })
        .map({ player in
            return player.rate > 0
        })
        .asObservable()
        
        viewModel = MediaViewModel(
            playerDuration:totalTimeVariable.asObservable(),
            currentTimeObservable:currentTimeVariable.asObservable(),
            event:event
        )
        
        viewModel?.currentTime.asObservable()
            .bindTo(avToolsBar.currentTime.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel?.totalTime
            .bindTo(avToolsBar.totalTime.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel?.progress
            .bindTo(avToolsBar.slider.rx.value)
            .addDisposableTo(disposeBag)
        
        viewModel?.playEvent
            .bindTo(avToolsBar.playButton.rx.playing)
            .addDisposableTo(disposeBag)
        
        
        player!.addPeriodicTimeObserver(
            forInterval: CMTimeMake(100, 600),
            queue: DispatchQueue.main
        ) { [weak self] cmTime in
            
            guard self?.playerItemDuration() != nil else {
                return
            }
            let playerDuration: CMTime = (self?.playerItemDuration())!
            if !playerDuration.isValid {
                self?.currentTimeVariable.value = 0
                self?.totalTimeVariable.value = 0
                return
            }
            
            let duration: Double = CMTimeGetSeconds(playerDuration)
            let currentTime: Double = CMTimeGetSeconds((self?.player!.currentTime())!)
            self?.currentTimeVariable.value = currentTime
            self?.totalTimeVariable.value = duration
        }
        
    }
    
    /// Get current player item duration
    private func playerItemDuration() -> CMTime {
        let playerItem: AVPlayerItem = player!.currentItem!
        if playerItem.status == .readyToPlay {
            return playerItem.duration
        }
        return kCMTimeInvalid
    }
    
    /// Change containers layout
    func changePlayerSize() {
        
    }
    
    // Mark: UIScrollView Delegate
    /// Zooming view
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return playerContainer!
    }
    
    // MARK: Notification
    /// Send message when player did finished
    func playerItemDidReachEnd(notification: NSNotification) {
        avToolsBar.isPlaying = false
        player?.seek(to: CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC)))
        currentTimeVariable.value = 0
        totalTimeVariable.value = 0
    }

}
