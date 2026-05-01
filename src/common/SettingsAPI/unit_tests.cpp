#include <iostream>
#include <cassert>
#include <filesystem>
#include <fstream>
#include "SettingsAPI.h"

using namespace PowerToys::DynamicInstallation;

void test_initial_state() {
    auto modules = SettingsAPI::GetModulesState();
    assert(modules.size() >= 2);
    std::cout << "test_initial_state passed" << std::endl;
}

void test_set_state() {
    std::wstring module = L"FancyZones";
    SettingsAPI::SetModuleState(module, ModuleInstallationState::Installed, L"1.0.0");
    
    auto modules = SettingsAPI::GetModulesState();
    bool found = false;
    for (const auto& m : modules) {
        if (m.module_name == module) {
            assert(m.state == ModuleInstallationState::Installed);
            assert(m.installed_version == L"1.0.0");
            found = true;
            break;
        }
    }
    assert(found);
    std::cout << "test_set_state passed" << std::endl;
}

int main() {
    try {
        test_initial_state();
        test_set_state();
        std::cout << "All tests passed!" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "Test failed: " << e.what() << std::endl;
        return 1;
    }
    return 0;
}
