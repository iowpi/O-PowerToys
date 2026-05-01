#pragma once
#include <string>
#include <vector>

namespace PowerToys::DynamicInstallation
{
    enum class ModuleInstallationState
    {
        NotInstalled,
        Downloading,
        Installed,
        Error
    };

    struct CatalogEntry
    {
        std::wstring module_name;
        std::wstring version;
        std::wstring download_url;
        std::wstring sha256_hash;
    };

    struct ModuleState
    {
        std::wstring module_name;
        ModuleInstallationState state;
        std::wstring installed_version;
    };
}
