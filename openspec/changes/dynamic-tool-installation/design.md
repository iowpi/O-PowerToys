## Context

PowerToys currently installs as a monolithic package, consuming significant disk space (~800MB) even if a user only uses one or two tools (like ColorPicker or FancyZones). With the growing number of tools, the installer size and installation time will only increase. To mitigate this, we need an architecture where only the core application is installed initially, and individual tools are downloaded and installed on demand when requested by the user.

## Goals / Non-Goals

**Goals:**
- Reduce the initial installer payload to only the core framework (Runner + Settings).
- Provide a robust mechanism to fetch, verify, and extract individual tools from a remote CDN.
- Update the Settings UI to clearly show installation states (Available, Downloading, Installed, Error).
- Ensure tools can be loaded dynamically by the Runner without requiring a restart, if possible.

**Non-Goals:**
- Removing the capability for offline installations entirely (a separate "full" installer or bundle can still be provided, but it's not the default).
- Auto-updating individual tools out-of-band from the main application updates (tool versions will still be tied to the main PowerToys release version for now to simplify dependency management).

## Decisions

- **Package Format**: Individual tools will be packaged as `.zip` or MSIX fragments. We will choose `.zip` for simplicity in extraction and registration via the existing runner mechanism, signed with the Microsoft certificate.
  - *Rationale*: MSIX fragments might introduce unnecessary complexity for simple C++ DLLs/EXEs that PowerToys uses. A signed ZIP is lightweight and easy to verify.
- **CDN and Hosting**: Tool packages will be hosted on GitHub Releases or a dedicated Azure CDN tied to the specific PowerToys release version.
  - *Rationale*: Tying to the release version ensures compatibility between the Runner and the tool.
- **State Management**: The installation state (installed/not installed) will be tracked in the `settings.json` or a new `installation_state.json` file in the user's LocalAppData.
  - *Rationale*: Keeps state local to the user and integrates with existing settings mechanisms.

## Risks / Trade-offs

- [Risk] Network unavailability preventing users from accessing tools. -> Mitigation: Provide clear UI feedback if offline. Offer a "download all" button or a full offline installer alternative.
- [Risk] Tool extraction fails due to permissions or anti-virus. -> Mitigation: Extract to a temporary directory first, verify signature, then atomically move to the final installation directory. Handle access denied errors gracefully in UI.
- [Risk] Dynamic loading in Runner might fail or cause crashes. -> Mitigation: Ensure robust error handling around `LoadLibrary` or equivalent IPC mechanisms when a tool is launched.