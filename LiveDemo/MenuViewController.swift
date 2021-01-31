//
//  MenuViewController.swift
//  LiveDemo
//
//  Created by soal on 2021/1/26.
//  Copyright © 2021 soso. All rights reserved.
//

import UIKit

final class MenuViewController: UIViewController {
    
    @IBOutlet private weak var textView: UITextView!
    
    @IBOutlet private weak var pushButton: UIButton!
    
    @IBOutlet private weak var pullButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "配置"
        textView.text = "rtmp://116.62.26.147/live/test131532"
//        textView.text = "http://172.16.117.226:801/newSkyNet/original/20201112/1605180689820.mp4"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension MenuViewController {
    
    private var urlAbsoluteString: String? {
        guard
            let encodingText = textView.text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodingText)
            else {
                return nil
        }
        return url.absoluteString
    }
    
    @IBAction private func pushButtonTouched(_ sender: UIButton) {
        guard let url = urlAbsoluteString else { return }
        let pushVC = PushViewController(nibName: "PushViewController", bundle: .main)
        pushVC.url = url
        navigationController?.pushViewController(pushVC, animated: true)
    }
    
    @IBAction private func pullButtonTouched(_ sender: UIButton) {
        guard let url = urlAbsoluteString else { return }
        let pullVC = PullViewController(nibName: "PullViewController", bundle: .main)
        pullVC.url = url
        navigationController?.pushViewController(pullVC, animated: true)
    }
}
