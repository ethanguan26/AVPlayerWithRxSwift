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
    
    var currentTimeVariable = Variable(0.0)
    var totalTimeVariable = Variable(0.0)
    
    let playEvent = PublishSubject<Bool>()
    let totalTime: Observable<String>
    let currentTime: Observable<String>
    let progress: Observable<Float>
    
    init(
        finishPlaying: Observable<Notification>
        ) {
        
        let finishCurrentTime = finishPlaying.map { _ in 0.0 }
        let current = Observable.of(currentTimeVariable.asObservable(), finishCurrentTime).merge()
        
        progress = Observable.combineLatest(totalTimeVariable.asObservable(), current) {
            (duration, current) -> Float in
            let progress: Float = Float(current/duration)
            let progressStr = String(format: "%.2f", progress)
            return  Float(progressStr)!
        }
        
        currentTime = current
            .map { nowTime -> String in
                return nowTime.toTimeFormatter()
            }
        
        totalTime = totalTimeVariable.asObservable()
            .map { duration -> String in
                return duration.toTimeFormatter()
            }
    }
    
}





