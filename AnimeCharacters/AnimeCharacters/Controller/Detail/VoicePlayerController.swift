//
//  VoicePlayerController.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/1.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage
import MediaPlayer

enum PlayMode {
    case Shuffle
    case SingleLoop
    case ListLoop
    case OrderedPlay
}

struct PlayList {
    var list : [LineModel]
    
    var currentIndex = -1
    
    init(list : [LineModel]) {
        self.list = list
    }
    
    mutating func nextItem(playMode : PlayMode) -> LineModel? {
        switch playMode {
        
        case .OrderedPlay:
            if self.currentIndex < self.list.count - 1 {
                self.currentIndex += 1
            } else {
                return nil
            }
        case .SingleLoop:
            break
        case .ListLoop:
            self.currentIndex = (self.currentIndex + 1) % self.list.count
        case .Shuffle:
            let index : Int = Int(arc4random_uniform((UInt32)(self.list.count)))
            self.currentIndex = index
        }
        return self.list[self.currentIndex]
    }
    
    mutating func previousItem(playMode : PlayMode) -> LineModel? {
        switch playMode {
            
        case .OrderedPlay:
            if self.currentIndex > 0 {
                self.currentIndex -= 1
                return self.list[self.currentIndex]
            }
        case .SingleLoop:
            return self.list[self.currentIndex]
        case .ListLoop:
            self.currentIndex = (self.currentIndex - 1 + self.list.count) % self.list.count
            return self.list[self.currentIndex]
        case .Shuffle:
            let index : Int = Int(arc4random_uniform((UInt32)(self.list.count)))
            self.currentIndex = index
            return self.list[self.currentIndex]
        }
        return nil
    }
}

var timer : Timer?

protocol PlayerDelegate : NSObjectProtocol {
    func playerDidPlayAtProgress(_ player : Player, progress : Double)
    func playerWillPlayNextItem(_ player : Player, next : LineModel)
    func playerWillPlayPreviousItem(_ player : Player, previous : LineModel)
//    func playerWillReiciveLockScreenImage(_ player : Player)
}

class Player : UIResponder, AVAudioPlayerDelegate {
    static let player = Player()
    
    weak var delegate : PlayerDelegate?
    
    var player : AVAudioPlayer?
    
    var playMode : PlayMode = .OrderedPlay
    
    var currentPlayList : PlayList?
    
    var willPlaySameLine = false
    
    func setupList(_ lineList : [LineModel], currentIndex : Int) {
        self.willPlaySameLine = (self.currentPlayList?.currentIndex == currentIndex)
        if let curList = self.currentPlayList {
            if curList.currentIndex >= 0 && currentIndex >= 0 {
                let curLine = curList.list[curList.currentIndex]
                let toPlay = lineList[currentIndex]
                self.willPlaySameLine = (curLine == toPlay)
            }
        }
        if !self.willPlaySameLine {
            self.player?.stop()
            self.player = nil
        }
        self.currentPlayList = PlayList.init(list: lineList)
        self.currentPlayList?.currentIndex = currentIndex
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name(rawValue: AVAudioSessionInterruptionTypeKey), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleInterruption(_ notification : Notification) {
        guard let userInfo = notification.userInfo,
        let interruptionTypeRawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSession.InterruptionType.init(rawValue: interruptionTypeRawValue)
        else {
            return
        }
        
        switch interruptionType {
        case .began:
            if (self.player != nil) {
                self.player?.pause()
            } else {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(playNext), object: nil)
            }
        case .ended:
            if (self.player != nil) {
                self.player?.play()
            } else {
                self.playNext()
            }
        @unknown default:
            break
        }
    }
    
    func play() {
        if self.currentPlayList == nil || self.currentPlayList?.list.count == 0 {
            return
        }
        
        let playList = self.currentPlayList!
        let model = playList.list[playList.currentIndex]
        self.play(with: model)
    }
    
