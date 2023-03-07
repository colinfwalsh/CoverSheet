//
//  SheetHeight.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation

public enum SheetState: Equatable, Comparable {
    typealias RawValue = CGFloat
    
    case cover
    case full
    case normal
    case minimized
    case custom(CGFloat)
    
    var rawValue: CGFloat {
        switch self {
        case .cover:
            return 1.0
        case .full:
            return 0.9
        case .normal:
            return 0.7
        case .minimized:
            return 0.35
        case let .custom(value):
            return value
        }
    }
}
