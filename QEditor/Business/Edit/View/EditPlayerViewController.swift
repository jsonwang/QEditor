//
//  EditPlayerViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/13.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation


class EditPlayerViewController: UIViewController {
    
    public var presenter: (EditViewPresenterInput & EditPlayerViewOutput)!
    
    private var duration: Int64 = 0
    
    private var model: MediaVideoModel?

    override public func viewDidLoad() {
        super.viewDidLoad()
        initView()
        timeLabel.text = String.qe.formatTime(0) + "/" + String.qe.formatTime(Int(duration))
    }
    
    private func initView() {
        view.backgroundColor = .black
        view.addSubview(playerView)
        view.addSubview(toolBar)
        toolBar.addSubview(playButton)
        toolBar.addSubview(timeLabel)
        
        playerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.toolBar.snp.top)
        }
        
        toolBar.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(44)
        }
        
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(self.toolBar)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(SCREEN_PADDING_X)
            make.centerY.equalTo(self.toolBar)
        }
    }
    
    @objc
    func didClickPlayButton() {
        if playerView.status == .playing {
            playButton.setImage(UIImage(named: "edit_play"), for: .normal)
            playerView.pause()
        } else {
            playButton.setImage(UIImage(named: "edit_pause"), for: .normal)
            playerView.play()
        }
    }
    
    lazy var playerView: PlayerView = {
        let view = PlayerView()
        view.delegate = self
        return view
    }()
    
    lazy var toolBar: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_play"), for: .normal)
        view.addTarget(self, action: #selector(didClickPlayButton), for: .touchUpInside)
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = .systemFont(ofSize: 13)
        return view
    }()

}

extension EditPlayerViewController: PlayerViewDelegate {
    
    public func player(_ player: PlayerView, didChange status: AVPlayerItem.Status) {
        
    }
    
    public func player(_ player: PlayerView, playAt time: Int64) {
        let timeFormat = String.qe.formatTime(Int(time))
        timeLabel.text = "\(timeFormat)/" + String.qe.formatTime(Int(duration))
    }
    
    public func player(_ player: PlayerView, didLoadVideoWith duration: Int64) {
        self.duration = duration
        timeLabel.text = String.qe.formatTime(0) + "/" + String.qe.formatTime(Int(duration))
    }
    
}

extension EditPlayerViewController: EditPlayerViewInput {
    
    func setup(model: MediaVideoModel) {
        self.model = model
        playerView.setupPlayer(with: model.url!)
    }
    
}