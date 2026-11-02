# FLEET Webservice Kundenportal

Der FLEET Webservice verbindet mobile Geräte, FLEET MDE und Integrationsclients
mit der FLEET-Datenbank. Er stellt Fahrzeug-, Personal- und Lieferantenstammdaten
bereit und verarbeitet Werkstattaufträge, Mängel, Artikel und Lagerbewegungen,
Zeiterfassung, Unfälle, Abfahrtskontrollen und Führerscheinkontrollen.

## Funktionsbeschreibung

Die Schnittstelle besteht aus elf ASMX-Diensten mit derzeit 103 Webmethoden.
Sie unterstützt das Lesen von Listen und Details sowie das Erstellen,
Ändern und Löschen fachlicher Datensätze und zugehöriger Dokumente.
Der Bereich Werkstattartikel bietet zusätzlich Inventur, Wareneingang
und serverseitigen Etikettendruck.

Alle Methoden mit Zweck, Parametern und Rückgabetyp stehen auf der Seite
[Webservice-Funktionen](functions.md).

## Aufbau

```text
FLEET MDE / mobile Geräte / Integrationsclient
                 | HTTPS, SOAP/XML
                 v
       IIS: FLEET ASMX-Webservice (.NET Framework 4.8)
                 | Methodenaufrufe
                 v
       ehfleet_classlibrary: Geschäftslogik und Berechtigungen
                 | Datenbankzugriff
                 v
              FLEET SQL-Datenbank
```

Die Webservice-Schicht ist in Visual Basic .NET implementiert. Jeder Fachbereich
hat einen eigenen Endpunkt, zum Beispiel `WorkshopOrders.asmx` für Werkstattaufträge.
Die ASMX-Schicht reicht die Aufrufe an `ehfleet_classlibrary` weiter. Diese
übernimmt die fachliche Verarbeitung und die Prüfung der Benutzer- und Geräteberechtigungen.
Die WSDL eines Endpunkts ist unter `<Basis-URL>/<Dienst>.asmx?WSDL` verfügbar.

## Implementierung innerhalb FLEET

Der Dienst greift über die Klassenbibliothek auf die bestehende FLEET-Datenbank
zu. Er ersetzt weder die FLEET-Anwendung noch deren Datenbankschema.
Vor der Nutzung müssen FLEET-Benutzer, Berechtigungen und mobile Geräte in der
jeweiligen FLEET-Installation eingerichtet sein. Die meisten Methoden verlangen
`User`, `Password` und `DeviceID`; Geräteaktivierung und Anmeldung sind in
`GeneralRegistration.asmx` zusammengefasst.

Clients werden auf die Basis-URL der IIS-Anwendung eingestellt. Webservice,
Klassenbibliothek, Datenbankstand und Clientversion müssen zueinander passen.
Für Etikettendruck müssen zusätzlich die MDE-Drucker, Vorlagen und Gerätezuordnungen
eingerichtet sein; Drucker müssen vom IIS-Server aus erreichbar sein.

## Implementierung innerhalb IIS

Der Webservice läuft als eigene IIS-Anwendung mit einem eigenen Anwendungspool
(.NET CLR v4.0, integrierte Pipeline) auf .NET Framework 4.8.
Das Web-Deploy-Paket enthält die ASMX-Endpunkte und die benötigten Bibliotheken.
IIS benötigt ASP.NET 4.x, .NET-Erweiterungen und ISAPI-Unterstützung.

Die Verbindung zur FLEET-Datenbank steht in `web.config` unter
`connectionStrings/EHFleetConnectionString`. Eine gesetzte Umgebungsvariable
`EHFLEET_CONNECTION_STRING` hat Vorrang. Nach Änderung einer Umgebungsvariable
den betroffenen Workerprozess neu starten. SQL-Authentifizierung und Windows-
Authentifizierung sind im Installer wählbar; für Windows-Authentifizierung
muss die tatsächliche App-Pool-Identität auf dem SQL-Server berechtigt sein.

Für Kunden- und Gerätenetze ist eine HTTPS-Bindung mit gültigem Zertifikat
einzurichten. Die Skripte erzeugen für die Erstprüfung eine HTTP-Bindung;
Zertifikat, Firewall und Namensauflösung richtet der Administrator passend zur Umgebung ein.

## Installation und Betrieb

- [Neuinstallation auf IIS](installation.md)
- [Bestehende Installation aktualisieren](update.md)
- [Installations- und Updateskripte herunterladen](download.md)
- [Änderungsprotokoll](changelog.md)
