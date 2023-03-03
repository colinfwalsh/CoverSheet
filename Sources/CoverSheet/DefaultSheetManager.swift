//
//  SheetManager.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation
import Combine

public protocol Manager: ObservableObject, CoverSheetDelegate {
    var sheetState: SheetState { get set }
    var stateConstant: CGFloat { get }
}

public class DefaultSheetManager: Manager {
    @Published
    public var sheetState: SheetState = .normal
    
    public var stateConstant: CGFloat {
        return sheetState.rawValue
    }
    
    public func coverSheet(currentState: SheetState) {
        self.sheetState = currentState
    }
    
    public init() {}
}
