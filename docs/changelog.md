# Änderungsprotokoll

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format orientiert sich an Keep a Changelog. Die Versionierung folgt der vorhandenen Assembly-Version aus dem Visual-Studio-Projekt.

## [Unveröffentlicht]

### Hinzugefügt

- Öffentliches Kundenportal `harzmann/fleet_webservice_doc` mit MkDocs Material und GitHub Pages, Architekturübersicht, vollständiger Referenz aller 103 ASMX-Webmethoden sowie separaten Installations-, Update- und Downloadseiten.
- Eigenes IIS-Updateskript mit geschützter Dateisicherung, Erhalt der vorhandenen Konfiguration und automatischer Dateiwiederherstellung bei Deployment-/WSDL-Fehlern.
- Gemeinsames Deployment-Modul und herunterladbares IIS-Skriptpaket mit SHA256; sichere Übergabe der SQL-Konfiguration über eine geschützte Parameterdatei.
- `AGENTS.md` verpflichtet zur Pflege von ChangeLog, Installation, Update und Kundenportal bei Commit und Push.

- Automatische Erstellung eines installierbaren Kundenpakets mit Web-Deploy-Paket, IIS-Installationsskript, Kurzinstallationsanleitung und SHA256-Prüfsumme.
- Automatische Aktualisierung des öffentlichen MkDocs-Repositories `harzmann/ehfleet_webservice_docs` bei Push auf `master`.
- Öffentliche Download-, Installations- und Änderungsseiten für GitHub Pages.

### Geändert

- Release-Pakete schließen Quell-, Projekt-, Publish- und Debugdateien auch im Binärordner explizit aus; kompilierte SQL-Konfigurationsseiten kopieren ihren VB-Quellcode nicht mehr in den Ausgabeordner. Dies behebt den Abbruch der Kundenpaketerstellung im produktiven Deployment.
- Die Kundenpaketprüfung akzeptiert den versionierten Platzhalter `{{SQL_PASSWORD}}`, während echte Passwortwerte weiterhin abgelehnt werden.
- Werkstattaufträge schreiben nicht verwendete `KFZNr`-/`KundenNr`-Referenzen jetzt als Datenbank-`NULL`; Fahrzeug- und Kundenaufträge bleiben gegenseitig exklusiv.
- README und Änderungsprotokoll wurden auf deutsche Sprache mit Umlauten umgestellt.
- Der Deployment-Workflow veröffentlicht die Kundendokumentation zusätzlich zum bestehenden IIS-Deployment.

## [1.3.10.0] - 2026-06-12

### Hinzugefügt

- GitHub-Migrationsdokumentation für den ASMX-Webservice.
- GitHub-Actions-Workflow für Build und Deployment per MSDeploy.
- IIS-Installationsskript für Kundeninstallationen mit Web-Deploy-Paket.
- `web.config.template` mit Platzhaltern für die Datenbankverbindung.
- Lokale Debug-Übersteuerung der Verbindungszeichenfolge über `EHFLEET_CONNECTION_STRING`.
- `WorkshopItems.GetStockInventoryList` für Lagerbestandsdaten aus `abfr_lagerbestand`.
- `WorkshopItems.DeleteReceiptPosition` zum Löschen von Lieferanten-Lagerzugängen anhand der Bewegungs-ID.
- `WorkshopItems.GetLabelPrinters` zur Ermittlung von MDE-Etikettendruckern.
- `WorkshopItems.PrintReceiptLabel` für serverseitigen Etikettendruck aus MDE-Wareneingängen.
- Idempotentes MDE-Schema-Skript für Etikettendruck mit Druckern, Vorlagen, Gerätezuordnungen und Druckprotokoll.

### Geändert

- `web.config` enthält jetzt einen Platzhalter für `EHFleetConnectionString` statt einer kundenspezifischen Standardverbindung.
- Das GitHub-Actions-Deployment baut das Web-Deploy-Paket auf einem Entwicklungsrunner und installiert es remote auf `<IIS-Zielserver>` per MSDeploy.
- `CreateReceiptPosition` verwendet den Berechtigungspfad `frmLagerzugang` nun konsistent über die Klassenbibliothek.
- `GetStockInventoryList` akzeptiert einen leeren Parameter `ArtikelID` von ASMX-Clients und behandelt ihn als `0`.
- Webservice-Endpunkte lösen die Datenbankverbindung über einen gemeinsamen Helfer auf, bevor sie auf `web.config` zurückfallen.
- Local-IIS-Debugging kann die Testdatenbankverbindung aus `LocalDebuggerEnvironment` lesen, ohne `web.config` zu ändern.
- Web-Deploy-Pakete schließen `.vbproj.user` aus, damit lokale Debug-Zugangsdaten nicht deployt werden.
- `web.config.template` enthält Binding Redirects für die JSON-Laufzeitabhängigkeiten der Etikettenvorlagen.

