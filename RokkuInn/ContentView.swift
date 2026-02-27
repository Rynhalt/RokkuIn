//
//  ContentView.swift
//  RokkuInn
//
//  Created by Marcus Chang on 2026/02/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("RokkuInn")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Hello! Build succeeds when you see this screen on device.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
