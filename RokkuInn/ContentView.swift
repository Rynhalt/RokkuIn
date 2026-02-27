//
//  ContentView.swift
//  RokkuInn
//
//  Created by Marcus Chang on 2026/02/26.
//

import SwiftUI
import FamilyControls

/// Root view that controls whether the authorization gate or the block list UI is visible.
struct ContentView: View {
    /// Persistent authorization manager instance so state changes propagate across refreshes.
    @StateObject private var auth = AuthorizationManager()
    /// Stores the saved domain tokens and pushes updates into the UI hierarchy.
    @StateObject private var blockingStore = BlockingStore()
    /// Applies the selected tokens to the device-wide Screen Time shield.
    @StateObject private var shieldManager = ShieldManager()

    var body: some View {
        ZStack {
#if canImport(UIKit)
            Color(uiColor: .systemBackground)
#elseif canImport(AppKit)
            Color(nsColor: .windowBackgroundColor)
#else
            Color(.white)
#endif

            Group {
                switch auth.state {
                case AuthorizationState.authorized:
                    NavigationStack {
                        BlockListHomeView(blockingStore: blockingStore, shieldManager: shieldManager)
                            .onAppear {
                                // Sync the persisted block list every time the view becomes visible.
                                blockingStore.loadBlocked()
                                // Ensure the Managed Settings store mirrors the latest tokens.
                                shieldManager.apply(blockedTokens: blockingStore.blocked)
                            }
                    }
                default:
                    AuthorizationGateView(auth: auth)
                }
            }
        }
        .task(id: auth.state) {
            if auth.state == AuthorizationState.authorized {
                // Authorization just flipped to `authorized`, so reload the cache and reapply shields.
                blockingStore.loadBlocked()
                shieldManager.apply(blockedTokens: blockingStore.blocked)
            }
        }
    }
}

/// Simple explanatory screen that prompts the user to grant Screen Time access.
struct AuthorizationGateView: View {
    @ObservedObject var auth: AuthorizationManager

    var body: some View {
        VStack(spacing: 16) {
            Text("Screen Time Access Required")
                .font(.title2)
                .bold()

            Text("Enable Screen Time access to add and block websites.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Enable Screen Time Access") {
                Task {
                    // The authorization request is asynchronous, so wrap it in a Task.
                    await auth.requestAuthorization()
                }
            }

            Text(statusText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    /// Human-readable description of the authorization state shown under the button.
    private var statusText: String {
        switch auth.state {
        case .unknown: return "Not determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        }
    }
}

#Preview {
    ContentView()
}
