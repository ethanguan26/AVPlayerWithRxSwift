//
//  AVPlayerToolsBar.swift
//  AVPlayerWithRxSwift
//
//  Created by YGuan on 2016/11/21.
//  Copyright © 2016年 YGuan. All rights reserved.
//


import UIKit
import AVFoundation
import RxSwift
import RxCocoa


class AVPlayerToolsBar: UIView {
    
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var currentTime: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var totalTime: UILabel!
    @IBOutlet var barView: UIView!
    
    let disposeBag = DisposeBag()
    
    var progress: Variable<Float> = Variable(0.0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("AVPlayerToolsBar", owner: self, options: nil)
        
        self.addSubview(barView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        progress.asObservable()
            .debug("Tools Bar Observable")
            .bindTo(progressView.rx.progress)
            .addDisposableTo(disposeBag)
        
        
    }
    
}


//extension Reactive where Base: UIButton {
//    var valid: UIBindingObserver<Base, Bool> {
//        return UIBindingObserver(UIElement: base) { button, valid in
//            button.alpha = valid ? 1 : 0.5
//            button.isEnabled = valid
//        }
//    }
//}
