//
//  RecordViewController.swift
//  hyakko
//
//  Created by Monzy Zhang on 25/05/2017.
//  Copyright © 2017 MonzyZhang. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

let kButtonWidth: CGFloat = 70

class RecordViewController: UIViewController, RecordingButtonDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    var isPlaying = false

    var isRecording: Bool {
        return self.recordingButton.isRecording
    }

    // MARK: recorder & player
    lazy var recorder: AVAudioRecorder? = {
        // path
        var pathComponents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        pathComponents.append("temp.m4a")
        let outputURL = NSURL.fileURL(withPathComponents: pathComponents)

        // session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            return nil
        }
        let recordSettings = [
            AVFormatIDKey: NSNumber(integerLiteral: Int(kAudioFormatMPEG4AAC)),
            AVSampleRateKey: NSNumber(floatLiteral: 44100.0),
            AVNumberOfChannelsKey: NSNumber(integerLiteral: 2)
        ]
        do {
            let recorder = try AVAudioRecorder(url: outputURL!, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            return recorder
        } catch {
            return nil
        }
    }()

    var player: AVAudioPlayer?

    // MARK: views
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(displayP3Red: 0,
                                   green: 190.0/255.0,
                                   blue: 0,
                                   alpha: 1)
        button.setImage(UIImage(named: "play"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.isHidden = true
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        return button
    }()

    lazy var recordingButton: RecordingButton = {
        let button = RecordingButton(frame: CGRect(x: self.view.center.x - 52 / 2.0, y: self.view.frame.height - 52 - 30, width: 52, height: 52))
        button.delegate = self
        return button
    }()

    lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.isHidden = true
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "00:00"
        return label
    }()

    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: kButtonWidth, height: kButtonWidth)
        button.layer.cornerRadius = kButtonWidth / 2.0
        button.backgroundColor = UIColor(displayP3Red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1)

        var center = self.view.center
        center.y = self.view.bounds.height - kButtonWidth * 1.5
        button.center = center
        return button
    }()

    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: kButtonWidth, height: kButtonWidth)
        button.layer.cornerRadius = kButtonWidth / 2.0
        button.backgroundColor = .white

        var center = self.view.center
        center.y = self.view.bounds.height - kButtonWidth * 1.5
        button.center = center
        return button
    }()

    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let listButton = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(goToRecordList))
        navigationItem.rightBarButtonItem = listButton
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 74.0/255.0,
                                                                   green: 74.0/255.0,
                                                                   blue: 74.0/255.0,
                                                                   alpha: 1)
        view.backgroundColor = .black

        view.addSubview(playButton)
        view.addSubview(hintLabel)
        view.addSubview(timeLabel)

        view.addSubview(deleteButton)
        view.addSubview(saveButton)
        view.addSubview(recordingButton)

        setupConstraints()
    }

    private func setupConstraints() {
        playButton.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.width.equalTo(22)
            make.height.equalTo(40)
        }
        hintLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.playButton)
            make.top.equalTo(self.playButton.snp.bottom).offset(10)
        }
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.playButton)
            make.top.equalTo(self.hintLabel.snp.bottom).offset(10)
        }
    }

    // MARK: Action Handlers
    func goToRecordList() {
        navigationController?.pushViewController(RecordListViewController(), animated: true)
    }

    func play() {
        if isPlaying {
            // pause
            playButton.setImage(UIImage(named: "play"), for: .normal)
            player?.pause()
        } else {
            // play
            playButton.setImage(UIImage(named: "pause"), for: .normal)
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch {
            }
            if let player = player {
                if !player.isPlaying {
                    player.play()
                }
            } else if let recorder = recorder {
                do {
                    player = try AVAudioPlayer(contentsOf: recorder.url)
                    player?.delegate = self
                    player?.play()
                } catch {
                }
            }
        }
        isPlaying = !isPlaying
    }

    // MARK: RecordingButtonDelegate
    func didTouchesMoveOutOfButton(button: RecordingButton) {
        hintLabel.text = "松开取消"
    }

    func didTouchesMoveInsideButton(button: RecordingButton) {
        hintLabel.text = "松开完成"
    }

    // stop recording
    func didEndTouchInsideButton(button: RecordingButton) {
        hintLabel.text = "松开完成"
        hintLabel.isHidden = true

        recorder?.stop()

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            return
        }
    }

    // cancel recording
    func didEndTouchOutOfButton(button: RecordingButton) {
        hintLabel.text = "松开完成"
        hintLabel.isHidden = true
    }

    // start recording
    func didStartRecording(button: RecordingButton) {
        hintLabel.isHidden = false
        hintLabel.text = "松开完成"

        if let recorder = recorder {
            if !recorder.isRecording {
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch {
                    return
                }

                recorder.record()
            }
        }
    }

    // MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.isHidden = false
        hintLabel.isHidden = true

        let alertController = UIAlertController(title: nil, message: "finished", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 切换成暂停状态
        playButton.setImage(UIImage(named: "play"), for: .normal)
        isPlaying = false
    }
}
