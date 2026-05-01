## Why

Currently, installing PowerToys downloads and installs all available tools by default. This consumes a significant amount of disk space and can increase the initial overhead. Many users only utilize a small subset of the available tools. Implementing an on-demand, dynamic download and installation mechanism will drastically reduce the initial installation size, save disk space, and potentially improve the overall performance and startup time of the application.

## What Changes

- The initial PowerToys installer will be streamlined to only install the core framework (runner, settings dashboard, and essential shared libraries).
- In the Settings dashboard, tools will be displayed with their installation status (e.g., "Available to Download", "Installed").
- When a user attempts to enable or use a tool that is not yet installed, the application will dynamically download and install it in the background.
- A new Tool Manager component will be introduced to handle the downloading, verification, extraction, and registration of individual tool packages.
- **BREAKING**: The default installation process will require an active internet connection to acquire additional tools. The monolithic offline installer will be replaced or supplemented by this dynamic model.

## Capabilities

### New Capabilities
- `tool-manager`: Manages the fetching, downloading, verifying, and installing of individual PowerToys tools from a remote source or CDN.
- `dynamic-ui`: Enhances the Settings dashboard to support tool installation states, progress bars for downloads, and error handling for failed downloads.

### Modified Capabilities
- (None identified yet; this feature primarily introduces new systems rather than modifying existing spec-level behavior)

## Impact

- **Installer**: Needs to be refactored to separate the core framework from the individual tool payloads.
- **Build System**: CI/CD pipelines must be updated to package and publish each tool as an individual downloadable module alongside the core installer.
- **Settings UI**: Significant additions to the UI to handle the new states (Download, Installing, Error).
- **Core Runner**: Needs the ability to dynamically load tool modules at runtime after they are downloaded, rather than expecting all modules to be present at startup.