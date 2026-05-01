## ADDED Requirements

### Requirement: Display Tool Installation State
The Settings dashboard SHALL display the current installation state of each tool, allowing users to differentiate between installed and available tools.

#### Scenario: Uninstalled tool is viewed
- **WHEN** the user navigates to the Settings page of an uninstalled tool
- **THEN** the main toggle switch is replaced or augmented by a "Download & Install" button
- **AND** a badge indicates "Not Installed"

#### Scenario: Installed tool is viewed
- **WHEN** the user navigates to the Settings page of an installed tool
- **THEN** the standard enable/disable toggle is shown

### Requirement: Download Progress Feedback
The Settings UI SHALL provide visual feedback during the download and installation process of a tool.

#### Scenario: Tool download initiated
- **WHEN** the user clicks "Download & Install" for a tool
- **THEN** the UI displays a progress bar indicating download status
- **AND** the button is disabled to prevent multiple concurrent requests for the same tool

#### Scenario: Tool installation completes
- **WHEN** the Tool Manager reports successful installation
- **THEN** the UI updates to show the standard toggle switch
- **AND** the tool is automatically enabled by default
