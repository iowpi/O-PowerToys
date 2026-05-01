using System.IO.Pipes;
using System.Text;
using System.Text.Json;

namespace PowerToys.InstallerService;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly PackageHandler _packageHandler;
    private const string PipeName = "PowerToysInstallerPipe";

    public Worker(ILogger<Worker> logger)
    {
        _logger = logger;
        _packageHandler = new PackageHandler(logger);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Installer Service started at: {time}", DateTimeOffset.Now);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var pipeServer = new NamedPipeServerStream(PipeName, PipeDirection.InOut, 1, PipeTransmissionMode.Byte, PipeOptions.Asynchronous);
                
                _logger.LogInformation("Waiting for client connection...");
                await pipeServer.WaitForConnectionAsync(stoppingToken);
                
                _logger.LogInformation("Client connected.");
                await HandleClientAsync(pipeServer, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in Named Pipe server");
                await Task.Delay(1000, stoppingToken);
            }
        }
    }

    private async Task HandleClientAsync(NamedPipeServerStream pipe, CancellationToken stoppingToken)
    {
        var buffer = new byte[1024];
        int bytesRead = await pipe.ReadAsync(buffer, 0, buffer.Length, stoppingToken);
        var request = Encoding.UTF8.GetString(buffer, 0, bytesRead);
        
        _logger.LogInformation("Received request: {request}", request);

        string response;
        if (request.StartsWith("INSTALL_MODULE:"))
        {
            var moduleName = request.Split(':')[1].Trim();
            response = await ProcessInstallationAsync(moduleName, stoppingToken);
        }
        else
        {
            response = $"UNKNOWN_COMMAND: {request}";
        }

        byte[] responseBytes = Encoding.UTF8.GetBytes(response);
        await pipe.WriteAsync(responseBytes, 0, responseBytes.Length, stoppingToken);
        
        _logger.LogInformation("Sent response: {response}", response);
    }

    private async Task<string> ProcessInstallationAsync(string moduleName, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("Processing installation for {moduleName}", moduleName);
            
            // 1. Locate catalog.json
            string baseDir = AppDomain.CurrentDomain.BaseDirectory;
            string catalogPath = Path.Combine(baseDir, "catalog.json");
            if (!File.Exists(catalogPath)) {
                catalogPath = Path.Combine(Directory.GetParent(baseDir).FullName, "catalog.json");
            }

            if (!File.Exists(catalogPath)) {
                return "ERROR: catalog.json not found";
            }

            // 2. Parse catalog and find module
            var json = await File.ReadAllTextAsync(catalogPath, cancellationToken);
            using var doc = JsonDocument.Parse(json);
            var modules = doc.RootElement.GetProperty("modules");
            
            string downloadUrl = null;
            foreach (var module in modules.EnumerateArray()) {
                if (module.GetProperty("id").GetString().Equals(moduleName, StringComparison.OrdinalIgnoreCase)) {
                    downloadUrl = module.GetProperty("download_url").GetString();
                    break;
                }
            }

            if (string.IsNullOrEmpty(downloadUrl)) {
                return $"ERROR: Module {moduleName} not found in catalog";
            }

            // 3. Prepare directories
            string tempDir = Path.Combine(Path.GetTempPath(), "PowerToysInstaller");
            Directory.CreateDirectory(tempDir);
            
            string installDir = Directory.GetParent(baseDir).FullName;
            string modulesDir = Path.Combine(installDir, "modules");

            // 4. Download
            _logger.LogInformation("Downloading {moduleName} from {url}", moduleName, downloadUrl);
            string zipPath = await _packageHandler.DownloadPackageAsync(downloadUrl, tempDir, null, cancellationToken);

            // 5. Verify
            if (!_packageHandler.VerifySignature(zipPath)) {
                File.Delete(zipPath);
                return "ERROR: Signature verification failed";
            }

            // 6. Extract
            _logger.LogInformation("Extracting {moduleName} to {modulesDir}", moduleName, modulesDir);
            await _packageHandler.ExtractAsync(zipPath, modulesDir);
            
            // Cleanup
            File.Delete(zipPath);

            return $"SUCCESS: {moduleName} installed";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Installation failed for {moduleName}", moduleName);
            return $"ERROR: {ex.Message}";
        }
    }
}
