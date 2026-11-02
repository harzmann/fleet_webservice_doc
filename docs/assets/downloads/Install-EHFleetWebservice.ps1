#requires -Version 5.1
<# Neuinstallation. EHFleetDeployment.psm1 muss im selben Verzeichnis liegen. #>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$SiteName = 'Default Web Site',
    [ValidatePattern('^[a-zA-Z0-9_-]+$')][string]$AppName = 'ehfleet_webservice',
    [ValidatePattern('^[a-zA-Z0-9_-]+$')][string]$AppPoolName = 'ehfleet_webservice',
    [ValidateRange(1,65535)][int]$Port = 8080,
    [string]$HostName = '',
    [string]$PhysicalPath = 'C:\inetpub\wwwroot\ehfleet_webservice',
    [Parameter(Mandatory)][string]$PackagePath,
    [ValidatePattern('^[a-fA-F0-9]{64}$')][string]$ExpectedSha256,
    [Parameter(Mandatory)][string]$SqlServer,
    [Parameter(Mandatory)][string]$Database,
    [PSCredential]$SqlCredential,
    [string]$SqlUser,
    [string]$SqlPassword,
    [switch]$UseWindowsAuth,
    [uri]$SmokeTestUrl
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'EHFleetDeployment.psm1') -Force
Assert-EHFleetAdministrator
Assert-EHFleetPackage -PackagePath $PackagePath -ExpectedSha256 $ExpectedSha256
$PackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$msdeploy = Get-EHFleetMSDeploy
$PhysicalPath = [IO.Path]::GetFullPath($PhysicalPath).TrimEnd('\')
if ($PhysicalPath -eq [IO.Path]::GetPathRoot($PhysicalPath).TrimEnd('\')) { throw 'Das Ziel darf kein Laufwerksstamm sein.' }
if ((Test-Path -LiteralPath $PhysicalPath) -and (Get-ChildItem -LiteralPath $PhysicalPath -Force | Select-Object -First 1)) {
    throw 'Zielverzeichnis ist nicht leer. Für vorhandene Installationen das Updateskript verwenden.'
}
$release = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction Stop).Release
if ($release -lt 528040) { throw '.NET Framework 4.8 oder neuer ist erforderlich.' }
if (-not $PSCmdlet.ShouldProcess("$SiteName/$AppName ($PhysicalPath)", 'IIS-Features aktivieren und FLEET Webservice installieren')) { return }
if (-not $UseWindowsAuth -and -not $SqlCredential) {
    if ($SqlUser -and $SqlPassword) {
        $SqlCredential = New-Object PSCredential($SqlUser, (ConvertTo-SecureString $SqlPassword -AsPlainText -Force))
    } else { $SqlCredential = Get-Credential -Message 'SQL-Anmeldung für die FLEET-Datenbank' }
    if (-not $SqlCredential) { throw 'SQL-Anmeldung fehlt.' }
}
$builder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder
$builder.Provider = 'SQLOLEDB.1'
$builder['Data Source'] = $SqlServer
$builder['Initial Catalog'] = $Database
$builder['Persist Security Info'] = $false
if ($UseWindowsAuth) { $builder['Integrated Security'] = 'SSPI' }
else {
    $builder['User ID'] = $SqlCredential.UserName
    $builder['Password'] = $SqlCredential.GetNetworkCredential().Password
}
foreach ($featureName in @('IIS-WebServerRole','IIS-WebServer','IIS-CommonHttpFeatures','IIS-StaticContent',
    'IIS-DefaultDocument','IIS-ASPNET45','IIS-NetFxExtensibility45','IIS-ISAPIExtensions','IIS-ISAPIFilter','IIS-ManagementConsole')) {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName
    if ($feature.State -ne 'Enabled') {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName $featureName -All -NoRestart
        if ($result.RestartNeeded) { throw 'Windows-Neustart erforderlich. Danach Installer erneut starten.' }
    }
}
Import-Module WebAdministration
if (Test-Path "IIS:\Sites\$SiteName\$AppName") { throw 'IIS-Anwendung existiert bereits. Updateskript verwenden.' }
if (Test-Path "IIS:\AppPools\$AppPoolName") { throw 'App-Pool existiert bereits. Für die Neuinstallation einen eigenen Namen wählen.' }
$bindingInformation = "*:${Port}:${HostName}"
if (Test-Path "IIS:\Sites\$SiteName") {
    if (-not (Get-WebBinding -Name $SiteName -Protocol http | Where-Object bindingInformation -eq $bindingInformation)) {
        throw 'Die bestehende Website hat nicht die angegebene HTTP-Bindung. Port/HostName prüfen oder eine eigene Site angeben.'
    }
} elseif (Get-WebBinding | Where-Object bindingInformation -eq $bindingInformation) {
    throw 'Die gewünschte Bindung wird bereits verwendet. Anderen Port oder HostName wählen.'
}
New-Item -ItemType Directory -Path $PhysicalPath -Force | Out-Null
New-WebAppPool -Name $AppPoolName | Out-Null
Set-ItemProperty "IIS:\AppPools\$AppPoolName" managedRuntimeVersion 'v4.0'
Set-ItemProperty "IIS:\AppPools\$AppPoolName" managedPipelineMode 'Integrated'
Set-ItemProperty "IIS:\AppPools\$AppPoolName" processModel.identityType 4
if (-not (Test-Path "IIS:\Sites\$SiteName")) {
    $siteRoot = Join-Path (Split-Path $PhysicalPath -Parent) ($AppName + '-site')
    New-Item -ItemType Directory -Path $siteRoot -Force | Out-Null
    New-Website -Name $SiteName -Port $Port -HostHeader $HostName -PhysicalPath $siteRoot | Out-Null
}
New-WebApplication -Site $SiteName -Name $AppName -PhysicalPath $PhysicalPath -ApplicationPool $AppPoolName | Out-Null
$null = & icacls.exe $PhysicalPath /grant "IIS AppPool\${AppPoolName}:(OI)(CI)(RX)"
if ($LASTEXITCODE -ne 0) { throw 'NTFS-Leserechte konnten nicht gesetzt werden.' }
try {
    Invoke-EHFleetPackage -MSDeployExe $msdeploy -PackagePath $PackagePath -IisAppPath "$SiteName/$AppName" -ConnectionString $builder.ConnectionString
    if (-not $SmokeTestUrl) {
        $server = if ($HostName) { $HostName } else { 'localhost' }
        $SmokeTestUrl = "http://${server}:$Port/$AppName/WorkshopItems.asmx?WSDL"
    }
    Test-EHFleetService -Uri $SmokeTestUrl
} catch {
    Stop-WebAppPool -Name $AppPoolName
    throw 'Installation fehlgeschlagen; neuer App-Pool wurde gestoppt. IIS-Anwendung und Konfiguration prüfen, vor erneutem Installieren neue Anwendung/Dateien entfernen oder Updateskript nutzen.'
} finally { $builder.Clear(); $SqlPassword = $null; $SqlCredential = $null }
Write-Host 'Neuinstallation abgeschlossen. HTTPS-Bindung einrichten und fachliche Anmeldung im FLEET-Client testen.'
