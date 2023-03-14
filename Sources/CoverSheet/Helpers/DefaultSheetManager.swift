//
//  SheetManager.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation
import Combine

public class DefaultSheetManager: Manager, CoverSheetDelegate {
    public typealias EnumValue = DefaultSheetState
    
    @Published
    public var currentState: EnumValue = .hidden
    
    @Published
    public var sheetHeight: CGFloat = 0.0
    
    public var currentStatePublisher: Published<EnumValue>.Publisher { $currentState }
    
    public func coverSheet(sheetHeight: CGFloat) {
        self.sheetHeight = sheetHeight
    }
    
    public var currentStateConstant: CGFloat {
        return currentState.rawValue
    }
    
    public required init() {}
}
