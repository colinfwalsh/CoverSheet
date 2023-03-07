//
//  File.swift
//  
//
//  Created by Colin Walsh on 3/7/23.
//

import Foundation
import UIKit

public struct AnimationConfig {
    let timing: CGFloat
    let options: UIView.AnimationOptions
    let springDamping: CGFloat
    let springVelocity: CGFloat
    
    init(timing: CGFloat = 0.1,
         options: UIView.AnimationOptions = [.curveLinear],
         springDamping: CGFloat = 2.0,
         springVelocity: CGFloat = 7.0) {
        self.timing = timing
        self.options = options
        self.springDamping = springDamping
        self.springVelocity = springVelocity
    }
}
