// AuthorizationManager.swift
import Foundation
import FamilyControls
import Combine

/// Immutable set of high-level authorization states used by the UI.
public enum AuthorizationState: CaseIterable {
    case unknown
    case denied
    case authorized
}

/// Handles all interaction with `AuthorizationCenter` and publishes state changes.
@MainActor
public final class AuthorizationManager: ObservableObject {

    /// Backing property observed by SwiftUI screens to react to permission changes.
    @Published public private(set) var state: AuthorizationState = .unknown

    public init() {
        // On creation, asynchronously query the system for the latest status.
        Task { [weak self] in
            await self?.refreshStatus()
        }
    }

    /// Presents the Screen Time permission sheet if needed and refreshes `state`.
    public func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await refreshStatus()
        } catch {
            // If the system throws (e.g., capability missing or user declined), treat it as denied.
            state = .denied
        }
    }

    /// Reads the current authorization status from the system and maps it onto our enum.
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
