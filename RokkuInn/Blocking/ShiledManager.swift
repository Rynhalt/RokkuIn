// ShieldManager.swift
import Foundation
import ManagedSettings
import FamilyControls

public final class ShieldManager: ObservableObject {
    private let store = ManagedSettingsStore()
    public init() {}

    public func apply(blockedTokens: Set<WebDomainToken>) {
        store.shield.webDomains = .specific(blockedTokens)
    }
}
