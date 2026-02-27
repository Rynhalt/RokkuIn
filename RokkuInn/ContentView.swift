//
//  ContentView.swift
//  RokkuInn
//
//  Created by Marcus Chang on 2026/02/26.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @StateObject private var auth = AuthorizationManager()
    @StateObject private var blockingStore = BlockingStore()
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
                                blockingStore.loadBlocked()
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
                blockingStore.loadBlocked()
                shieldManager.apply(blockedTokens: blockingStore.blocked)
            }
        }
    }
}

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
                    await auth.requestAuthorization()
                }
            }

            Text(statusText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

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
