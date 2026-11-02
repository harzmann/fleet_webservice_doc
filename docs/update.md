# Bestehende Installation aktualisieren

Das Updateskript verwendet den in IIS hinterlegten Anwendungspfad und App-Pool.
Es verändert weder Website-Bindungen noch Zugangsdaten. Alle Dateien namens
`web.config` werden beim Deployment beibehalten; lokale Dateien werden nicht automatisch gelöscht.
Neue Konfigurationseinträge/Binding Redirects und entfernte Programmdateien daher
vorab anhand der Releasehinweise prüfen und bei Bedarf gezielt anpassen.

## Vorbereitung

1. Wartungsfenster abstimmen, Benutzer abmelden und FLEET-Datenbank sichern.
2. Aktuelle Version, Anwendungspfad, App-Pool, Bindungen und Konfiguration dokumentieren.
3. Aktuelles [Skriptpaket](download.md) in einem neuen Ordner entpacken und
   das freigegebene Web-Deploy-Paket mit passender SHA256 bereitstellen.
4. Sicherstellen, dass die Anwendung einen eigenen, gestarteten App-Pool verwendet.
   Gemeinsam genutzte Pools werden abgelehnt, damit andere Anwendungen weiterlaufen.
5. Paket und Sicherungsordner müssen außerhalb des Anwendungsverzeichnisses liegen.

## Ausführen

Windows PowerShell 5.1 als Administrator öffnen:

```powershell
.\Update-EHFleetWebservice.ps1 `
  -SiteName 'FLEET Webservice' `
  -AppName 'ehfleet_webservice' `
  -PackagePath 'C:\Install\ehfleet_webservice.zip' `
  -BackupRoot 'C:\ProgramData\EHFleet\WebserviceBackups' `
  -SmokeTestUrl 'http://localhost:8080/ehfleet_webservice/WorkshopItems.asmx?WSDL'
```

Mit `-WhatIf` zuerst die Zielparameter prüfen. Optional `-ExpectedSha256` angeben;
die Prüfsumme muss zum **inneren Web-Deploy-Paket** gehören.

## Ablauf und Wiederherstellung

Das Skript prüft zuerst Paket und IIS-Ziel, stoppt den eigenen App-Pool und
sichert das vollständige Anwendungsverzeichnis in einen eindeutigen Unterordner.
Die Sicherung ist auf Administratoren und SYSTEM beschränkt und enthält auch
die vertrauliche Konfiguration. Danach werden die Programmdateien aktualisiert,
der App-Pool gestartet und der angegebene ASMX-/WSDL-Endpunkt getestet.

Scheitern Deployment oder Test, stellt das Skript die gesicherten Dateien zurück
und testet den alten Stand erneut. Schlägt auch die Wiederherstellung fehl,
meldet es den Sicherungspfad und bricht mit Fehler ab. Anwendung und App-Pool
dann manuell prüfen. Bei einer manuellen Dateiwiederherstellung den App-Pool
vorher stoppen und erst nach vollständig zurückgespielter Sicherung starten.

Die Wiederherstellung betrifft die Anwendungsdateien. Eine SQL-Migration wird
nicht ausgeführt und eine Datenbank wird nicht automatisch zurückgesetzt.
Bei Schemaänderungen sind die freigegebenen Datenbankschritte separat im
Wartungsfenster auszuführen. Verknüpfungen/Junctions im Ziel werden abgelehnt.

Nach Erfolg die Anmeldung und die verwendeten Fachfunktionen im Client prüfen.
Sicherung bis zur erfolgreichen Abnahme aufbewahren; alte Backups nach der
betrieblichen Aufbewahrungsregel entfernen.
