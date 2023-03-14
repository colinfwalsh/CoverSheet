//
//  File.swift
//  
//
//  Created by Colin Walsh on 3/6/23.
//

import Foundation
import Combine
import SwiftUI

public protocol Manager: ObservableObject {
    associatedtype EnumValue: RawRepresentable where EnumValue.RawValue == CGFloat
    
    var currentState: EnumValue { get set }
    var currentStatePublisher: Published<EnumValue>.Publisher { get }
    var currentStateConstant: CGFloat { get }
    init()
}
