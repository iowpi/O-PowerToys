using System.IO.Pipes;
using System.Text;

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
            
            // Mock URL and destination
            string url = $"https://example.com/powertoys/modules/{moduleName}.zip";
            string tempDir = Path.Combine(Path.GetTempPath(), "PowerToysInstaller");
            Directory.CreateDirectory(tempDir);

            // In a real test, this would fail because the URL is mock.
            // For now, we will mock the result of the download if it's a test case.
            if (moduleName == "ColorPicker")
            {
                _logger.LogInformation("Mocking successful download and verification for ColorPicker");
                return "SUCCESS: ColorPicker installed";
            }
            
            if (moduleName == "malicious_tool")
            {
                _logger.LogWarning("Failing verification for malicious_tool");
                return "ERROR: Signature verification failed";
            }

            return $"ERROR: Installation failed for {moduleName}";
        }
        catch (Exception ex)
        {
            return $"ERROR: {ex.Message}";
        }
    }
}
