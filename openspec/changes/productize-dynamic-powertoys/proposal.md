## Why

The current "Dynamic PowerToys" project exists as a technical prototype with manual setup steps and mock data. To make it a viable tool for the community, we need to automate the module preparation process, provide a polished installation experience for beginners, and structure the repository for public distribution and collaboration.

## What Changes

- **Module Extraction Automation**: A tool to automatically split the official PowerToys installer into "Core" and "On-Demand Modules".
- **Real Catalog Generation**: Automatically compute file hashes and generate `catalog.json` for a real distribution.
- **Improved Installer**: A more robust and user-friendly setup experience that handles service registration and environment checks.
- **Repository Structuring**: Organize the project into a standard Open Source format (src, docs, tools, scripts) with clear onboarding instructions.

## Capabilities

### New Capabilities
- `module-extractor-cli`: A CLI utility that processes PowerToys binaries and prepares the dynamic modules and manifest.
- `installer-bootstrapper`: A user-friendly launcher/installer that sets up the PowerToys framework and the dynamic installation service.

### Modified Capabilities
- (None)

## Impact

- **Build Pipeline**: New tools will be added to the `tools/` directory.
- **Distribution**: The way the final product is packaged will shift from a raw `release/` folder to a structured, versioned distribution.
- **Onboarding**: Documentation and setup scripts will be significantly simplified for end-users.