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
        
        avToolsBar.playButton.rx.tap
            .map { [unowned self] _ -> Bool in
                return self.player.isPlaying()
            }
            .do(onNext: { [unowned self] isPlaying in
                self.avToolsBar.isPlaying = !isPlaying
            })
            .bindTo(player.rx.isPlaying)
            .addDisposableTo(disposeBag)
        
        finishPlaying
            .subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.avToolsBar.isPlaying = false
            self.player.seek(to: CMTime(value: 0, timescale: 1))
        })
        .addDisposableTo(disposeBag)
        
        let viewModel = MediaViewModel(finishPlaying: finishPlaying)
        
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
            guard playerDuration.isValid else {
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
    
}
