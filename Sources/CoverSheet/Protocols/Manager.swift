//
//  File.swift
//  
//
//  Created by Colin Walsh on 3/6/23.
//

import Foundation
import Combine
import SwiftUI

public protocol Manager: ObservableObject, CoverSheetDelegate {
    var states: [SheetState] { get set }
    var currentState: SheetState { get set }
    var currentStatePublisher: Published<SheetState>.Publisher { get }
    var currentStateConstant: CGFloat { get }
    init()
}
