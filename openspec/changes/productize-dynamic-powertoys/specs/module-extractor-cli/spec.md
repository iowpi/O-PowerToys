## ADDED Requirements

### Requirement: Automated Module Splitting
The system SHALL identify individual tool directories within an official PowerToys installation and move them into separate zip archives.

#### Scenario: Successful extraction
- **WHEN** the extractor tool is pointed to a valid PowerToys installation directory
- **THEN** it identifies subdirectories in `modules/`
- **AND** it creates a `.zip` file for each module in the target distribution folder

### Requirement: Manifest Generation
The system SHALL generate a `catalog.json` file containing the metadata for all identified modules, including their file hashes.

#### Scenario: Metadata creation
- **WHEN** the extraction process completes
- **THEN** the tool calculates the SHA256 hash for each zip file
- **AND** it writes the module ID, version, and hash into the `catalog.json` file
