## RokkuInn Architecture Overview

This document explains how the major pieces of RokkuInn fit together and the role each file plays in the Screen Time blocking workflow.

### High-Level Flow

1. `RokkuInnApp` launches and shows `ContentView`.
2. `ContentView` owns the long-lived objects (`AuthorizationManager`, `BlockingStore`, `ShieldManager`) and reacts to the current authorization state.
3. When the user is authorized, `BlockListHomeView` becomes visible. It allows the user to pick domains (`WebDomainPickerSheet`) and manage the locally persisted block list (`BlockingStore`).
4. `ShieldManager` forwards the chosen `ManagedSettings.WebDomainToken` set to `ManagedSettingsStore`, which instructs Screen Time to block the domains system-wide.

### File Responsibilities

| File | Responsibility |
| --- | --- |
| `RokkuInnApp.swift` | SwiftUI entry point; boots the window group and displays `ContentView`. |
| `ContentView.swift` | Coordinates the authorization gate with the block list UI. Initializes and reuses the observable singletons that power the app. |
| `Authorization/AuthorizationManager.swift` | Wraps `AuthorizationCenter` interactions, exposes the observable `AuthorizationState`, and handles async permission requests. |
| `Blocking/BlockingStore.swift` | Persists the selected `ManagedSettings.WebDomainToken` set to `UserDefaults`, reloads the set on launch, and exposes helper methods for merging changes. |
| `Blocking/ShiledManager.swift` | Minimal adapter around `ManagedSettingsStore` that applies the current blocked tokens to the system shield configuration. |
| `UI/BlockListHomeView.swift` | SwiftUI surface that shows buttons, summary, optional debug list, and presents the picker sheet. It orchestrates updates between `BlockingStore` and `ShieldManager`. |
| `UI/WebDomainPicker.swift` | Wraps `FamilyActivityPicker` so the app can present Apple's Screen Time UI and receive the selected `ManagedSettings.WebDomainToken` set. |
| `Item.swift` | Template `SwiftData` model that currently acts as a placeholder (not used elsewhere). Kept for potential future data modeling. |
| `RokkuInn.entitlements` | Declares the execution entitlements (APNs, CloudKit, Family Controls) required for the associated App ID. |

### Key Dependencies

- **FamilyControls** – Provides `AuthorizationCenter`, `FamilyActivitySelection`, and `FamilyActivityPicker`.
- **ManagedSettings** – Gives access to `ManagedSettingsStore`, `WebDomainToken`, and the shielding APIs used to enforce blocks.
- **Combine / SwiftUI** – Drives the observable object graph and reactive UI updates.

### Data Persistence and Shielding

The list of blocked tokens is stored in `UserDefaults` as a JSON-encoded `Set<ManagedSettings.WebDomainToken>`. Reloads happen when authorization changes or when the block list view appears so the UI always mirrors persisted state. When tokens change, `ShieldManager` immediately calls `ManagedSettingsStore().shield.webDomains = tokens`, which informs Screen Time of the desired domain restrictions for the active device.

Together these components create a thin, testable surface around Apple's Screen Time frameworks, keeping the business logic (authorization, persistence, shielding) isolated from the SwiftUI presentation layer.
