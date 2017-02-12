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
    
    /// Consts
    private let disposeBag = DisposeBag()
    
    /// IBOutlet variable
    @IBOutlet private weak var avToolsBar: AVPlayerToolsBar!
    @IBOutlet private weak var playerContainer: UIView!
    
    // MARK: Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        let path = Bundle.main.path(forResource: "sample", ofType: "mp4")
        initializationPlayer(path: path)
        initializationBindRelationship()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerContainer.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
        avToolsBar.isPlaying = true
    }
    
    deinit {
        print("AVPlayer controller has been released")
    }
    
    // MARK: Private method
    /// initialization the cantianer and toolbar to display the media
    ///
    /// - Parameter path: doucument path
    private func initializationPlayer(path: String?) {
        
        guard path != nil else { return }
        
        let asset = AVAsset(url: URL(fileURLWithPath: path!))
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerContainer.layer.addSublayer(playerLayer)

    }
    
    private func initializationBindRelationship() {

         let finishPlaying = NotificationCenter.default.rx.notification(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
        
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
        
        let viewModel = MediaViewModel(playAction:event,
                                       finishPlaying: finishPlaying)
        
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
            .bindTo(player.rx.progress)
            .addDisposableTo(disposeBag)
        
        player.addPeriodicTimeObserver(
            forInterval: CMTimeMake(100, 600),
            queue: DispatchQueue.main
        ) { [weak self] cmTime in
            guard let weakSelf = self else { return }
            let playerDuration: CMTime = weakSelf.player.playerItemDuration()
            if !playerDuration.isValid {
                viewModel.currentTimeVariable.value = 0
                viewModel.totalTimeVariable.value = 0
                return
            }
            
            let duration: Double = CMTimeGetSeconds(playerDuration)
            let currentTime: Double = CMTimeGetSeconds(weakSelf.player.currentTime())
            viewModel.currentTimeVariable.value = currentTime
            viewModel.totalTimeVariable.value = duration
        }
        
        
    }
    
    /// Return the current player playing status
    ///
    /// - Returns: palyer is playing or not
    private func isPlaying() -> Bool {
        return self.player.rate != 0
    }

}
