//
//  VoiceNoteCell.swift
//  hyakko
//
//  Created by Monzy Zhang on 25/05/2017.
//  Copyright © 2017 MonzyZhang. All rights reserved.
//

import UIKit
import SnapKit

class VoiceNoteCell: UITableViewCell {
    var playing: Bool = false {
        didSet {
            if playing {
                playButton.setImage(UIImage(named: "pause"), for: .normal)
            } else {
                playButton.setImage(UIImage(named: "play"), for: .normal)
            }
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "play"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(playButton)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        playing = false
        titleLabel.text = ""
    }

    // MARK: private
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(10.0)
            make.centerY.equalTo(self.contentView)
            make.right.lessThanOrEqualTo(self.playButton.snp.left).offset(-5.0)
        }
        playButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(10.0)
            make.bottom.equalTo(self.contentView).offset(-10.0)
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-10.0)
        }
    }
}
