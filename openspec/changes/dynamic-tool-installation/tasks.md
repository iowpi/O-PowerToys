## 1. Project Scaffolding and Infrastructure

- [ ] 1.1 Create the basic Tool Manager module structure in `src/runner/` or a new `src/tool-manager/` directory.
- [ ] 1.2 Define the interface and data models for Tool Information (ID, Version, State, Download URL) and State Tracking (`installation_state.json`).
- [ ] 1.3 Set up a stub or mock download endpoint for testing local tool fetching.

## 2. Core Tool Manager Implementation

- [ ] 2.1 Implement the downloading logic in Tool Manager to fetch `.zip` packages from a given URL with progress reporting.
- [ ] 2.2 Implement signature verification logic for the downloaded packages.
- [ ] 2.3 Implement the extraction logic to unzip the package into the local AppData directory safely.
- [ ] 2.4 Implement the registration mechanism to notify the Runner that a new tool is available and ready to be loaded dynamically.
- [ ] 2.5 Implement state management to read and write the installation state to `installation_state.json`.

## 3. Settings UI Updates (dynamic-ui)

- [ ] 3.1 Update the Settings dashboard UI components to read the installation state of each tool from the Tool Manager.
- [ ] 3.2 Modify the tool toggle switch logic: if not installed, show a "Download & Install" button and a "Not Installed" badge.
- [ ] 3.3 Wire up the "Download & Install" button to trigger the Tool Manager's download process.
- [ ] 3.4 Implement UI progress indicators (progress bar or percentage) that update based on events from the Tool Manager during download.
- [ ] 3.5 Handle UI state changes upon successful installation (switch to normal toggle, auto-enable) and error states (show error message).

## 4. Runner Integration and Testing

- [ ] 4.1 Update the PowerToys Runner to read `installation_state.json` on startup and only load installed tools.
- [ ] 4.2 Test the end-to-end flow: from clicking "Download & Install" in Settings, to Tool Manager downloading/extracting, to the tool becoming active in the Runner.
- [ ] 4.3 Add unit and integration tests for the Tool Manager download, verify, and extract logic.
- [ ] 4.4 Add UI tests for the new download states in the Settings dashboard.