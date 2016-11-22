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
    
    let disposeBag = DisposeBag()
    var viewModel: MediaViewModel?
    
    let currentTimeVariable = Variable(0.0)
    let totalTimeVariable = Variable(0.0)
    
    
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
            object: self.playerLayer
        )
    }
    
    private func initializationBindRelationship() {
        
        viewModel = MediaViewModel(
            playerDuration:totalTimeVariable.asObservable(),
            currentTimeObservable:currentTimeVariable.asObservable()
        )
        
        viewModel?.currentTime.asObservable()
            .bindTo(avToolsBar.currentTime.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel?.totalTime
            .bindTo(avToolsBar.totalTime.rx.text)
            .addDisposableTo(disposeBag)
        
        viewModel?.progress
            .bindTo(avToolsBar.progressView.rx.progress)
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
    
    func playerItemDuration() -> CMTime {
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
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return playerContainer!
    }
    
    // MARK: Notification
    /// Send message when player did finished
    func playerItemDidReachEnd(notification: NSNotification) {
    
    }

}
