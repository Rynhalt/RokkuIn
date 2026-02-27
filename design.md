# design.md — System Website Blocking (Screen Time API)

## Goal
Build an iOS app that can block access to specific websites at the system level using Screen Time APIs.
The app allows users to *add* websites to a blocked list, but does not provide UI to remove/edit the list
(append-only). The "Add websites" UI is shown only after Screen Time authorization succeeds.

## Non-goals
- No “unblock” or “remove from blocked list” UI.
- No parental/child device management features (this is a self-use app).
- No background web filtering outside what Screen Time APIs can enforce.

## Constraints & Threat Model
- This is “hard to undo inside the app,” not cryptographically irreversible.
- The device owner can potentially bypass by revoking Screen Time permission in Settings, disabling Screen Time access, uninstalling the app, etc. This is expected behavior.

---

## Architecture Overview

### Frameworks
- FamilyControls: obtain authorization and present picker UI for selecting websites.
- ManagedSettings: apply system-level shielding for selected web domains.
- (Optional) DeviceActivity: time-based schedules and thresholds (future milestone).
- (Optional) ShieldConfiguration / ShieldAction extensions: customize the shield UI and actions.

### High-level Flow
1. App launches → checks authorization status.
2. If not authorized: show authorization screen only.
3. After authorization succeeds: show “Add Websites to Block” screen.
4. User selects sites in FamilyActivityPicker → yields WebDomainTokens.
5. App merges tokens into stored blocked set (append-only).
6. App applies ManagedSettings shielding from stored tokens.
7. Attempting to open blocked websites triggers system shield UI.

---

## Data Model

### Stored state (minimum)
- `blockedWebDomainTokens: Set<WebDomainToken>`  
  Persisted locally (UserDefaults or SwiftData).
- `authorizationState: enum { unknown, denied, authorized }`  
  Derived from AuthorizationCenter + in-app cached state.

### Persistence choice
Milestone 1: UserDefaults (simple, fast iteration)
Milestone 2: SwiftData (if you want richer auditing / history)

---

## UI / Screens

### Screen A: AuthorizationGateView
Shown when authorization is not yet granted.

Elements:
- Title/explanation
- “Enable Screen Time Access” button
- Status label (authorized / denied / not determined)
- Error text if request fails

Behavior:
- User taps button → `requestAuthorization(for: .individual)`
- On success: route to main blocking UI
- On deny/error: stay here and show error

### Screen B: BlockListHomeView (only after authorized)
Elements:
- “Add websites to block” button
- Summary: “Blocking N websites”
- (Optional) “Show blocked list” read-only view without delete controls
- (Optional) “Re-apply restrictions” button (debug)

Behavior:
- Tapping “Add” presents FamilyActivityPicker
- On picker dismiss:
  - union new tokens into stored blocked set
  - persist
  - apply shielding immediately

---

## Core Components & Files

Suggested file structure:

- `RokkuInnApp.swift`
  - root bootstrapping
  - creates shared instances (settings manager, storage)

- `Authorization/AuthorizationManager.swift`
  - wraps AuthorizationCenter
  - exposes async `requestAuthorization()`
  - exposes current status (authorized/denied)

- `Blocking/BlockingStore.swift`
  - persistence layer
  - load/save `Set<WebDomainToken>` (UserDefaults initially)

- `Blocking/ShieldManager.swift`
  - wraps ManagedSettingsStore
  - `apply(blockedTokens: Set<WebDomainToken>)`
  - optionally supports categories later

- `UI/AuthorizationGateView.swift`
- `UI/BlockListHomeView.swift`
- `UI/WebDomainPickerSheet.swift`
  - hosts FamilyActivityPicker
  - returns selection tokens

Optional later:
- `Extensions/ShieldConfigurationExtension`
- `Extensions/ShieldActionExtension`
- `Extensions/DeviceActivityMonitorExtension`

---

## Milestones

### Milestone 0 — Dev Setup & Run on Device
**Goal:** Run a basic SwiftUI app on your iPhone (signed).

Deliverables:
- Project builds on device
- “Hello” screen visible

Acceptance:
- App launches on device without Xcode attached (trusted developer).

---

### Milestone 1 — Authorization Gate (No Blocking Yet)
**Goal:** Implement authorization flow and gating UI.

Implementation steps:
1. Create `AuthorizationManager`.
2. Create `AuthorizationGateView`.
3. On app launch, show AuthorizationGateView if not authorized.
4. Only after success, navigate to BlockListHomeView.

Acceptance:
- If not authorized, BlockListHomeView cannot be reached.
- If user authorizes, BlockListHomeView is reachable.

Notes:
- Handle denied state and show instructions.
- Keep logic simple: one “Enable” button.

---

### Milestone 2 — Add Websites via Picker + Persist Tokens (Append-only)
**Goal:** Allow user to add websites to a stored blocked set.

Implementation steps:
1. Add “Add websites to block” button in BlockListHomeView.
2. Present FamilyActivityPicker configured for web domains.
3. Extract `webDomainTokens` from selection.
4. Merge into stored set (`blocked = blocked ∪ newTokens`) and persist.

Acceptance:
- After selecting sites once, relaunch app → count persists.
- Selecting again increases or stays same; never decreases via UI.

---

### Milestone 3 — Apply System Shielding
**Goal:** Actually block selected websites.

Implementation steps:
1. Implement `ShieldManager.apply(blockedTokens:)` using ManagedSettingsStore shielding.
2. On app launch (authorized), load stored tokens and apply shielding.
3. After each “Add” operation, apply shielding immediately.

Acceptance:
- Attempting to open a blocked site triggers the system shield.
- Reboot device / relaunch app → shielding still applied after app runs.

---

### Milestone 4 — Remove Edit UI (Hardening)
**Goal:** Ensure no “edit/remove” path exists in the UI and reduce accidental undo.

Implementation steps:
- Do not present list with delete controls.
- If showing the list, make it read-only.
- Remove any “reset” buttons from release builds.
- Optionally require a “cooldown” before allowing new additions (not required).

Acceptance:
- No in-app path to remove a blocked domain.

---

### Milestone 5 (Optional) — Custom Shield UI
**Goal:** Customize the shield page and actions to reduce “escape hatches”.

Implementation steps:
- Add ShieldConfiguration extension.
- Provide custom message (“Blocked: focus mode”).
- Add ShieldAction extension if you need custom button behavior.

Acceptance:
- Block screen shows your branding/message.

---

### Milestone 6 (Optional) — Scheduling (DeviceActivity)
**Goal:** Block websites only during focus windows.

Implementation steps:
- Add DeviceActivity monitoring extension.
- Define schedules (e.g., weekdays 9–6).
- Apply/clear shielding based on schedule events.

Acceptance:
- Websites blocked only during configured window.

---

## Implementation Notes & Pitfalls
- Tokens are opaque; don’t rely on raw domain strings.
- Persist tokens carefully (serialization).
- Always re-apply shields on launch after loading stored tokens.
- Provide clear user messaging for “This can still be disabled in Settings.”

---

## Testing Plan
- Unit-ish: token persistence roundtrip (save/load equality).
- Manual:
  - authorize → add websites → confirm shield
  - kill app → relaunch → confirm shield still active
  - add more websites → confirm union behavior

---

## Release Checklist
- Remove debug reset toggles.
- Confirm authorization gate cannot be bypassed.
- Confirm no delete/remove UI exists.