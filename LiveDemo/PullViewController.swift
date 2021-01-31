//
//  PullViewController.swift
//  LiveDemo
//
//  Created by soal on 2021/1/26.
//  Copyright © 2021 soso. All rights reserved.
//

import UIKit
import SnapKit
import IJKMediaFramework

final class PullViewController: UIViewController {
    
    var url: String = ""
    
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet private weak var backButton: UIButton!
    
    @IBOutlet private weak var playButton: UIButton!
    
    @IBOutlet weak var backButtonTop: NSLayoutConstraint!
    
    private var mediaPlayer: IJKMediaPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            if view.safeAreaInsets.top > 20 {
                backButtonTop.constant = 0
            } else {
                backButtonTop.constant = 20
            }
        } else {
            backButtonTop.constant = 20
        }
        
        loadMedia()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        mediaPlayer?.prepareToPlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        mediaPlayer?.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mediaPlayer?.shutdown()
    }
}

extension PullViewController {
    
    @IBAction private func backButtonTouched(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func playButtonTouched(_ sender: UIButton) {
        guard let `mediaPlayer` = mediaPlayer else { return }
        if mediaPlayer.isPlaying() {
            mediaPlayer.pause()
            playButton.setImage(UIImage(named: "btn_play"), for: .normal)
        } else {
            mediaPlayer.play()
            playButton.setImage(UIImage(named: "btn_pause"), for: .normal)
        }
    }
}

extension PullViewController {
    
    private func loadMedia() {
        
        guard let `url` = URL(string: url) else {
            return
        }
        
        IJKFFMoviePlayerController.setLogReport(isDebug)
        IJKFFMoviePlayerController.setLogLevel(isDebug ? k_IJK_LOG_DEBUG : k_IJK_LOG_INFO)
        IJKFFMoviePlayerController.checkIfFFmpegVersionMatch(true)
        
        let options: IJKFFOptions = .byDefault()
        
        options.setPlayerOptionValue("tcp", forKey: "rtsp_transport")
        
        options.setPlayerOptionIntValue(3, forKey: "reconnect")
        
        //播放前的探测时间
        options.setPlayerOptionIntValue(1, forKey: "analyzeduration")
        
        options.setPlayerOptionIntValue(100, forKey: "analyzemaxduration")
        options.setPlayerOptionIntValue(200, forKey: "probesize")
        options.setPlayerOptionIntValue(0, forKey: "http-detect-range-support")
        options.setPlayerOptionIntValue(1, forKey: "dns_cache_clear")
        options.setPlayerOptionIntValue(1, forKey: "mediacodec-hevc")
        options.setPlayerOptionIntValue(1, forKey: "flush_packets")
        options.setPlayerOptionIntValue(1, forKey: "start-on-prepared")
        options.setPlayerOptionIntValue(1, forKey: "fast")
        
        options.setPlayerOptionIntValue(Int64(IJK_AVDISCARD_ALL.rawValue), forKey: "skip_loop_filter")
        options.setPlayerOptionIntValue(Int64(IJK_AVDISCARD_DEFAULT.rawValue), forKey: "skip_frame")
        
        let player = IJKMediaPlayer(url: url, options: options)
        player.setPauseInBackground(false)
        player.shouldAutoplay = true
        mediaPlayer = player
        
        player.view.frame = contentView.bounds
        contentView.addSubview(player.view)
        player.view.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
