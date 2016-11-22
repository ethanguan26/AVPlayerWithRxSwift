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
    
    let playButtonAction = PublishSubject<Void>()
    let totalTime = PublishSubject<String>()
    let currentTime = PublishSubject<String>()
    let progress = PublishSubject<Float>()
    
    
    init(
        playerDuration: Observable<Double>,
        currentTimeObservable: Observable<Double>
        ) {
        
        
        Observable.combineLatest(playerDuration, currentTimeObservable) { (duration, current) -> Float in
            let progress: Float = Float(current/duration)
            let progressStr = String(format: "%.2f", progress)
            return  Float(progressStr)!
        }
        .bindTo(progress)
        .addDisposableTo(disposeBag)
        
        
        
        currentTimeObservable
            .map { nowTime -> String in
            
            let elapsedTimeHour: Int = Int(nowTime/360)
            let elapsedTimeMin: Int = (Int(nowTime) - Int(elapsedTimeHour * 360)) / 60
            let elapsedTimeSec: Int = Int(nowTime) - elapsedTimeHour * 360 - elapsedTimeMin * 60
            
            return String(format:"%02d",elapsedTimeHour) + ":" +
                String(format:"%02d",elapsedTimeMin) + ":" +
                String(format:"%02d",elapsedTimeSec)
        }
        .bindTo(currentTime)
        .addDisposableTo(disposeBag)
        
        
        playerDuration
            .map { duration -> String in
            
            let remainingTimeHour: Int = Int(duration) / 360
            let remainingTimeMin: Int = (Int(duration) - Int(remainingTimeHour * 360)) / 60
            let remainingTimeSec: Int = Int(duration) - Int(remainingTimeHour * 360) - Int(remainingTimeMin * 60)
            
            return String(format:"%02d",remainingTimeHour) + ":" +
                String(format:"%02d",remainingTimeMin) + ":" +
                String(format:"%02d",remainingTimeSec)
        }
        .bindTo(totalTime)
        .addDisposableTo(disposeBag)
        
        
    }
    
}
