## 1. Module Extraction Tool (module-extractor-cli)

- [ ] 1.1 Create `tools/PowerToys-Extractor.ps1` script skeleton.
- [ ] 1.2 Implement logic to identify subdirectories in the `modules/` folder of a PowerToys installation.
- [ ] 1.3 Add logic to zip individual module folders into a `dist/modules/` directory.
- [ ] 1.4 Implement SHA256 hashing and automatic generation of the `catalog.json` file.
- [ ] 1.5 Add a "Dry Run" mode to preview changes without zipping files.

## 2. Polished Installer (installer-bootstrapper)

- [ ] 2.1 Refactor `release/install.ps1` into a more robust `PowerToys-Setup.ps1`.
- [ ] 2.2 Add explicit system checks (.NET runtime version, Administrator privileges).
- [ ] 2.3 Improve error handling and logging during service registration.
- [ ] 2.4 Add a post-installation summary and a "Launch PowerToys" option.

## 3. Project Structuring and Documentation

- [ ] 3.1 Organize the repository into `src/`, `tools/`, `docs/`, and `dist/` folders.
- [ ] 3.2 Create a professional `README.md` with "Quick Start", "How it Works", and "Contributing" sections.
- [ ] 3.3 Create `docs/Getting-Started.md` specifically for beginners.
- [ ] 3.4 Add a license file (e.g., MIT) to make the project Open Source ready.

## 4. Final Verification and Cleanup

- [ ] 4.1 Run the extractor on a real PowerToys installation to verify the output.
- [ ] 4.2 Perform a clean installation on a fresh machine (or VM) using the new setup script.
- [ ] 4.3 Clean up all temporary build artifacts and test files (like `test_loader.exe`).