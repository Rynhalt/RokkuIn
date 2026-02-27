// WebDomainPickerSheet.swift
import SwiftUI
import FamilyControls

public typealias WebDomainToken = FamilyControls.WebDomain

public struct WebDomainPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    public let onPicked: (Set<WebDomainToken>) -> Void
    @State private var selection = FamilyActivitySelection()

    public init(onPicked: @escaping (Set<WebDomainToken>) -> Void) { self.onPicked = onPicked }

    public var body: some View {
        NavigationStack {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Select Websites")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            onPicked(selection.webDomains)
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview { WebDomainPickerSheet { _ in } }

