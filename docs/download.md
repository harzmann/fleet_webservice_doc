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

Erwartete SHA256 des Skriptpakets: `7e0cc2a19270b4f08b9692b74e9e5ff4759ce29c881e089eeb8d7c037ae44bc1`.

Dokumentierter Assembly-Stand: **1.3.11.0**. Umfang: **103 Webmethoden**.

## Aktuelles Kundenpaket

[Installationspaket 1.3.11.0](assets/downloads/EHFleet_Webservice_1.3.11.0_d39c500a_Installation.zip) · [SHA256](assets/downloads/EHFleet_Webservice_1.3.11.0_d39c500a_Installation.zip.sha256)

Enthält Web-Deploy-Paket, Neuinstallations-/Updateskripte und Anleitung.


