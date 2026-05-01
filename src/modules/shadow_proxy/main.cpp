#include <windows.h>
#include <iostream>
#include <string>

// Mocking PowertoyModuleIface for demonstration
class IPowertoyModule {
public:
    virtual const wchar_t* get_name() = 0;
    virtual void enable() = 0;
    virtual void disable() = 0;
};

class ShadowProxyModule : public IPowertoyModule {
public:
    ShadowProxyModule(const std::wstring& name) : module_name(name) {}

    virtual const wchar_t* get_name() override {
        return module_name.c_str();
    }

    virtual void enable() override {
        std::wcout << L"Shadow Proxy enabled for: " << module_name << std::endl;
        RequestInstallation();
    }

    virtual void disable() override {
        std::wcout << L"Shadow Proxy disabled for: " << module_name << std::endl;
    }

private:
    std::wstring module_name;

    void RequestInstallation() {
        std::wcout << L"Requesting installation via Named Pipe..." << std::endl;
        
        HANDLE hPipe = CreateFileW(
            L"\\\\.\\pipe\\PowerToysInstallerPipe",
            GENERIC_READ | GENERIC_WRITE,
            0,
            NULL,
            OPEN_EXISTING,
            0,
            NULL);

        if (hPipe != INVALID_HANDLE_VALUE) {
            std::string message = "INSTALL_MODULE: " + std::string(module_name.begin(), module_name.end());
            DWORD written;
            WriteFile(hPipe, message.c_str(), (DWORD)message.length(), &written, NULL);
            
            char buffer[1024];
            DWORD read;
            ReadFile(hPipe, buffer, 1023, &read, NULL);
            buffer[read] = '\0';
            
            std::cout << "Server response: " << buffer << std::endl;
            CloseHandle(hPipe);
        } else {
            std::cerr << "Failed to connect to Installer Service pipe." << std::endl;
        }
    }
};

extern "C" __declspec(dllexport) IPowertoyModule* create_module(const wchar_t* name) {
    return new ShadowProxyModule(name);
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved) {
    return TRUE;
}
