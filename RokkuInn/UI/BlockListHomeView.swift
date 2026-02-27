// BlockListHomeView.swift
import SwiftUI
import Combine
import FamilyControls
import ManagedSettings

/// Primary Screen Time management UI shown after authorization succeeds.
public struct BlockListHomeView: View {
    @ObservedObject var blockingStore: BlockingStore
    @ObservedObject var shieldManager: ShieldManager

    /// Controls presentation of the Family Activity picker sheet.
    @State private var showPicker = false
    /// Toggles the optional debug list of blocked tokens.
    @State private var showList = false

    public init(blockingStore: BlockingStore, shieldManager: ShieldManager) {
        self.blockingStore = blockingStore
        self.shieldManager = shieldManager
    }

    public var body: some View {
        List {
            // Primary actions for adding and reapplying restrictions.
            Section {
                Button("Add websites to block") { showPicker = true }
                Button("Re-apply restrictions") { shieldManager.apply(blockedTokens: blockingStore.blocked) }
            }
            Section("Summary") {
                Text("Blocking \(blockingStore.blocked.count) website(s)")
            }
            // Optional debug/read-only context for the exact tokens stored locally.
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
                // Merge newly picked domains into the store and re-apply shielding
                blockingStore.merge(new: tokens)
                shieldManager.apply(blockedTokens: tokens)
            }
        }
    }
}

#Preview { NavigationStack { BlockListHomeView(blockingStore: BlockingStore(), shieldManager: ShieldManager()) } }