    func fireTimer() {
        removeTimer()
        timer = Timer.init(timeInterval: 0.1, repeats: true, block: { (_ timer) in
            if self.player != nil {
                let progress = Double(self.player!.currentTime / self.player!.duration)
                self.delegate?.playerDidPlayAtProgress(self, progress: progress)
            }
        })
        if timer != nil {
            RunLoop.main.add(timer!, forMode: .common)
        }
    }
    
    func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func play(with lineModel : LineModel) {
        if self.currentPlayList == nil || self.currentPlayList?.list.count == 0 {
            return
        }
        
        if self.willPlaySameLine {
            if self.player != nil {
                if !self.player!.isPlaying {
                    self.player?.play()
                    self.fireTimer()
                }
            }
            return
        }
        
        self.player = nil
        
        //1.search for cache
        
        
        //2.play
        let url = Bundle.lineURL(with: lineModel.id)
        
        if url != nil {
            let theURL = url!
            do {
                try self.player = AVAudioPlayer.init(contentsOf: theURL)
                self.player?.delegate = self
                self.player?.prepareToPlay()
                
            } catch  {
                self.player = nil
            }
        } else {
            return
        }
    
        self.player?.play()
        self.fireTimer()
        //3.add to cache
    }
    
    @objc func playNext() {
        let next = self.currentPlayList?.nextItem(playMode: self.playMode)
        if next != nil {
            self.play(with: next!)
            self.delegate?.playerWillPlayNextItem(self, next: next!)
        }
    }
    
    @objc func playPrevious() {
        let prevs = self.currentPlayList?.previousItem(playMode: self.playMode)
        if prevs != nil {
            self.play(with: prevs!)
            self.delegate?.playerWillPlayPreviousItem(self, previous: prevs!)
        }
    }
    
    /// MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.stop()
        self.player = nil
        self.willPlaySameLine = false
        if flag {
            self.playNext()
        }
    }
}

class VoicePlayerController : BaseController, PlayerDelegate , PlayToolBarDelegate {
    
    static let sliderWrapperViewHeight : CGFloat = 36
    
    private var backgroundImageview = UIImageView()
    private var effectView = UIVisualEffectView()
    private var scrollview = UIScrollView()
    private var imageview = UIImageView()
    private var lineLabel = UILabel()
    
    private var favouriteBtn = UIButton()
    private var downloadBtn = UIButton()
    private var panelBtn = UIButton()
    
    private var sliderWrapperView = UIView()
    private var startTimeLabel = UILabel()
    private var endTimeLabel   = UILabel()
    private var slider = UISlider()
    
    private var playToolBar = PlayToolBar()
    
    private var line : LineModel?
    
    struct TimeState {
        var timeState : String = "00:00"
        
