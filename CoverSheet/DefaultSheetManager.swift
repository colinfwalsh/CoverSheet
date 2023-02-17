//
//  SheetManager.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation
import Combine

public protocol Manager: ObservableObject {
    var sheetState: SheetState { get set }
    var sheetPublisher: Published<SheetState>.Publisher { get }
    var states: [SheetState] { get set }
    var stateConstant: CGFloat { get }
}

public class DefaultSheetManager: Manager {
    @Published
    public var sheetState: SheetState = .normal
    
    public var sheetPublisher: Published<SheetState>.Publisher { $sheetState }
    
    public var states: [SheetState] = [.minimized, .normal, .full]
    
    public var stateConstant: CGFloat {
        return sheetState.rawValue
    }
    
    public init() {}
}
