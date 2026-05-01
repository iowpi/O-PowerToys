#pragma once
#include <vector>
#include <string>
#include "dynamic_installation_types.h"

namespace PowerToys::DynamicInstallation
{
    class SettingsAPI
    {
    public:
        static std::vector<ModuleState> GetModulesState();
        static void SaveModulesState(const std::vector<ModuleState>& states);
        static void SetModuleState(const std::wstring& module_name, ModuleInstallationState state, const std::wstring& version);
    private:
        static std::wstring GetStateFilePath();
    };
}
