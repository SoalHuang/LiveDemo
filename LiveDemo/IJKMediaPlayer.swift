//
//  IJKMediaPlayer.swift
//  Sophon
//
//  Created by soal on 2021/1/22.
//  Copyright © 2021 sunlands-zf. All rights reserved.
//

import UIKit
import SnapKit
import IJKMediaFramework

#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif

@objc
final class IJKMediaPlayer: NSObject {
    
    let player: IJKFFMoviePlayerController
    
    deinit {
        removeObservers()
    }
    
    init(url: URL, options: IJKFFOptions = IJKFFOptions.byDefault()) {
        
        IJKFFMoviePlayerController.setLogReport(isDebug)
        IJKFFMoviePlayerController.setLogLevel(isDebug ? k_IJK_LOG_DEBUG : k_IJK_LOG_INFO)
        IJKFFMoviePlayerController.checkIfFFmpegVersionMatch(true)
        
        player = IJKFFMoviePlayerController(contentURL: url, with: options)
        player.scalingMode = .aspectFit
        player.shouldAutoplay = true
        player.view.backgroundColor = .clear
        
        super.init()
        
        setup()
        
        addObservers()
        
//        refreshDurationsLoop()
    }
    
    private func setup() {
        
        view.addSubview(playableProgressView)
        view.addSubview(progressView)
        view.addSubview(indicatorView)
        
        layout()
    }
    
    private func layout() {
        playableProgressView.snp.makeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0)
            $0.height.equalTo(2)
        }
        progressView.snp.makeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0)
            $0.height.equalTo(2)
        }
        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private lazy var playableProgressView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        temp.isUserInteractionEnabled = false
        return temp
    }()
    
    private lazy var progressView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.blue.withAlphaComponent(0.75)
        temp.isUserInteractionEnabled = false
        return temp
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let temp = UIActivityIndicatorView(style: .large)
            temp.color = UIColor.lightGray.withAlphaComponent(0.5)
            temp.hidesWhenStopped = true
            return temp
        } else {
            let temp = UIActivityIndicatorView(style: .whiteLarge)
            temp.color = UIColor.lightGray.withAlphaComponent(0.5)
            temp.hidesWhenStopped = true
            return temp
        }
    }()
    
    private var totalDuration: TimeInterval = 0
}

extension IJKMediaPlayer {
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadStateDidChange(_:)),
                                               name: .IJKMPMoviePlayerLoadStateDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(preparedToPlayDidChange(_:)),
                                               name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playbackStateDidChange(_:)),
                                               name: .IJKMPMoviePlayerPlaybackStateDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playbackDidFinish(_:)),
                                               name: .IJKMPMoviePlayerPlaybackDidFinish,
                                               object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerLoadStateDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackDidFinish, object: nil)
    }
    
    @objc
    private func loadStateDidChange(_ notification: Notification) {
        print("###### load state: \(player.loadState.rawValue)")
        switch player.loadState {
        case .playable: break
        case .playthroughOK: break
        case .stalled: indicatorView.startAnimating()
        default: break
        }
    }
    
    @objc
    private func preparedToPlayDidChange(_ notification: Notification) {
        print("###### prepared to play: \(player.isPreparedToPlay)")
        indicatorView.stopAnimating()
    }
    
    @objc
    private func playbackStateDidChange(_ notification: Notification) {
        print("###### playback state: \(player.playbackState.rawValue)")
        switch player.playbackState {
        case .stopped, .playing:
            indicatorView.stopAnimating()
        case .paused: break
        case .interrupted, .seekingForward, .seekingBackward:
            indicatorView.startAnimating()
        default: break
        }
    }
    
    @objc
    private func playbackDidFinish(_ notification: Notification) {
        print("###### playback finish")
        indicatorView.stopAnimating()
    }
}

extension IJKMediaPlayer {
    
    @objc
    private func refreshDurationsLoop() {
        
        if totalDuration <= 0 {
            totalDuration = player.duration
        }
        
        guard totalDuration > 0 else {
            perform(#selector(refreshDurationsLoop), with: nil, afterDelay: 0.5)
            return
        }
        
        playableProgressView.snp.remakeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(player.playableDuration / totalDuration)
            $0.height.equalTo(2)
        }
        progressView.snp.remakeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(player.currentPlaybackTime / totalDuration)
            $0.height.equalTo(2)
        }
        
        perform(#selector(refreshDurationsLoop), with: nil, afterDelay: 0.5)
    }
}

extension IJKMediaPlayer: IJKMediaPlayback {
    
    var view: UIView! {
        player.view
    }
    
    func prepareToPlay() {
        player.prepareToPlay()
        indicatorView.startAnimating()
    }
    
    func play() {
        player.play()
        indicatorView.startAnimating()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.stop()
    }
    
    func isPlaying() -> Bool {
        player.isPlaying()
    }
    
    func shutdown() {
        removeObservers()
        player.shutdown()
    }
    
    func setPauseInBackground(_ pause: Bool) {
        player.setPauseInBackground(pause)
    }
    
    var currentPlaybackTime: TimeInterval {
        get { player.currentPlaybackTime }
        set { player.currentPlaybackTime = newValue }
    }
    
    var duration: TimeInterval {
        player.duration
    }
    
    var playableDuration: TimeInterval {
        player.playableDuration
    }
    
    var bufferingProgress: Int {
        player.bufferingProgress
    }
    
    var isPreparedToPlay: Bool {
        player.isPreparedToPlay
    }
    
    var playbackState: IJKMPMoviePlaybackState {
        player.playbackState
    }
    
    var loadState: IJKMPMovieLoadState {
        player.loadState
    }
    
    var isSeekBuffering: Int32 {
        player.isSeekBuffering
    }
    
    var isAudioSync: Int32 {
        player.isAudioSync
    }
    
    var isVideoSync: Int32 {
        player.isVideoSync
    }
    
    var numberOfBytesTransferred: Int64 {
        player.numberOfBytesTransferred
    }
    
    var naturalSize: CGSize {
        player.naturalSize
    }
    
    var scalingMode: IJKMPMovieScalingMode {
        get { player.scalingMode }
        set { player.scalingMode = newValue }
    }
    
    var shouldAutoplay: Bool {
        get { player.shouldAutoplay }
        set { player.shouldAutoplay = newValue }
    }
    
    var allowsMediaAirPlay: Bool {
        get { player.allowsMediaAirPlay }
        set { player.allowsMediaAirPlay = newValue }
    }
    
    var isDanmakuMediaAirPlay: Bool {
        get { player.isDanmakuMediaAirPlay }
        set { player.isDanmakuMediaAirPlay = newValue }
    }
    
    var airPlayMediaActive: Bool {
        player.airPlayMediaActive
    }
    
    var playbackRate: Float {
        get { player.playbackRate }
        set { player.playbackRate = newValue }
    }
    
    var playbackVolume: Float {
        get { player.playbackVolume }
        set { player.playbackVolume = newValue }
    }
    
    func thumbnailImageAtCurrentTime() -> UIImage! {
        player.thumbnailImageAtCurrentTime()
    }
}
