#requires -Version 5.1
<# Bestehende IIS-Anwendung aktualisieren; Konfiguration, Bindungen und App-Pool bleiben erhalten. #>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$SiteName = 'Default Web Site',
    [ValidatePattern('^[a-zA-Z0-9_-]+$')][string]$AppName = 'ehfleet_webservice',
    [Parameter(Mandatory)][string]$PackagePath,
    [ValidatePattern('^[a-fA-F0-9]{64}$')][string]$ExpectedSha256,
    [string]$BackupRoot = 'C:\ProgramData\EHFleet\WebserviceBackups',
    [Parameter(Mandatory)][uri]$SmokeTestUrl
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'EHFleetDeployment.psm1') -Force
Assert-EHFleetAdministrator
Assert-EHFleetPackage -PackagePath $PackagePath -ExpectedSha256 $ExpectedSha256
$PackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$msdeploy = Get-EHFleetMSDeploy
Import-Module WebAdministration
$app = Get-WebApplication -Site $SiteName -Name $AppName
if (-not $app) { throw 'IIS-Anwendung fehlt. Zuerst das Installationsskript verwenden.' }
$target = [IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($app.PhysicalPath)).TrimEnd('\')
$siteRoot = [IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables((Get-Item "IIS:\Sites\$SiteName").PhysicalPath)).TrimEnd('\')
if ($target -eq $siteRoot -or $target -eq [IO.Path]::GetPathRoot($target).TrimEnd('\')) { throw 'Unsicheres Ziel: eigenes Anwendungsverzeichnis erforderlich.' }
if (-not (Test-Path -LiteralPath (Join-Path $target 'web.config'))) { throw 'Vorhandene web.config fehlt.' }
if ((Get-Item -LiteralPath $target).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Ziel darf keine Verknüpfung sein.' }
if (Get-ChildItem -LiteralPath $target -Recurse -Force | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }) {
    throw 'Verknüpfungen im Anwendungsverzeichnis werden für automatische Sicherung nicht unterstützt.'
}
$BackupRoot = [IO.Path]::GetFullPath($BackupRoot).TrimEnd('\')
if ($BackupRoot -eq $target -or $BackupRoot.StartsWith($target + '\', [StringComparison]::OrdinalIgnoreCase) -or
    $PackagePath.StartsWith($target + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Paket und Backup müssen außerhalb des Zielverzeichnisses liegen.' }
$pool = [string]$app.ApplicationPool
$poolUsers = @(Get-ChildItem IIS:\Sites | ForEach-Object {
    if ($_.ApplicationPool -eq $pool) { $_.Name }
    Get-WebApplication -Site $_.Name | Where-Object ApplicationPool -eq $pool
})
if ($poolUsers.Count -ne 1) { throw 'Update benötigt einen ausschließlich von dieser Anwendung verwendeten App-Pool.' }
if ((Get-WebAppPoolState -Name $pool).Value -ne 'Started') { throw 'App-Pool muss vor dem Update gestartet sein.' }
$backup = Join-Path $BackupRoot ($AppName + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N'))
if (-not $PSCmdlet.ShouldProcess("$SiteName/$AppName", "Sichern nach $backup, aktualisieren und WSDL prüfen")) { return }
New-Item -ItemType Directory -Path $backup -Force | Out-Null
# Sicherung enthält Zugangsdaten: nur Administratoren und SYSTEM zulassen.
$null = & icacls.exe $backup /inheritance:r /grant:r '*S-1-5-32-544:(OI)(CI)(F)' '*S-1-5-18:(OI)(CI)(F)'
if ($LASTEXITCODE -ne 0) { throw 'Sicherungsrechte konnten nicht gesetzt werden.' }
$backupComplete = $false
$deploymentStarted = $false
try {
    Stop-WebAppPool -Name $pool
    for ($i = 0; $i -lt 30 -and (Get-WebAppPoolState -Name $pool).Value -ne 'Stopped'; $i++) { Start-Sleep -Seconds 1 }
    if ((Get-WebAppPoolState -Name $pool).Value -ne 'Stopped') { throw 'App-Pool konnte nicht gestoppt werden.' }
    Copy-EHFleetBackup -Source $target -Destination (Join-Path $backup 'files')
    $backupComplete = $true
    $deploymentStarted = $true
    Invoke-EHFleetPackage -MSDeployExe $msdeploy -PackagePath $PackagePath -IisAppPath "$SiteName/$AppName" -PreserveConfig
    Start-WebAppPool -Name $pool
    Test-EHFleetService -Uri $SmokeTestUrl
    Write-Host "Update abgeschlossen. Sicherung: $backup"
} catch {
    $failure = $_
    if ($backupComplete -and $deploymentStarted) {
        try {
            Stop-WebAppPool -Name $pool -ErrorAction SilentlyContinue
            for ($i = 0; $i -lt 30 -and (Get-WebAppPoolState -Name $pool).Value -ne 'Stopped'; $i++) { Start-Sleep -Seconds 1 }
            if ((Get-WebAppPoolState -Name $pool).Value -ne 'Stopped') { throw 'App-Pool stoppt nicht für Rollback.' }
            # Vor /MIR das festgehaltene IIS-Ziel erneut prüfen.
            $current = [IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables((Get-WebApplication -Site $SiteName -Name $AppName).PhysicalPath)).TrimEnd('\')
            if ($current -ne $target -or $target -eq $siteRoot -or $target -eq [IO.Path]::GetPathRoot($target).TrimEnd('\')) { throw 'IIS-Ziel wurde während des Updates geändert.' }
            Copy-EHFleetBackup -Source (Join-Path $backup 'files') -Destination $target -Mirror
            Start-WebAppPool -Name $pool
            Test-EHFleetService -Uri $SmokeTestUrl
        } catch { throw "Update und Wiederherstellung fehlgeschlagen. App-Pool/Ziel prüfen; Sicherung: $backup. $($_.Exception.Message)" }
        throw "Update fehlgeschlagen; vorherige Dateien wiederhergestellt. Sicherung: $backup. $($failure.Exception.Message)"
    }
    Start-WebAppPool -Name $pool
    throw $failure
}
