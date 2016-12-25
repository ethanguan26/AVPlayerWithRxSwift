//
//  MediaViewModel.swift
//  AVPlayerWithRxSwift
//
//  Created by YGuan on 2016/11/22.
//  Copyright © 2016年 YGuan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct MediaViewModel {
    
    let disposeBag = DisposeBag()
    
    let playEvent = PublishSubject<Bool>()
    let totalTime = PublishSubject<String>()
    let currentTime = PublishSubject<String>()
    let progress = PublishSubject<Float>()
    
    var isPlaying = false
    
    init(
        playerDuration: Observable<Double>,
        currentTimeObservable: Observable<Double>,
        event: Observable<Bool>
        ) {
        
        Observable.combineLatest(playerDuration, currentTimeObservable) {
            (duration, current) -> Float in
            
            let progress: Float = Float(current/duration)
            let progressStr = String(format: "%.2f", progress)
            return  Float(progressStr)!
            }
            .bindTo(progress)
            .addDisposableTo(disposeBag)
        
        currentTimeObservable
            .map { nowTime -> String in
                return nowTime.toTimeFormatter()
            }
            .bindTo(currentTime)
            .addDisposableTo(disposeBag)
        
        
        playerDuration
            .map { duration -> String in
                return duration.toTimeFormatter()
            }
            .bindTo(totalTime)
            .addDisposableTo(disposeBag)
        
        
        event
        .bindTo(playEvent)
        .addDisposableTo(disposeBag)
    }
    
}





