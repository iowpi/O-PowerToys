## ADDED Requirements

### Requirement: Service Registration
The bootstrapper SHALL register the `PowerToys.InstallerService` as a Windows service with the appropriate permissions.

#### Scenario: Service setup
- **WHEN** the user runs the bootstrapper/setup tool
- **THEN** it checks if the service is already registered
- **AND** it creates the service pointing to the local binary if missing
- **AND** it ensures the service is started

### Requirement: Environment Readiness Check
The bootstrapper SHALL verify that the necessary .NET runtimes and system settings (like Developer Mode) are present.

#### Scenario: Missing runtime detection
- **WHEN** the setup is initiated on a machine without .NET 8/10
- **THEN** it provides a clear warning and a link to download the required runtime
