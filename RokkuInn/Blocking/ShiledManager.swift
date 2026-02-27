// ShieldManager.swift
import Foundation
import ManagedSettings
import FamilyControls
import Combine

/// Minimal adapter that writes the selected tokens into `ManagedSettingsStore`.
public final class ShieldManager: ObservableObject {
    private let store = ManagedSettingsStore()
    public init() {}

    /// Applies the provided tokens to Screen Time, completely replacing the previous set.
    public func apply(blockedTokens: Set<ManagedSettings.WebDomainToken>) {
        store.shield.webDomains = blockedTokens
    }
}
