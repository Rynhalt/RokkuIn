// BlockListHomeView.swift
import SwiftUI
import FamilyControls

public struct BlockListHomeView: View {
    @ObservedObject var blockingStore: BlockingStore
    @ObservedObject var shieldManager: ShieldManager

    @State private var showPicker = false
    @State private var showList = false

    public init(blockingStore: BlockingStore, shieldManager: ShieldManager) {
        self.blockingStore = blockingStore
        self.shieldManager = shieldManager
    }

    public var body: some View {
        List {
            Section {
                Button("Add websites to block") { showPicker = true }
                Button("Re-apply restrictions") { shieldManager.apply(blockedTokens: blockingStore.blocked) }
            }
            Section("Summary") {
                Text("Blocking \(blockingStore.blocked.count) website(s)")
            }
            if showList {
                Section("Blocked (read-only)") {
                    ForEach(Array(blockingStore.blocked), id: \.self) { token in
                        Text(String(describing: token))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("RokkuInn")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(showList ? "Hide List" : "Show List") { showList.toggle() }
            }
        }
        .sheet(isPresented: $showPicker) {
            WebDomainPickerSheet { tokens in
                blockingStore.merge(new: tokens)
                shieldManager.apply(blockedTokens: blockingStore.blocked)
            }
        }
    }
}

#Preview { NavigationStack { BlockListHomeView(blockingStore: BlockingStore(), shieldManager: ShieldManager()) } }
