//
//  HintViewController.swift
//  hyakko
//
//  Created by Monzy Zhang on 26/05/2017.
//  Copyright © 2017 MonzyZhang. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class HintViewController: UIViewController {
    lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.textColor = .yellow
        label.text = "请在隐私中心允许hyakko访问麦克风"
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(hintLabel)

        hintLabel.snp.makeConstraints { make in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(10, 10, 10, 10))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}
