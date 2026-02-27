// BlockingStore.swift
import Foundation
import Combine
import FamilyControls
import ManagedSettings

/// Source of truth for the user's blocked `WebDomainToken` set.
@MainActor
public final class BlockingStore: ObservableObject {
    private let defaultsKey = "blockedWebDomainTokens"
    /// Published value consumed by SwiftUI to show counts and lists.
    @Published public private(set) var blocked: Set<ManagedSettings.WebDomainToken> = []

    public init() { loadBlocked() }

    /// Reloads the tokens from `UserDefaults` and publishes them to observers.
    public func loadBlocked() {
        guard let raw = UserDefaults.standard.data(forKey: defaultsKey) else { blocked = []; return }
        blocked = (try? JSONDecoder().decode(Set<ManagedSettings.WebDomainToken>.self, from: raw)) ?? []
    }

    /// Persists the current `blocked` set back to `UserDefaults`.
    public func saveBlocked() {
        guard let data = try? JSONEncoder().encode(blocked) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    /// Adds new tokens to the set and immediately saves the merged result.
    public func merge(new tokens: Set<ManagedSettings.WebDomainToken>) {
        blocked.formUnion(tokens)
        saveBlocked()
    }
}
