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

class AVPlayerViewController
    : UIViewController
    , UIScrollViewDelegate {
    
    /// Properties
    var filePath: String?
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var playerContainer: UIView!
    
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

        let path = Bundle.main.path(forResource: "sample", ofType: "mp4")
        initializationPlayer(path: path)
        initializationBindRelationship()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if player.currentItem?.status != .readyToPlay {
            playerContainer.frame = scrollView.bounds
            playerLayer.frame = playerContainer.layer.bounds
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
        avToolsBar.isPlaying = true
    }
    
    // MARK: Private method
    
    /// initialization the cantianer and toolbar to display the media
    ///
    /// - Parameter path: doucument path
    private func initializationPlayer(path: String?) {
        
        guard path != nil else { return }
        
        playerContainer = UIView(frame: scrollView.bounds)
        scrollView.addSubview(playerContainer!)
        scrollView.maximumZoomScale = 3
        
        let asset = AVAsset(url: URL(fileURLWithPath: path!))
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerContainer.layer.addSublayer(playerLayer)
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(changePlayerSize)
        )
        playerContainer.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd(notification:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil
            
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func initializationBindRelationship() {

        let event = avToolsBar.playButton.rx.tap
            .map { [weak self] _ -> Bool in
            return self?.isPlaying() ?? false
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
        
        let viewModel = MediaViewModel(
            playerDuration:totalTimeVariable.asObservable(),
            currentTimeObservable:currentTimeVariable.asObservable(),
            event:event
        )
        
        viewModel.currentTime.asObservable()
            .bindTo(avToolsBar.currentTime.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.totalTime
            .bindTo(avToolsBar.totalTime.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel.progress
            .bindTo(avToolsBar.slider.rx.value)
            .addDisposableTo(disposeBag)
        
        viewModel.playEvent
            .bindTo(avToolsBar.playButton.rx.playing)
            .addDisposableTo(disposeBag)
        
        avToolsBar.slider.rx.value
            .subscribe(onNext: { [weak self] value in
                guard let weakSelf = self else { return }
                
                let playerDuration: CMTime = weakSelf.playerItemDuration()
                let duration: Double  = CMTimeGetSeconds(playerDuration);
                
                let currentTime: Double = CMTimeGetSeconds(weakSelf.player.currentTime())
                if (currentTime <= 0 && value == Float(0)) || (currentTime >= duration && value == 1) {
                    return;
                }
                
                let time: Double = duration * Double(value)
                weakSelf.player.seek(to: CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC)))
            })
            .addDisposableTo(disposeBag)
        
        player.addPeriodicTimeObserver(
            forInterval: CMTimeMake(100, 600),
            queue: DispatchQueue.main
        ) { [weak self] cmTime in
            guard let weakSelf = self else { return }
            let playerDuration: CMTime = weakSelf.playerItemDuration()
            if !playerDuration.isValid {
                weakSelf.currentTimeVariable.value = 0
                weakSelf.totalTimeVariable.value = 0
                return
            }
            
            let duration: Double = CMTimeGetSeconds(playerDuration)
            let currentTime: Double = CMTimeGetSeconds(weakSelf.player.currentTime())
            weakSelf.currentTimeVariable.value = currentTime
            weakSelf.totalTimeVariable.value = duration
        }
    }
    
    /// Return the current player playing status
    ///
    /// - Returns: palyer is playing or not
    private func isPlaying() -> Bool {
        return self.player.rate != 0
    }
    
    /// Get current player item duration
    private func playerItemDuration() -> CMTime {
        let playerItem: AVPlayerItem = player.currentItem!
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
        return playerContainer
    }
    
    // MARK: Notification
    /// Send message when player did finished
    func playerItemDidReachEnd(notification: NSNotification) {
        avToolsBar.isPlaying = false
        player.seek(to: CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC)))
        currentTimeVariable.value = 0
        totalTimeVariable.value = 0
    }

}
