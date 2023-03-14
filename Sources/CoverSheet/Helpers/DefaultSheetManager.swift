//
//  SheetManager.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation
import Combine

public class DefaultSheetManager: Manager {
    public typealias EnumValue = DefaultSheetState
    
    @Published
    public var currentState: EnumValue = .hidden
    
    public var currentStatePublisher: Published<EnumValue>.Publisher { $currentState }
    
    public var currentStateConstant: CGFloat {
        return currentState.rawValue
    }
    
    public required init() {}
}
