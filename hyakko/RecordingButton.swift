//
//  RecordingButton.swift
//  hyakko
//
//  Created by Monzy Zhang on 25/05/2017.
//  Copyright © 2017 MonzyZhang. All rights reserved.
//

import UIKit

@objc protocol RecordingButtonDelegate {
    @objc optional func didTouchesMoveOutOfButton(button: RecordingButton)
    @objc optional func didTouchesMoveInsideButton(button: RecordingButton)

    @objc optional func didEndTouchInsideButton(button: RecordingButton)
    @objc optional func didEndTouchOutOfButton(button: RecordingButton)

    @objc optional func didStartRecording(button: RecordingButton)
}

class RecordingButton: UIView {

    weak var delegate: RecordingButtonDelegate?

    var isRecording = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.borderColor = UIColor(displayP3Red: 80.0/255.0,
                                    green: 227.0/255.0,
                                    blue: 194.0/255.0,
                                    alpha: 1).cgColor
        layer.borderWidth = 4.0
        layer.cornerRadius = frame.width / 2.0
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: public
    func reset(animated: Bool, handler: (() -> ())?) {
        isRecording = false

        let duration = 0.5

        UIView.animate(withDuration: duration, animations: {
            self.transform = .identity
            self.alpha = 1
        }) { finished in
            if let handler = handler {
                handler()
            }
        }

        startBorderWidthAnimation(fromValue: 15, toValue: 4, duration: duration)
    }

    // MARK: touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isRecording = true

        // animate to recording state
        let duration = 0.5
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 2, y: 2)
        }) { finished in
            self.delegate?.didStartRecording?(button: self)
        }
        startBorderWidthAnimation(fromValue: 4, toValue: 15, duration: duration)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if let previousPoint = touches.first?.previousLocation(in: self), let point = touches.first?.location(in: self) {
            let isPreviousPointInside = self.point(inside: previousPoint, with: event)
            let isCurrentPointInside = self.point(inside: point, with: event)

            if isPreviousPointInside && !isCurrentPointInside {
                self.delegate?.didTouchesMoveOutOfButton?(button: self)
            } else if !isPreviousPointInside && isCurrentPointInside {
                self.delegate?.didTouchesMoveInsideButton?(button: self)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isRecording = false
        let isInside = self.point(inside: (touches.first?.location(in: self))!, with: event)
        if isInside {
            let duration = 0.5
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.alpha = 0
            }) { finished in
                self.delegate?.didEndTouchInsideButton?(button: self)
            }
        } else {
            reset(animated: true, handler: {
                self.delegate?.didEndTouchOutOfButton?(button: self)
            })
        }
    }

    // MARK: private
    private func startBorderWidthAnimation(fromValue from: CGFloat, toValue to: CGFloat, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = from
        animation.toValue = to
        animation.isRemovedOnCompletion = true
        layer.add(animation, forKey: "borderWidth")
        layer.borderWidth = to
    }
}
