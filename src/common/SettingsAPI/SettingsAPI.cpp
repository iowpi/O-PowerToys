#include "SettingsAPI.h"
#include <fstream>
#include <filesystem>
#include <sstream>
#include <regex>

namespace PowerToys::DynamicInstallation
{
    std::wstring SettingsAPI::GetStateFilePath()
    {
        return L"installation_state.json"; 
    }

    std::vector<ModuleState> SettingsAPI::GetModulesState()
    {
        std::vector<ModuleState> result;
        std::ifstream file("installation_state.json");
        if (!file.is_open()) return result;

        std::stringstream buffer;
        buffer << file.rdbuf();
        std::string content = buffer.str();

        std::regex module_regex(R"(\{\s*"module_name":\s*"([^"]+)",\s*"state":\s*"([^"]+)",\s*"installed_version":\s*"([^"]*)"\s*\})");
        auto words_begin = std::sregex_iterator(content.begin(), content.end(), module_regex);
        auto words_end = std::sregex_iterator();

        for (std::sregex_iterator i = words_begin; i != words_end; ++i) {
            std::smatch match = *i;
            ModuleState state;
            
            std::string name = match[1].str();
            state.module_name = std::wstring(name.begin(), name.end());
            
            std::string state_str = match[2].str();
            if (state_str == "Installed") state.state = ModuleInstallationState::Installed;
            else if (state_str == "Downloading") state.state = ModuleInstallationState::Downloading;
            else if (state_str == "Error") state.state = ModuleInstallationState::Error;
            else state.state = ModuleInstallationState::NotInstalled;

            std::string version = match[3].str();
            state.installed_version = std::wstring(version.begin(), version.end());
            
            result.push_back(state);
        }

        return result;
    }

    void SettingsAPI::SaveModulesState(const std::vector<ModuleState>& states)
    {
        std::ofstream file("installation_state.json");
        file << "{\n  \"modules\": [\n";
        for (size_t i = 0; i < states.size(); ++i) {
            std::string name(states[i].module_name.begin(), states[i].module_name.end());
            std::string version(states[i].installed_version.begin(), states[i].installed_version.end());
            std::string state_str;
            switch (states[i].state) {
                case ModuleInstallationState::Installed: state_str = "Installed"; break;
                case ModuleInstallationState::Downloading: state_str = "Downloading"; break;
                case ModuleInstallationState::Error: state_str = "Error"; break;
                default: state_str = "NotInstalled"; break;
            }

            file << "    {\n";
            file << "      \"module_name\": \"" << name << "\",\n";
            file << "      \"state\": \"" << state_str << "\",\n";
            file << "      \"installed_version\": \"" << version << "\"\n";
            file << "    }" << (i == states.size() - 1 ? "" : ",") << "\n";
        }
        file << "  ]\n}\n";
    }

    void SettingsAPI::SetModuleState(const std::wstring& module_name, ModuleInstallationState state, const std::wstring& version)
    {
        auto states = GetModulesState();
        bool found = false;
        for (auto& s : states) {
            if (s.module_name == module_name) {
                s.state = state;
                s.installed_version = version;
                found = true;
                break;
            }
        }
        if (!found) {
            states.push_back({module_name, state, version});
        }
        SaveModulesState(states);
    }
}
