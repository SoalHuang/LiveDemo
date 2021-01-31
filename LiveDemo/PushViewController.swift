//
//  PushViewController.swift
//  LiveDemo
//
//  Created by soal on 2021/1/26.
//  Copyright © 2021 soso. All rights reserved.
//

import UIKit
import AVFoundation
import LFLiveKit

final class PushViewController: UIViewController {
    
    var url: String = ""
    
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet private weak var backButton: UIButton!
    
    @IBOutlet private weak var camraButton: UIButton!
    
    @IBOutlet private weak var playButton: UIButton!
    
    @IBOutlet private weak var messageLabel: UILabel!
    
    @IBOutlet private weak var statusLabel: UILabel!
    
    @IBOutlet private weak var backButtonTop: NSLayoutConstraint!
    
    deinit {
        
    }
    
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
        
        requestVideoAccess()
        requestAudioAccess()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private lazy var session: LFLiveKit.LFLiveSession = {
        let audioConfig = LFLiveAudioConfiguration.defaultConfiguration(for: .high)
        let videoConfig = LFLiveVideoConfiguration.defaultConfiguration(for: .low3)
        let temp = LFLiveKit.LFLiveSession(audioConfiguration: audioConfig,
                                           videoConfiguration: videoConfig)!
        temp.delegate = self
        temp.preView = contentView
        return temp
    }()
    
    private var info: LFLiveStreamInfo {
        let info = LFLiveStreamInfo()
        info.url = url
        return info
    }
    
    private var isLiving: Bool = false {
        didSet {
            playButton.setImage(UIImage(named: isLiving ? "btn_pause" : "btn_record"), for: .normal)
        }
    }
}

extension PushViewController {
    
    private func requestVideoAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: .video);
        if status ~= .authorized {
            session.running = true
            return
        }
        guard case .notDetermined = status else { return }
        AVCaptureDevice.requestAccess(for: .video) { [weak self] in
            guard $0 else { return }
            DispatchQueue.main.async {
                self?.session.running = true
            }
        }
    }
    
    private func requestAudioAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        guard case .notDetermined = status else { return }
        AVCaptureDevice.requestAccess(for: .audio) { _ in }
    }
}

extension PushViewController {
    
    @IBAction private func backButtonTouched(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func playButtonTouched(_ sender: UIButton) {
        isLiving.toggle()
        if isLiving {
            session.startLive(info)
        } else {
            session.stopLive()
        }
    }
    
    @IBAction private func camraButtonTouched(_ sender: UIButton) {
        session.captureDevicePosition = session.captureDevicePosition ~= .front ? .back : .front
    }
}

extension PushViewController: LFLiveKit.LFLiveSessionDelegate {
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        statusLabel.text = state.desc
    }
    
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        messageLabel.text = errorCode.desc
    }
}

extension LFLiveState {
    
    var desc: String {
        switch self {
        case .ready:        return "准备"
        case .pending:      return "连接中"
        case .start:        return "已连接"
        case .stop:         return "已断开"
        case .error:        return "连接出错"
        case .refresh:      return "正在刷新"
        @unknown default:   return "未知"
        }
    }
}

extension LFLiveSocketErrorCode {
    
    var desc: String {
        switch self {
        case .preView:          return "预览失败"
        case .getStreamInfo:    return "获取流媒体信息失败"
        case .connectSocket:    return "连接socket失败"
        case .verification:     return "验证服务器失败"
        case .reConnectTimeOut: return "重新连接服务器超时"
        @unknown default:       return "未知"
        }
    }
}
