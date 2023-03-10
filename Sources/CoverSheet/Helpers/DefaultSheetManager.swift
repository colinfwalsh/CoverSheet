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
    @Published
    public var currentState: SheetState = .hidden
    
    public var currentStatePublisher: Published<SheetState>.Publisher { $currentState }
    
    public var states: [SheetState] = [.collapsed, .normal, .full]
    
    public var currentStateConstant: CGFloat {
        return currentState.rawValue
    }
    
    public func coverSheet(currentState: SheetState) {
        self.currentState = currentState
    }
    
    public required init() {}
}
