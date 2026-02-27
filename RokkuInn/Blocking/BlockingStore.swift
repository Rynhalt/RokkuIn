// BlockingStore.swift
import Foundation
import FamilyControls

struct PersistedWebDomainToken: Codable, Hashable {
    let data: Data

    init?(from token: WebDomainToken) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
            self.data = data
        } catch {
            return nil
        }
    }

    func token() -> WebDomainToken? {
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: WebDomainToken.self, from: data)
        } catch {
            return nil
        }
    }
}

@MainActor
public final class BlockingStore: ObservableObject {
    private let defaultsKey = "blockedWebDomainTokens"
    @Published public private(set) var blocked: Set<WebDomainToken> = []

    public init() { loadBlocked() }

    public func loadBlocked() {
        guard let raw = UserDefaults.standard.data(forKey: defaultsKey) else { blocked = []; return }
        do {
            let decoded = try JSONDecoder().decode([PersistedWebDomainToken].self, from: raw)
            blocked = Set(decoded.compactMap { $0.token() })
        } catch {
            blocked = []
        }
    }

    public func saveBlocked() {
        let persisted = blocked.compactMap { PersistedWebDomainToken(from: $0) }
        if let data = try? JSONEncoder().encode(persisted) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    public func merge(new tokens: Set<WebDomainToken>) {
        blocked.formUnion(tokens)
        saveBlocked()
    }
}
