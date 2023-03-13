//
//  SheetHeight.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation

public protocol SheetId: Identifiable, RawRepresentable {}

public enum SheetState: Equatable {
    typealias RawValue = CGFloat
    
    case cover
    case full
    case normal
    case collapsed
    case hidden
    case custom(_ id: any SheetId, _ value: CGFloat)
    
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
    
    func getIdentifier<T>() -> T where T:Identifiable {
        switch self {
        case .cover:
            return "cover" as! T
        case .full:
            return "full" as! T
        case .normal:
            return "normal" as! T
        case .collapsed:
            return "collapsed" as! T
        case .hidden:
            return "hidden" as! T
        case let .custom(id, _):
            return id as! T
        }
    }
    
    public static func == (lhs: SheetState, rhs: SheetState) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
