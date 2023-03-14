//
//  SheetHeight.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation

public enum DefaultSheetState: RawRepresentable, Equatable {
    public init?(rawValue: CGFloat) {
        switch rawValue {
        case 1.0:
            self = .cover
        case 0.9:
            self = .full
        case 0.7:
            self = .normal
        case 0.35:
            self = .collapsed
        default:
            self = .hidden
        }
    }
    
    case cover
    case full
    case normal
    case collapsed
    case hidden
    
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
        }
    }
    
    public static func == (lhs: DefaultSheetState, rhs: DefaultSheetState) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
