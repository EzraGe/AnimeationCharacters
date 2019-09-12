//
//  PlayVoiceRelatedInfoPanel.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/2.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

protocol PlayToolBarDelegate : NSObjectProtocol {
    func playtoolbarDidClickFavouriteButton(_ playtoolbar : PlayToolBar , btn : UIButton)
    func playtoolbarDidClickLastButton(_ playtoolbar : PlayToolBar ,btn : UIButton)
    func playtoolbarDidClickPlayPauseButton(_ playtoolbar : PlayToolBar ,btn : UIButton)
    func playtoolbarDidClickNextButton(_ playtoolbar : PlayToolBar ,btn : UIButton)
    func playtoolbarDidClickPlayModeButton(_ playtoolbar : PlayToolBar ,btn : PlayModeButton)
}

class PlayModeButton : UIButton {
    private var modeInt = 0
    
    func changeMode() -> PlayMode {
        modeInt = (modeInt + 1) % 4
        
        if modeInt == 1 {
            self.setImage(UIImage.init(named: "mode_loop_single"), for: .normal)
            return .SingleLoop
        } else if modeInt == 2 {
            self.setImage(UIImage.init(named: "mode_shuffle"), for: .normal)
            return .Shuffle
        } else if modeInt == 3 {
            self.setImage(UIImage.init(named: "mode_ordered"), for: .normal)
            return .OrderedPlay
        } else {
            self.setImage(UIImage.init(named: "mode_loop_list"), for: .normal)
            return .ListLoop
        }
    }
}

class PlayToolBar : UIView {
    static let PlayToolBarHeight : CGFloat = 72
    
    weak var delegate : PlayToolBarDelegate?
    
    private let btnsSquare : [CGFloat] = [40, 49, 68, 49, 44]
    
    private var favouriteBtn = UIButton()
    private var lastVoiceBtn = UIButton()
    private var playOrPauseBtn = UIButton()
    private var nextVoiceBtn = UIButton()
    private var playModelBtn = PlayModeButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initPlayBtns()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let space = (screenWidth - 40 - 49 * 2 - 68 - 44) / 6
        var x = space
        
        for (i, btn) in [self.favouriteBtn, self.lastVoiceBtn, self.playOrPauseBtn, self.nextVoiceBtn, self.playModelBtn].enumerated() {
            let square = self.btnsSquare[i]
            let y = 0.5 * (PlayToolBar.PlayToolBarHeight - square)
            btn.frame = CGRect.init(x: x, y: y, width: square, height: square)
            x += square
            x += space
        }
    }
    
    func initPlayBtns() {
        let imgNames : [String] = ["btn_favourite", "play_btn_previous", "btn_pause", "play_btn_next", "mode_loop_list"]
        let selectors : [Selector] = [#selector(onFavouriteBtnClick(_:)), #selector(onLastBtnClick(_:)), #selector(onPlayPauseBtnClick(_:)), #selector(onNextBtnClick(_:)), #selector(onPlayModeBtnClick(_:))]
        for (i, btn) in [self.favouriteBtn, self.lastVoiceBtn, self.playOrPauseBtn, self.nextVoiceBtn, self.playModelBtn].enumerated() {
            let imgName = imgNames[i]
            let selector = selectors[i]
            btn.setImage(UIImage.init(named: imgName), for: .normal)
            btn.addTarget(self, action: selector, for: .touchUpInside)
            self.addSubview(btn)
        }
        
        self.playOrPauseBtn.setImage(UIImage.init(named: "btn_play"), for: .selected)
        self.favouriteBtn.setImage(UIImage.init(named: "btn_favourite_done"), for: .selected)
    }
    
    func updateFavouriteState(_ isFavourited : Bool) {
        self.favouriteBtn.isSelected = isFavourited
    }
    
    func updateSelectState() {
        self.playOrPauseBtn.isSelected = !self.playOrPauseBtn.isSelected
    }
    
    @objc func onFavouriteBtnClick(_ sender : UIButton) {
        self.delegate?.playtoolbarDidClickFavouriteButton(self, btn: sender)
    }
    
    @objc func onLastBtnClick(_ sender : UIButton) {
        self.delegate?.playtoolbarDidClickLastButton(self, btn: sender)
    }
    
    @objc func onPlayPauseBtnClick(_ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.delegate?.playtoolbarDidClickPlayPauseButton(self, btn: sender)
    }
    
    @objc func onNextBtnClick(_ sender : UIButton) {
        self.delegate?.playtoolbarDidClickNextButton(self, btn: sender)
    }
    
    @objc func onPlayModeBtnClick(_ sender : PlayModeButton) {
        self.delegate?.playtoolbarDidClickPlayModeButton(self, btn: sender)
    }
}
