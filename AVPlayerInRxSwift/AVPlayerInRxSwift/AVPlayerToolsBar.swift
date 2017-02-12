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
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet var barView: UIView!
    
    let disposeBag = DisposeBag()
    
    var isPlaying = false {
        didSet {
            let image = isPlaying ? #imageLiteral(resourceName: "btn_stop") : #imageLiteral(resourceName: "btn play")
            playButton.setBackgroundImage(image, for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("AVPlayerToolsBar", owner: self, options: nil)
        self.addSubview(barView)
    }
    
}
