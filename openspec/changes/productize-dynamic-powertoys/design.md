## Context

We have the core infrastructure for dynamic PowerToys (Service, Shadow Proxy, Coordinator). However, the process of preparing modules (extracting from official binaries, zipping, hashing) and installing the service is currently manual and prone to error. To scale this to other users, we need to automate these tasks.

## Goals / Non-Goals

**Goals:**
- Provide a `PowerToys-Extractor.ps1` or similar CLI tool that converts an official installation directory into a "Core Bundle" and a "Module CDN folder".
- Automate the generation of `catalog.json` with accurate SHA256 hashes.
- Create a `PowerToys-Setup.exe` (or a high-quality PowerShell bootstrapper) that provides a "one-click" experience for new users.

**Non-Goals:**
- Modifying the official PowerToys installer source code (we work with compiled binaries).
- Hosting the files (we only provide the tools to prepare the files for hosting).

## Decisions

- **Extractor Language**: PowerShell.
  - *Rationale*: PowerToys is Windows-only, and PowerShell is the native automation language for Windows administrators and developers. It handles file operations and hashing easily.
- **Bootstrapper Strategy**: A self-extracting archive or a "Thin Installer".
  - *Rationale*: A thin installer downloads the core bundle first, then sets up the service. This keeps the initial download extremely small.
- **Manifest Versioning**: Use the official PowerToys version string (e.g., `v0.80.0`) as the primary key in `catalog.json`.
  - *Rationale*: Ensures consistency between the Runner and the modules.

## Risks / Trade-offs

- [Risk] PowerToys directory structure changes in future official releases. -> Mitigation: Make the extractor configurable with regex/glob patterns for identifying modules.
- [Risk] Anti-virus flagging the dynamic downloader/service. -> Mitigation: Provide clear instructions on signing the binaries and service.
- [Risk] Complexity of dependency management between modules. -> Mitigation: Initially assume all modules depend only on the "Core" framework.