        init(_ totalSeconds : Double) {
            let min : Int = (Int(totalSeconds / 60))
            let sec : Int = Int(totalSeconds) % 60
            self.timeState = String(format: "%02d", min) + ":" + String(format: "%02d", sec)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.resignFirstResponder()
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    init(line : LineModel) {
        super.init(nibName: nil, bundle: nil)
        self.line = line
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        self.initBackgroundAndLineLabel()
        self.initBtns()
        
        let toolbarH = screenHeight - PlayToolBar.PlayToolBarHeight - (hasSafeArea ? 44 : 30)
        self.playToolBar.frame = CGRect.init(x: 0, y: toolbarH, width: screenWidth, height: PlayToolBar.PlayToolBarHeight)
        self.view.addSubview(self.playToolBar)
        self.playToolBar.delegate = self
        
        self.initPlaySlider()
        
        let avaliableHeight = self.sliderWrapperView.frame.minY - self.ac_navigationBar.frame.maxY
        self.scrollview.contentSize = .init(width: 2 * screenWidth, height: 0)
        self.scrollview.bounces = true
        self.scrollview.showsHorizontalScrollIndicator = false
        self.scrollview.frame = .init(x: 0, y: self.ac_navigationBar.frame.maxY, width: screenWidth, height: avaliableHeight)
        self.view.addSubview(self.scrollview)
        
        let scrollviewContentH = avaliableHeight * 0.8
        let scrollviewContentW = scrollviewContentH / 1.6
        let x = (screenWidth - scrollviewContentW) * 0.5
        let y = (avaliableHeight - scrollviewContentH) * 0.5
        
        self.imageview.frame = .init(x: x, y: y, width: scrollviewContentW, height: scrollviewContentH)
        self.imageview.contentMode = .scaleAspectFill
        self.imageview.clipsToBounds = true
        self.imageview.sd_setImage(with: URL.init(string: self.line?.backgroundURL ?? "")!, completed: nil)
        self.scrollview.addSubview(self.imageview)
        
        self.lineLabel.font = .PingFangSC_Regular(size: 15)
        self.lineLabel.textColor = .white
        self.lineLabel.text = self.line?.line
        self.lineLabel.textAlignment = .center
        let w = screenWidth - 40
        let h = self.imageview.frame.height
        self.lineLabel.bounds = .init(x: 0, y: 0, width: w, height: h)
        self.lineLabel.center = .init(x: self.scrollview.center.x + screenWidth, y: self.scrollview.center.y)
        self.scrollview.addSubview(self.lineLabel)
        self.scrollview.isPagingEnabled = true
        
        Player.player.delegate = self
        Player.player.playMode = .ListLoop
        Player.player.play()
        self.updateUI()
        
        self.ac_navigationBarHidden = false
        self.ac_navigationBarBackButtonStyle = .white
        self.view.bringSubviewToFront(self.ac_navigationBar)
        
        NotificationCenter.default.addObserver(self, selector: #selector(routeChange(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(playtoolbarDidClickLastButton(_:btn:)))
        
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(playtoolbarDidClickNextButton(_:btn:)))
        
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(remoteControlPause(_:)))
        
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(remoteControlPlay(_:)))
        
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget(self, action: #selector(remoteSliderChange(_:)))
    }
    
    // MARK: Remote Control
    
    @objc func remoteSliderChange(_ event : MPChangePlaybackPositionCommandEvent) {
        if let player = Player.player.player {
            player.currentTime = event.positionTime
        }
    }
    
    @objc func remoteControlPause(_ sender : Any ) {
        Player.player.player?.pause()
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if info != nil {
            info![MPNowPlayingInfoPropertyPlaybackRate] = 0
        }
        Player.player.removeTimer()
        self.playToolBar.updateSelectState()
    }
    
