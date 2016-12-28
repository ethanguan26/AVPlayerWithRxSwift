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


extension Reactive where Base: UIButton {

    /// avPlayer's status
    var playing: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { button, playing in
            
            let backgroundImage = playing ? #imageLiteral(resourceName: "btn_stop") : #imageLiteral(resourceName: "btn play")
            button.setBackgroundImage(backgroundImage, for: .normal)
            
        }
    }
}