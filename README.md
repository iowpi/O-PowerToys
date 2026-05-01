# Dynamic PowerToys

Dynamic PowerToys is a productized version of the PowerToys suite designed for modular, on-demand installation. It reduces the initial footprint and system overhead by fetching and installing modules only when they are needed.

## Key Features

- **Modular Architecture**: Only install the PowerToys modules you actually use.
- **On-Demand Loading**: Missed a tool? The system will automatically fetch it for you.
- **Installer Service**: A dedicated Windows Service handles background module management and updates.
- **Extractor Tool**: Easily package modules from a standard PowerToys installation into dynamic modules.

## Project Structure

- `src/`: Source code for the Runner, Installer Service, and Settings UI.
- `tools/`: Utility scripts, including the `PowerToys-Extractor`.
- `docs/`: Detailed documentation and getting started guides.
- `dist/`: Ready-to-use binaries and module catalog.

## Quick Start

### 1. Installation

Clone the repository and run the setup script as Administrator:

```powershell
.\src\installer\PowerToys-Setup.ps1
```

### 2. Basic Usage

Once installed, the **PowerToys Runner** will monitor for module requests. You can test the dynamic loading by running the test client:

```powershell
.\dist\test_client.exe
```

## How It Works

Dynamic PowerToys uses a **Shadow Proxy** pattern. The system presents a minimal interface for all available modules. When a module is invoked:
1. The Runner checks if the module binary exists locally.
2. If missing, it communicates with the **PowerToys Installer Service**.
3. The Service retrieves the module package from the `catalog.json` specifications.
4. The module is extracted, and the Runner completes the loading process.

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](docs/CONTRIBUTING.md) (coming soon) for more details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
