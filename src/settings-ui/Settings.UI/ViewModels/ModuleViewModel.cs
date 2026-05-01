using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows.Input;

namespace PowerToys.Settings.UI.ViewModels;

public enum ModuleInstallationState
{
    NotInstalled,
    Downloading,
    Installed,
    Error
}

public class ModuleViewModel : INotifyPropertyChanged
{
    private ModuleInstallationState _installationState = ModuleInstallationState.NotInstalled;
    private double _downloadProgress = 0;
    private bool _isEnabled = false;
    private string _moduleName;

    public ModuleViewModel(string name)
    {
        _moduleName = name;
        DownloadCommand = new RelayCommand(async () => await DownloadAndInstallAsync());
    }

    public string ModuleName => _moduleName;

    public ModuleInstallationState InstallationState
    {
        get => _installationState;
        set { _installationState = value; OnPropertyChanged(); OnPropertyChanged(nameof(ShowDownloadButton)); OnPropertyChanged(nameof(ShowToggleSwitch)); }
    }

    public double DownloadProgress
    {
        get => _downloadProgress;
        set { _downloadProgress = value; OnPropertyChanged(); }
    }

    public bool IsEnabled
    {
        get => _isEnabled;
        set { _isEnabled = value; OnPropertyChanged(); }
    }

    public bool ShowDownloadButton => InstallationState == ModuleInstallationState.NotInstalled || InstallationState == ModuleInstallationState.Error;
    public bool ShowToggleSwitch => InstallationState == ModuleInstallationState.Installed;
    public bool IsDownloading => InstallationState == ModuleInstallationState.Downloading;

    public ICommand DownloadCommand { get; }

    private async Task DownloadAndInstallAsync()
    {
        InstallationState = ModuleInstallationState.Downloading;
        DownloadProgress = 0;

        // Simulate download
        for (int i = 0; i <= 100; i += 10)
        {
            await Task.Delay(500);
            DownloadProgress = i;
        }

        InstallationState = ModuleInstallationState.Installed;
        IsEnabled = true;
    }

    public event PropertyChangedEventHandler PropertyChanged;
    protected void OnPropertyChanged([CallerMemberName] string name = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
    }
}

public class RelayCommand : ICommand
{
    private readonly Action _execute;
    public RelayCommand(Action execute) => _execute = execute;
    public bool CanExecute(object parameter) => true;
    public void Execute(object parameter) => _execute();
    public event EventHandler CanExecuteChanged;
}
