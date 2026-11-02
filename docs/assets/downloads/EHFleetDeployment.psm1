#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-EHFleetAdministrator {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Windows PowerShell 5.1 als Administrator starten.'
    }
    if ($PSVersionTable.PSEdition -eq 'Core') { throw 'IIS-Skripte mit Windows PowerShell 5.1 (powershell.exe) starten.' }
}

function Get-EHFleetMSDeploy {
    foreach ($root in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        if ($root) {
            $candidate = Join-Path $root 'IIS\Microsoft Web Deploy V3\msdeploy.exe'
            if (Test-Path -LiteralPath $candidate) { return $candidate }
        }
    }
    throw 'Microsoft Web Deploy 3.6 fehlt. Zuerst mit dem Microsoft-Installer einrichten.'
}

function Assert-EHFleetPackage {
    param([string]$PackagePath, [string]$ExpectedSha256)
    if (-not (Test-Path -LiteralPath $PackagePath -PathType Leaf)) { throw 'Web-Deploy-Paket nicht gefunden.' }
    if ($ExpectedSha256 -and (Get-FileHash -LiteralPath $PackagePath -Algorithm SHA256).Hash -ne $ExpectedSha256) {
        throw 'SHA256 des Web-Deploy-Pakets stimmt nicht überein.'
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $PackagePath).Path)
    try {
        if (-not ($zip.Entries | Where-Object { $_.FullName -eq 'archive.xml' })) {
            throw 'Kein Web-Deploy-Paket: archive.xml fehlt. Das äußere Kundenpaket zuerst entpacken.'
        }
    } finally { $zip.Dispose() }
}

function Invoke-EHFleetPackage {
    param([string]$MSDeployExe, [string]$PackagePath, [string]$IisAppPath,
          [string]$ConnectionString, [switch]$PreserveConfig)
    $temp = Join-Path ([IO.Path]::GetTempPath()) ('EHFleet-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $temp | Out-Null
    try {
        # Zugangsdaten weder in Prozessargumenten noch in allgemein lesbaren Dateien.
        $acl = New-Object Security.AccessControl.DirectorySecurity
        $acl.SetAccessRuleProtection($true, $false)
        foreach ($sid in @('S-1-5-32-544', 'S-1-5-18')) {
            $identity = New-Object Security.Principal.SecurityIdentifier($sid)
            $rule = New-Object Security.AccessControl.FileSystemAccessRule($identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
            $acl.AddAccessRule($rule)
        }
        Set-Acl -LiteralPath $temp -AclObject $acl
        $file = Join-Path $temp 'SetParameters.xml'
        $xml = New-Object Xml.XmlDocument
        $root = $xml.CreateElement('parameters')
        $null = $xml.AppendChild($root)
        $values = @{ 'IIS Web Application Name' = $IisAppPath }
        if (-not $PreserveConfig) { $values['EHFleetConnectionString-Web.config Connection String'] = $ConnectionString }
        foreach ($name in $values.Keys) {
            $node = $xml.CreateElement('setParameter')
            $node.SetAttribute('name', $name)
            $node.SetAttribute('value', $values[$name])
            $null = $root.AppendChild($node)
        }
        $xml.Save($file)
        $arguments = @('-verb:sync', "-source:package='$PackagePath'", '-dest:auto',
            "-setParamFile:$file", '-disableLink:AppPoolExtension', '-disableLink:CertificateExtension',
            '-disableLink:ContentExtension', '-enableRule:DoNotDeleteRule')
        if ($PreserveConfig) { $arguments += '-skip:objectName=filePath,absolutePath=(?i)\\web\.config$' }
        $null = & $MSDeployExe @arguments 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Web Deploy fehlgeschlagen (Exitcode $LASTEXITCODE). IIS-Konfiguration und Paket prüfen." }
    } finally {
        $resolved = [IO.Path]::GetFullPath($temp)
        $parent = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
        if ([IO.Path]::GetDirectoryName($resolved) -ne $parent -or [IO.Path]::GetFileName($resolved) -notlike 'EHFleet-*') { throw 'Ungültiger temporärer Pfad.' }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}

function Test-EHFleetService {
    param([uri]$Uri)
    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try {
            $response = Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 30
            $wsdl = New-Object Xml.XmlDocument
            $wsdl.XmlResolver = $null
            $wsdl.LoadXml($response.Content)
            if ($response.StatusCode -eq 200 -and $wsdl.DocumentElement.LocalName -eq 'definitions' -and
                $wsdl.DocumentElement.NamespaceURI -eq 'http://schemas.xmlsoap.org/wsdl/') {
                Write-Host "ASMX/WSDL erreichbar: $Uri"
                return
            }
        } catch { }
        if ($attempt -lt 5) { Start-Sleep -Seconds 2 }
    }
    throw "ASMX/WSDL-Test fehlgeschlagen: $Uri"
}

function Copy-EHFleetBackup {
    param([string]$Source, [string]$Destination, [switch]$Mirror)
    $copyArgs = @($Source, $Destination, '/E', '/COPY:DAT', '/DCOPY:DAT', '/R:1', '/W:1', '/XJ', '/NFL', '/NDL', '/NJH', '/NJS')
    if ($Mirror) { $copyArgs += '/MIR' }
    $null = & robocopy.exe @copyArgs
    if ($LASTEXITCODE -ge 8) { throw "Dateisicherung/Wiederherstellung fehlgeschlagen (Robocopy $LASTEXITCODE)." }
}

Export-ModuleMember -Function *-EHFleet*
