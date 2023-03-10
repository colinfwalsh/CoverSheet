//
//  SheetHeight.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation

public enum SheetState: Identifiable, Equatable {
    typealias RawValue = CGFloat
    
    case cover
    case full
    case normal
    case collapsed
    case hidden
    case custom(_ id: String, _ value: CGFloat)
    
    public var rawValue: CGFloat {
        switch self {
        case .cover:
            return 1.0
        case .full:
            return 0.9
        case .normal:
            return 0.7
        case .collapsed:
            return 0.35
        case .hidden:
            return 0.0
        case let .custom(_, value):
            return value
        }
    }
    
    public var id: String {
        switch self {
        case .cover:
            return "cover"
        case .full:
            return "full"
        case .normal:
            return "normal"
        case .collapsed:
            return "collapsed"
        case .hidden:
            return "hidden"
        case let .custom(id, _):
            return "custom_" + id
        }
    }
}