    @objc func remoteControlPlay(_ sender : Any ) {
        Player.player.player?.play()
        Player.player.fireTimer()
        self.playToolBar.updateSelectState()
        
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if info != nil {
            info![MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        }
    }
    
    // MARK: Notification
    
    @objc func routeChange(_ notification : Notification) {
        if let player = Player.player.player {
            if let userinfo = notification.userInfo {
                let reason = userinfo[AVAudioSessionRouteChangeReasonKey] as! AVAudioSession.RouteChangeReason
                let description = userinfo[AVAudioSessionRouteChangePreviousRouteKey] as! AVAudioSessionRouteDescription
                
                if let portDescription = description.outputs.first {
                    if portDescription.portType == .headphones {
                        switch reason {
                        case .oldDeviceUnavailable:
                            player.pause()
                        case .newDeviceAvailable:
                            player.play()
                        default:break
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Subviews
    
    func updateUI() {
        self.backgroundImageview.sd_setImage(with: URL.init(string: self.line?.backgroundURL ?? "")!, completed: nil)
        
        if self.line != nil {
            let url = Bundle.lineURL(with: self.line!.id)
            if url != nil {
                let currentTime = Player.player.player?.currentTime ?? 0
                self.startTimeLabel.text = TimeState.init(currentTime).timeState
                
                let totalSeconds = Player.player.player?.duration ?? 0
                self.endTimeLabel.text = TimeState.init(totalSeconds).timeState
                
                self.slider.minimumValue = 0
                self.slider.maximumValue = 1
                self.slider.value = Float(currentTime / totalSeconds)
                
                let isFavourited = Favourites.sharedInstance.isFavourited(data: self.line!)
                self.playToolBar.updateFavouriteState(isFavourited)
                
                let line = self.line!
                let duration = Player.player.player?.duration ?? 0
                self.imageview.sd_setImage(with: URL.init(string: self.line?.backgroundURL ?? "")!) { (image, error, cachetype, url) in
                    if image != nil {
                        let artwork = MPMediaItemArtwork.init(boundsSize: .init(width: 100, height: 100)) { (size) -> UIImage in
                            return image!
                        }
                        
                        let playingInfo = [MPMediaItemPropertyArtwork : artwork,
                                           MPMediaItemPropertyTitle   : line.line,
                                           MPMediaItemPropertyArtist  : line.character.name,
                                  MPMediaItemPropertyPlaybackDuration : duration,
                                  
                                  MPNowPlayingInfoPropertyPlaybackRate : 1.0] as [String : Any]
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
                    }
                }
                self.lineLabel.text = self.line?.line
            }
        }
    }
    
    func initBackgroundAndLineLabel() {
        self.backgroundImageview.frame = self.view.bounds
        self.backgroundImageview.contentMode = UIView.ContentMode.scaleAspectFit
        self.view.addSubview(self.backgroundImageview)
        
        self.effectView.effect = UIBlurEffect.init(style: UIBlurEffect.Style.dark)
        self.effectView.frame = self.view.bounds
        self.view.addSubview(self.effectView)
        
        self.lineLabel.numberOfLines = 0
        self.lineLabel.frame = CGRect.init(x: 0, y: navigationBarHeight + 30, width: screenWidth, height: 10)
    }
    
    func initBtns() {
        let y = self.lineLabel.frame.maxY + 20
        let btnSquare : CGFloat = 40
        let space = (screenWidth - 3 * btnSquare) / 4
        var x = space
        
        self.favouriteBtn.frame = CGRect.init(x: x, y: y, width: btnSquare, height: btnSquare)
        self.view.addSubview(self.favouriteBtn)
        x += btnSquare
        x += space
        
        self.downloadBtn.frame = CGRect.init(x: x, y: y, width: btnSquare, height: btnSquare)
        self.view.addSubview(self.downloadBtn)
        x += btnSquare
        x += space
        
        self.panelBtn.frame = CGRect.init(x: x, y: y, width: btnSquare, height: btnSquare)
        self.view.addSubview(self.panelBtn)
    }
    
    func initPlaySlider() {
        let y = self.playToolBar.frame.minY - 5
        self.sliderWrapperView.frame = CGRect.init(x: 0, y: y - VoicePlayerController.sliderWrapperViewHeight, width: screenWidth, height: VoicePlayerController.sliderWrapperViewHeight)
        self.view.addSubview(self.sliderWrapperView)
        
        let labelWidth : CGFloat = 44
        let space : CGFloat = 18
        let sliderWidth = screenWidth - labelWidth * 2 - 3 * space
        var x = space
        
        self.startTimeLabel.frame = CGRect.init(x: x, y: 0, width: labelWidth, height: VoicePlayerController.sliderWrapperViewHeight)
        self.sliderWrapperView.addSubview(self.startTimeLabel)
        self.startTimeLabel.textColor = UIColor.white
        self.startTimeLabel.font = UIFont.PingFangSC_Regular(size: 12)
        self.startTimeLabel.textAlignment = NSTextAlignment.right
        self.startTimeLabel.text = "00:00"
        x += space * 0.5
        x += labelWidth
        
        self.slider.frame = CGRect.init(x: x, y: 0, width: sliderWidth, height: VoicePlayerController.sliderWrapperViewHeight)
        self.sliderWrapperView.addSubview(self.slider)
        self.slider.tintColor = UIColor.FlatUI.emerald
        self.slider.setThumbImage(UIImage.circularImageWithColor(UIColor.white, size: 10), for: UIControl.State.normal)
        self.slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        self.slider.addTarget(self, action: #selector(sliderTouchupInside(_:)), for: .touchUpInside)
        self.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        x += sliderWidth
        x += space * 0.5
        
        self.endTimeLabel.frame = CGRect.init(x: x, y: 0, width: labelWidth, height: VoicePlayerController.sliderWrapperViewHeight)
        self.endTimeLabel.textColor = self.startTimeLabel.textColor
        self.endTimeLabel.font = self.startTimeLabel.font
        self.endTimeLabel.textAlignment = NSTextAlignment.left
        self.endTimeLabel.text = "00:00"
        self.sliderWrapperView.addSubview(self.endTimeLabel)
    }
    
    // MARK: UISlider Delegate
    
    @objc func sliderTouchDown(_ slider : UISlider) {
        let player = Player.player
        player.player?.pause()
        player.removeTimer()
    }
    
    @objc func sliderTouchupInside(_ slider : UISlider) {
        let player = Player.player
        player.player?.play()
        player.fireTimer()
    }
    
    @objc func sliderValueChanged(_ slider : UISlider) {
        if let player = Player.player.player {
            let progress = slider.value
            let timeinterval = player.duration * Double(progress)
            player.currentTime = timeinterval
            
            self.startTimeLabel.text = TimeState.init(Double(progress) * Player.player.player!.duration).timeState
        }
    }
    
    // MARK: PlayToolBarDelegate
    
    func playtoolbarDidClickFavouriteButton(_ playtoolbar: PlayToolBar, btn: UIButton) {
        let line = self.line!
        
        if !btn.isSelected {
            Favourites.sharedInstance.persist(line, completion: { (success) in
                if success {
                    btn.isSelected = true
                }
            })
        } else {
            Favourites.sharedInstance.unpersist(line) { (success) in
                if success {
                    btn.isSelected = false
                }
            }
        }
    }
    
    @objc func playtoolbarDidClickLastButton(_ playtoolbar: PlayToolBar, btn: UIButton) {
//        let mode = Player.player.playMode
//        Player.player.playMode = .ListLoop
        Player.player.playPrevious()
//        Player.player.playMode = mode
    }
    
    func playtoolbarDidClickPlayPauseButton(_ playtoolbar: PlayToolBar, btn: UIButton) {
        if let player = Player.player.player {
            if btn.isSelected {
                player.pause()
                Player.player.removeTimer()
            } else {
                player.play()
                Player.player.fireTimer()
            }
        } else {
            btn.isSelected = false
        }
    }
    
    @objc func playtoolbarDidClickNextButton(_ playtoolbar: PlayToolBar, btn: UIButton) {
//        let mode = Player.player.playMode
//        Player.player.playMode = .ListLoop
        Player.player.playNext()
//        Player.player.playMode = mode
    }
    
    func playtoolbarDidClickPlayModeButton(_ playtoolbar: PlayToolBar, btn: PlayModeButton) {
        let mode = btn.changeMode()
        Player.player.playMode = mode
    }
    
    // MARK: PlayerDelegate
    func playerDidPlayAtProgress(_ player: Player, progress: Double) {
        self.startTimeLabel.text = TimeState.init(progress * Player.player.player!.duration).timeState
        self.slider.value = Float(progress)
    }
    
    func playerWillPlayNextItem(_ player: Player, next: LineModel) {
        self.line = next
        self.updateUI()
    }
    
    func playerWillPlayPreviousItem(_ player : Player, previous : LineModel) {
        self.line = previous
        self.updateUI()
    }
}
