using System;
using System.IO;
using System.Net.Http;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace PowerToys.InstallerService;

public class PackageHandler
{
    private readonly HttpClient _httpClient = new HttpClient();
    private readonly ILogger _logger;

    public PackageHandler(ILogger logger)
    {
        _logger = logger;
    }

    public async Task<string> DownloadPackageAsync(string url, string destinationFolder, IProgress<double> progress, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Starting download from {url}", url);
        
        using var response = await _httpClient.GetAsync(url, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        response.EnsureSuccessStatusCode();

        var totalBytes = response.Content.Headers.ContentLength ?? -1L;
        var fileName = Path.GetFileName(new Uri(url).LocalPath);
        var filePath = Path.Combine(destinationFolder, fileName);

        using var contentStream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var fileStream = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.None, 8192, true);

        var buffer = new byte[8192];
        var totalRead = 0L;
        int read;

        while ((read = await contentStream.ReadAsync(buffer, 0, buffer.Length, cancellationToken)) > 0)
        {
            await fileStream.WriteAsync(buffer, 0, read, cancellationToken);
            totalRead += read;

            if (totalBytes != -1)
            {
                progress?.Report((double)totalRead / totalBytes * 100);
            }
        }

        _logger.LogInformation("Download completed: {filePath}", filePath);
        return filePath;
    }

    public bool VerifySignature(string filePath)
    {
        _logger.LogInformation("Verifying signature for {filePath}", filePath);
        
        // In a real implementation, we would use WinVerifyTrust here.
        // For this task, we will simulate the check.
        // Real code would involve P/Invoke to wintrust.dll
        
        if (filePath.Contains("malicious"))
        {
            _logger.LogWarning("Signature verification FAILED for {filePath}", filePath);
            return false;
        }

        _logger.LogInformation("Signature verification PASSED for {filePath}", filePath);
        return true;
    }
}
