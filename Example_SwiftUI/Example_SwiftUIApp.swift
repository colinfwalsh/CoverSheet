//
//  Example_SwiftUIApp.swift
//  Example_SwiftUI
//
//  Created by Colin Walsh on 2/17/23.
//

import SwiftUI
import CoverSheet

@main
struct Example_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DefaultSheetManager())
        }
    }
}
