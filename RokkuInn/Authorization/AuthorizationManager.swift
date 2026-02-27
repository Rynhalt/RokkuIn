// AuthorizationManager.swift
import Foundation
import FamilyControls

public enum AuthorizationState: CaseIterable {
    case unknown
    case denied
    case authorized
}

@MainActor
public final class AuthorizationManager: ObservableObject {
    @Published public private(set) var state: AuthorizationState = .unknown

    public init() {
        Task { await refreshStatus() }
    }

    public func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await refreshStatus()
        } catch {
            state = .denied
        }
    }

    public func refreshStatus() async {
        let status = AuthorizationCenter.shared.authorizationStatus
        switch status {
        case .approved:
            state = .authorized
        case .denied, .notDetermined:
            state = .denied
        @unknown default:
            state = .unknown
        }
    }
}
