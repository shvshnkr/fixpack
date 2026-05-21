# Online-run entry point (irm ... | iex)
# Скачивает полный Fix-RdpListener.ps1 с GitHub или запускает встроенный минимальный фикс.

param(
    [string] $RepoUser = 'shvshnkr',
    [string] $Branch = 'main'
)

$base = "https://raw.githubusercontent.com/$RepoUser/fixpack/$Branch/fixes/windows-rdp-internal-error/local"
$fullScript = "$base/Fix-RdpListener.ps1"

try {
    $script = Invoke-RestMethod -Uri $fullScript -UseBasicParsing
    Invoke-Expression $script
} catch {
    Write-Warning "Could not download $fullScript — running inline minimal fix."
    $RdpTcpPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run PowerShell as Administrator.'
    }
    Set-ItemProperty -Path $RdpTcpPath -Name SecurityLayer -Value 1 -Type DWord -Force
    Remove-ItemProperty -Path $RdpTcpPath -Name SSLCertificateSHA1Hash -ErrorAction SilentlyContinue
    Stop-Service UmRdpService, TermService -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Start-Service TermService
    Start-Service UmRdpService -ErrorAction SilentlyContinue
    Write-Host 'Minimal fix applied. For full script, clone fixpack repo.' -ForegroundColor Green
}
