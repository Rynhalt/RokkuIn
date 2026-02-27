// WebDomainPickerSheet.swift
import SwiftUI
import FamilyControls
import ManagedSettings

/// Thin wrapper around `FamilyActivityPicker` that returns selected web domain tokens.
public struct WebDomainPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    /// Callback invoked when the user confirms their selection.
    public let onPicked: (Set<ManagedSettings.WebDomainToken>) -> Void
    /// Local binding that keeps track of the most recent picker state.
    @State private var selection = FamilyActivitySelection()

    public init(onPicked: @escaping (Set<ManagedSettings.WebDomainToken>) -> Void) { self.onPicked = onPicked }

    public var body: some View {
        NavigationStack {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Select Websites")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            // Send only the tokens (the shield API does not need the resolved domains).
                            onPicked(selection.webDomainTokens)
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview { WebDomainPickerSheet { _ in } }
