//
//  SheetHeight.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation

public enum SheetState: Equatable {
    typealias RawValue = CGFloat
    
    case fullScreen
    case full
    case normal
    case minimized
    case closed
    case custom(CGFloat)
    
    var rawValue: CGFloat {
        switch self {
        case .fullScreen:
            return 1.0
        case .full:
            return 0.9
        case .normal:
            return 0.7
        case .minimized:
            return 0.35
        case .closed:
            return 0.10
        case let .custom(value):
            return value
        }
    }
}
