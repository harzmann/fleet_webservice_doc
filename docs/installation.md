# Neuinstallation auf IIS

## Voraussetzungen

- Windows Server mit IIS-Unterstützung, administrativer Zugriff und Windows PowerShell 5.1 (`powershell.exe`).
- .NET Framework 4.8 oder neuer und Microsoft Web Deploy 3.6 bereits installiert.
- Freigegebenes **Web-Deploy-Paket** `ehfleet_webservice.zip` der gewünschten Version.
- Erreichbare FLEET-SQL-Datenbank mit passendem Schema und zugelassenem Datenbankkonto.
- Eigene IIS-Anwendung, eigener App-Pool und ein leeres Zielverzeichnis.
- Wartungsfenster, Datenbanksicherung und abgestimmte Client-/FLEET-Versionen.

Der Installer aktiviert fehlende IIS-/ASP.NET-Windows-Features. Falls Windows
einen Neustart verlangt, den Server neu starten und den Installer erneut ausführen.
Er installiert weder SQL Server noch FLEET und führt keine Datenbankmigrationen aus.
Web Deploy vorab über den [Microsoft-Installer](https://www.iis.net/downloads/microsoft/web-deploy) installieren.

## Download und Prüfung

1. [Skriptpaket](download.md) herunterladen und vollständig entpacken.
2. Alle drei Dateien (`Install-EHFleetWebservice.ps1`, `Update-EHFleetWebservice.ps1`,
   `EHFleetDeployment.psm1`) im selben Ordner lassen.
3. Das freigegebene Web-Deploy-Paket in einen separaten Installationsordner legen.
   Ein äußeres Kundenpaket zuerst entpacken; `-PackagePath` muss auf das innere Web-Deploy-ZIP zeigen.
4. SHA256 mit der vom Lieferanten bereitgestellten Prüfsumme vergleichen:

```powershell
Get-FileHash .\ehfleet_webservice.zip -Algorithm SHA256
```

Für einen Testlauf `-WhatIf` ergänzen. Voraussetzungen werden geprüft, IIS und
Dateien werden dabei nicht verändert. Bei Bedarf die heruntergeladenen und
geprüften Skriptdateien über die Dateieigenschaften oder `Unblock-File` entsperren.

## SQL-Authentifizierung

Windows PowerShell als Administrator öffnen. Das Passwort über den Dialog eingeben:

```powershell
$sqlLogin = Get-Credential -Message 'SQL-Anmeldung für FLEET'
.\Install-EHFleetWebservice.ps1 `
  -SiteName 'FLEET Webservice' `
  -AppName 'ehfleet_webservice' `
  -AppPoolName 'ehfleet_webservice' `
  -Port 8080 `
  -PhysicalPath 'C:\inetpub\wwwroot\ehfleet_webservice' `
  -PackagePath 'C:\Install\ehfleet_webservice.zip' `
  -SqlServer 'SQLSERVER\INSTANZ' `
  -Database 'EHFleet' `
  -SqlCredential $sqlLogin
```

Optional `-ExpectedSha256 '<64-stelliger SHA256-Wert des inneren Web-Deploy-ZIP>'`
angeben. Der Installer lehnt eine abweichende Prüfsumme ab.
`SqlUser` und `SqlPassword` werden aus Kompatibilitätsgründen unterstützt;
für interaktive Installationen den Anmeldedialog verwenden.

## Windows-Authentifizierung

Statt `-SqlCredential` den Schalter `-UseWindowsAuth` verwenden. Der App-Pool läuft
mit `ApplicationPoolIdentity`. Für einen entfernten SQL-Server muss die dafür
verwendete Domänen-/Computeridentität explizit berechtigt werden; ein lokales
virtuelles App-Pool-Konto ist kein eigenständiges Domänenkonto.

## IIS-Einrichtung

Das Skript erstellt eine eigene Website, falls sie noch nicht existiert, einen
eigenen App-Pool und eine Anwendung. Bei vorhandener Website muss die angegebene
HTTP-Bindung bereits vorhanden sein. Bestehende Bindungen werden nicht verändert.
Bei Portkonflikten einen freien Port bzw. einen passenden Hostnamen mit `-HostName` angeben.
Vorhandene Anwendungen oder nicht leere Zielordner werden abgelehnt; dafür das Updateskript verwenden.

Die App-Pool-Identität erhält NTFS-Leserechte. Schreibrechte nur für tatsächlich
benötigte Dokument-/Exportordner vergeben. Anschließend HTTPS mit einem gültigen
Zertifikat im IIS einrichten und die Clients auf diese HTTPS-Basis-URL einstellen.

## Abnahme

Das Skript prüft standardmäßig `http://localhost:8080/ehfleet_webservice/WorkshopItems.asmx?WSDL`.
Eine abweichende Testadresse mit `-SmokeTestUrl` übergeben.
Zusätzlich im Clientnetz WSDL, FLEET-Anmeldung, Geräteaktivierung/Berechtigungen
und eine lesende sowie eine freigegebene schreibende Funktion prüfen.
Ein erfolgreicher WSDL-Aufruf bestätigt noch keine funktionierende Datenbankanmeldung.

Bei Fehlern: IIS-Protokolle, Windows-Ereignisanzeige, App-Pool, ASP.NET-Rollen,
Datenbankverbindung und eine eventuell gesetzte `EHFLEET_CONNECTION_STRING` prüfen.
Scheitert das Deployment, stoppt der Installer den neu angelegten Pool. Teilweise
angelegte Anwendung/Dateien vor einem neuen Installationsversuch gezielt prüfen und bereinigen.
