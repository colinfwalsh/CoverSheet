//
//  ReloadableController.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/16/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

public protocol Containable: UIViewController {
    var hostingViewController: UIViewController? { get set }
    func configure(_ view: some View)
    func update<Content: View>(_ view: Content)
}
