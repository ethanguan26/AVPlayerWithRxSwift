//
//  AVPlayerToolsBar.swift
//  AVPlayerWithRxSwift
//
//  Created by YGuan on 2016/11/21.
//  Copyright © 2016年 YGuan. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerToolsBar: UIView {
    
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var currentTime: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var totalTime: UILabel!
    
    
}


//extension Reactive where Base: UIButton {
//    var valid: UIBindingObserver<Base, Bool> {
//        return UIBindingObserver(UIElement: base) { button, valid in
//            button.alpha = valid ? 1 : 0.5
//            button.isEnabled = valid
//        }
//    }
//}
