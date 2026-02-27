//
//  RokkuInnApp.swift
//  RokkuInn
//
//  Created by Marcus Chang on 2026/02/26.
//

import SwiftUI

/// Application entry point that boots the single SwiftUI window scene.
@main
struct RokkuInnApp: App {
    var body: some Scene {
        WindowGroup {
            /// `ContentView` owns the long-lived managers for authorization, storage, and shielding.
            ContentView()
        }
    }
}
