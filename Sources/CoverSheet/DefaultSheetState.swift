//
//  SheetHeight.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/15/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation

public enum DefaultSheetState: CGFloat, RawRepresentable, Equatable {
    case cover = 1.0
    case full = 0.9
    case normal = 0.7
    case collapsed = 0.35
    case hidden = 0.0
}
