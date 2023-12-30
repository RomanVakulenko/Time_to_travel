//
//  Animate.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 06.10.2023.
//

import Foundation
import UIKit

enum Animate {

    static func like(_ object: UIButton) {
        UIView.animateKeyframes(
            withDuration: 0.5,
            delay: 0,
            options: [],
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                    object.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    object.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                    object.transform = CGAffineTransform.identity
                }
            })
    }

    static func dislike(_ object: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            object.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            object.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    object.setImage(UIImage(systemName: "heart"), for: .normal)
                    object.transform = CGAffineTransform.identity
                }
            }
    }

}
