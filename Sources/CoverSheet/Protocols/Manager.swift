//
//  File.swift
//  
//
//  Created by Colin Walsh on 3/6/23.
//

import Foundation
import SwiftUI

public protocol Manager: ObservableObject, CoverSheetDelegate {
    var sheetState: SheetState { get set }
    var stateConstant: CGFloat { get }
}
