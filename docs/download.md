# Downloads

## Skripte für IIS

[Alle IIS-Skripte als ZIP herunterladen](assets/downloads/FLEET-Webservice-IIS-Skripte.zip)
· [SHA256](assets/downloads/FLEET-Webservice-IIS-Skripte.zip.sha256)

| Datei | Verwendung |
| --- | --- |
| [Install-EHFleetWebservice.ps1](assets/downloads/Install-EHFleetWebservice.ps1) | Neuinstallation von IIS-Anwendung und App-Pool. |
| [Update-EHFleetWebservice.ps1](assets/downloads/Update-EHFleetWebservice.ps1) | Update mit Sicherung und Wiederherstellung bei Fehlern. |
| [EHFleetDeployment.psm1](assets/downloads/EHFleetDeployment.psm1) | Gemeinsame Funktionen; muss neben beiden Skripten liegen. |

ZIP vollständig entpacken. Die Skripte enthalten keine Programmdateien und keine
Zugangsdaten. Zusätzlich wird das freigegebene Web-Deploy-Paket benötigt.

Prüfsumme des heruntergeladenen Skriptpakets vergleichen:

```powershell
Get-FileHash .\FLEET-Webservice-IIS-Skripte.zip -Algorithm SHA256
```

Siehe [Neuinstallation](installation.md) und [Update](update.md).

Erwartete SHA256 des Skriptpakets: `e1b83fef396f98126bacc175ff3fddf7fc3a6675427c92ab197d272ce4a2e5d7`.

Dokumentierter Assembly-Stand: **1.3.10.0**. Umfang: **103 Webmethoden**.

## Web-Deploy-Paket

Ein geprüftes Programmpaket erhalten Sie über EH Systemhaus. Der nächste freigegebene Build veröffentlicht das Kundenpaket auch hier.

