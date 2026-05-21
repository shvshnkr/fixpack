#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Локальный фикс RDP listener: SecurityLayer 1, сброс SSL hash, перезапуск TermService.

.DESCRIPTION
  Для случая: mstsc "внутренняя ошибка", порт 3389 открыт, в RdpCoreTS Event 227 / 0x8007050c.
  Запускать на проблемной машине (VNC, консоль, локальный админ).

.EXAMPLE
  .\Fix-RdpListener.ps1

.EXAMPLE
  .\Fix-RdpListener.ps1 -RestoreNla
#>
[CmdletBinding()]
param(
    [switch] $RestoreNla,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$RdpTcpPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
$LogFile = Join-Path $env:TEMP "fix-rdp-listener-$env:COMPUTERNAME-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log($msg) {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $msg"
    $line | Tee-Object -FilePath $LogFile -Append
}

Write-Log 'Fix-RdpListener start'

$before = @{
    SecurityLayer       = (Get-ItemProperty -Path $RdpTcpPath -Name SecurityLayer -ErrorAction SilentlyContinue).SecurityLayer
    UserAuthentication  = (Get-ItemProperty -Path $RdpTcpPath -Name UserAuthentication -ErrorAction SilentlyContinue).UserAuthentication
    HasSslHash          = $null -ne (Get-ItemProperty -Path $RdpTcpPath -Name SSLCertificateSHA1Hash -ErrorAction SilentlyContinue)
}
Write-Log "Before: SecurityLayer=$($before.SecurityLayer) UserAuthentication=$($before.UserAuthentication) HasSslHash=$($before.HasSslHash)"

if (-not $WhatIf) {
    # 1 = Negotiate; 2 = SSL-only — часто ломается при отсутствии listener cert
    Set-ItemProperty -Path $RdpTcpPath -Name SecurityLayer -Value 1 -Type DWord -Force
    Remove-ItemProperty -Path $RdpTcpPath -Name SSLCertificateSHA1Hash -ErrorAction SilentlyContinue

    if ($RestoreNla) {
        Set-ItemProperty -Path $RdpTcpPath -Name UserAuthentication -Value 1 -Type DWord -Force
        Write-Log 'NLA enabled (UserAuthentication=1)'
    }

    $svc = @('UmRdpService', 'TermService')
    foreach ($name in $svc) {
        if ((Get-Service -Name $name -ErrorAction SilentlyContinue).Status -eq 'Running') {
            Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
        }
    }
    Start-Sleep -Seconds 3
    Start-Service -Name TermService
    Start-Service -Name UmRdpService -ErrorAction SilentlyContinue
} else {
    Write-Log 'WhatIf: no changes applied'
}

$after = (Get-ItemProperty -Path $RdpTcpPath -Name SecurityLayer).SecurityLayer
Write-Log "After: SecurityLayer=$after"
Write-Log "Log file: $LogFile"
Write-Host "Done. Test mstsc. Log: $LogFile" -ForegroundColor Green
