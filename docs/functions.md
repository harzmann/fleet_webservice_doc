# Webservice-Funktionen

Diese Referenz umfasst alle öffentlichen ASMX-Webmethoden des Webservices.
Sie wird aus den Methodenverträgen erzeugt. Die Gruppierung folgt den elf Endpunkten.

## Aufruf und gemeinsame Parameter

Basis-URL: `https://<server>/<anwendung>/`. WSDL: `<Dienst>.asmx?WSDL`.
Die Dienste verwenden den Namespace `http://tempuri.org/` und SOAP/XML.
Ein SOAP-Client sollte die WSDL der installierten Version importieren, damit
auch die vollständigen Response-Felder und XML-Typen verfügbar sind.
Die folgenden Typen verwenden die VB-.NET-Schreibweise (`Integer`, `Date`, `Boolean`, `Double`).
Datumswerte und Zahlen werden im SOAP-XML entsprechend dem WSDL-Schema serialisiert.

| Parameter | Bedeutung |
| --- | --- |
| `User`, `Password` | FLEET-Anmeldung; über HTTPS im Methodenaufruf übertragen. |
| `DeviceID` | Kennung des freigeschalteten mobilen Geräts. |
| `ID` | Interne ID des jeweils genannten Datensatzes; nicht automatisch die sichtbare Nummer. |
| `PersonalID`, `KFZNr`, `KundenNr`, `ArtikelID` | Fachbezogene Referenzen; Typ und Bedeutung der jeweiligen Methode beachten. |
| `SortByField` | Sortierfeld der jeweiligen Liste; zulässige Werte richten sich nach der Fachlogik. |
| `Base64Stream` | Dokumentinhalt als Base64-Zeichenfolge. |

Nicht jede Methode hat alle gemeinsamen Parameter. Parameterlisten unten sind vollständig.
HTTP 200 allein ist kein fachlicher Erfolg: soweit der Rückgabetyp die Felder
`IsSuccessful`, `Message` und `MessageID` enthält, diese ebenfalls auswerten.
Array-Rückgaben sind durch `()` markiert. Schreiboperationen nicht blind wiederholen,
weil dadurch Datensätze oder Buchungen mehrfach entstehen können.

## Besonderheiten

- `GeneralRegistration.ListUserLogins` besitzt keine Anmeldeparameter; Zugriff auf die Endpunkte passend im Netz begrenzen.
- `GetStockInventoryList`: Leeres `ArtikelID` wird als `0` behandelt, ungültige Ganzzahlen liefern einen fachlichen Fehler.
- `DeleteReceiptPosition` verwendet die ID der Lagerbewegung, nicht die Artikel-ID.
- `PrintReceiptLabel` benötigt eine gültige Wareneingangsposition, einen zugeordneten Drucker und die Kopienanzahl. Drucker/Vorlagen müssen in FLEET eingerichtet sein.
- Werkstattaufträge verwenden Fahrzeug- oder Kundenbezug; nicht verwendete Referenzen werden in der Fachlogik als Datenbank-NULL gespeichert.
- CSV-Strukturen und Response-Feldschemas sind versionsabhängig. Für die Clientimplementierung WSDL und abgestimmte FLEET-Version verwenden.

## Abfahrtskontrollen

Endpunkt: `DepartureControl.asmx` · WSDL: `DepartureControl.asmx?WSDL`

### DepartureControl.GetPatternList

Vorlagenliste mit zugehörigen Aufaben.

**Rückgabe:** `Staff.DepartureControl.Pattern_Response()`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.CreateDepartureControl

Abfahrtskontrolle erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `PersonalNr` | `Integer` |
| `KFZNr` | `Integer` |
| `Kontrolldatum` | `Date` |
| `Kontrollort` | `String` |
| `Longitude` | `Double` |
| `Latitude` | `Double` |
| `Kurzbezeichnung` | `String` |
| `Kilometerstand` | `Double` |
| `Erledigt` | `Boolean` |
| `ErledigtDatum` | `Date` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.CreatePosition

Abfahrtskontrolle Position erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `AbfahrtskontrolleID` | `Integer` |
| `AbfahrtskontrolleAufgabeID` | `Integer` |
| `Erledigt` | `Boolean` |
| `ErledigtDatum` | `Date` |
| `Ergebnis` | `Boolean` |
| `Zusatzangabe` | `String` |
| `MangelID` | `Integer` |
| `Bemerkung` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.UpdateDepartureControl

Abfahrtskontrolle aktualisieren.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `PersonalNr` | `Integer` |
| `KFZNr` | `Integer` |
| `Kontrolldatum` | `Date` |
| `Kontrollort` | `String` |
| `Longitude` | `Double` |
| `Latitude` | `Double` |
| `Kurzbezeichnung` | `String` |
| `Kilometerstand` | `Double` |
| `Erledigt` | `Boolean` |
| `ErledigtDatum` | `Date` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.UpdatePosition

Abfahrtskontrolle Position aktualisieren.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `Erledigt` | `Boolean` |
| `ErledigtDatum` | `Date` |
| `Ergebnis` | `Boolean` |
| `Zusatzangabe` | `String` |
| `MangelID` | `Integer` |
| `Bemerkung` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.GetDepartureControlsList

Liste aller Abfahrtskontrollen.

**Rückgabe:** `Staff.DepartureControl.DepartureControl_Response()`.

| Parameter | Typ |
| --- | --- |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.GetDepartureControlsListOpen

Liste offene Abfahrtskontrollen.

**Rückgabe:** `Staff.DepartureControl.DepartureControl_Response()`.

| Parameter | Typ |
| --- | --- |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.GetDepartureControlsListClosed

Liste erledigte Abfahrtskontrollen.

**Rückgabe:** `Staff.DepartureControl.DepartureControl_Response()`.

| Parameter | Typ |
| --- | --- |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.GetDepartureControlsListVehicle

Liste Abfahrtskontrollen eines Fahrzeuges.

**Rückgabe:** `Staff.DepartureControl.DepartureControl_Response()`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `Integer` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.GetDepartureControlsListStaff

Liste Abfahrtskontrollen einer Person.

**Rückgabe:** `Staff.DepartureControl.DepartureControl_Response()`.

| Parameter | Typ |
| --- | --- |
| `PersonalID` | `Integer` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.GetDepartureControlsListID

Liste Abfahrtskontrollen ab ID.

**Rückgabe:** `Staff.DepartureControl.DepartureControl_Response()`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.GetDepartureControlDetails

Details Abfahrtskontrolle.

**Rückgabe:** `Staff.DepartureControl.DepartureControl_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.GetDepartureControlPositions

Positionen Abfahrtskontrolle.

**Rückgabe:** `Staff.DepartureControl.Position_Response()`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.CreateDepartureControlDocument

Bild/Dokument zu Abfahrtskontrolle erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `AbfahrtskontrolleID` | `Integer` |
| `Bezeichnung` | `String` |
| `Dateiname` | `String` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `Base64Stream` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.UpdateDepartureControlDocument

Bild/Dokument zu Abfahrtskontrolle ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `Bezeichnung` | `String` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.DeleteDepartureControlDocument

Bild/Dokument zu Abfahrtskontrolle löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DepartureControl.GetDepartureControlDocuments

Bilder/Dokumente Abfahrtskontrolle abrufen.

**Rückgabe:** `General.Files.Base64File_Response()`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `AbfahrstkonrolleID` | `Integer` |
| `NoBase64Stream` | `Boolean` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

## Führerscheinkontrollen

Endpunkt: `DriverLicenseControl.asmx` · WSDL: `DriverLicenseControl.asmx?WSDL`

### DriverLicenseControl.SendDriverLicenseCheck

Senden Führerscheinkontrolle EHFleet.

**Rückgabe:** `Staff.DriverLicenseControl.DriverLicenseControl_Response`.

| Parameter | Typ |
| --- | --- |
| `CSV` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DriverLicenseControl.WriteFileDriverLicenseCheck

Schreiben Führerscheinkontrolle EHFleet.

**Rückgabe:** `Staff.DriverLicenseControl.DriverLicenseControl_Response`.

| Parameter | Typ |
| --- | --- |
| `CSV` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### DriverLicenseControl.GetDriverLicenseAnalysis

Auswertung Führerscheinkontrollen EHFleet.

**Rückgabe:** `Staff.DriverLicenseControl.DriverLicenseAnalysis_Response()`.

| Parameter | Typ |
| --- | --- |
| `ForDeviceID` | `String` |
| `ForDriverID` | `Integer` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

## Unfälle

Endpunkt: `FleetAccidents.asmx` · WSDL: `FleetAccidents.asmx?WSDL`

### FleetAccidents.CreateAccident

Unfall erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `Integer` |
| `Unfallart` | `String` |
| `Bezeichnung` | `String` |
| `FahrerID` | `Integer` |
| `Unfalldatum` | `Date` |
| `Datum` | `Date` |
| `PersonalID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.UpdateAccident

Unfall ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `KFZNr` | `Integer` |
| `Unfallart` | `String` |
| `Bezeichnung` | `String` |
| `FahrerID` | `Integer` |
| `Beschreibung` | `String` |
| `Unfalldatum` | `Date` |
| `Unfallort` | `String` |
| `Land` | `String` |
| `Datum` | `Date` |
| `PersonalID` | `Integer` |
| `Eigenschaden` | `String` |
| `Geschädigter` | `String` |
| `Adresse` | `String` |
| `Ort` | `String` |
| `Postleitzahl` | `String` |
| `Fahrzeug` | `String` |
| `Kennzeichen` | `String` |
| `VersicherungsName` | `String` |
| `VersicherungsNr` | `String` |
| `Telefonnummer` | `String` |
| `Fremdschaden` | `String` |
| `Bemerkung` | `String` |
| `Erledigt` | `Boolean` |
| `Polizeibericht` | `Boolean` |
| `Polizeiberichttext` | `String` |
| `Stillstand` | `Boolean` |
| `Stillstandtext` | `String` |
| `SummeEigenschaden` | `Double` |
| `SummeFremdschaden` | `Double` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.DeleteAccident

Unfall löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.ListUserFields

Liste der benutzerdefinierten Freifelder.

**Rückgabe:** `General.Parameter.UserFields_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.UpdateUserFields

Ändern der benutzerdefinierten Freifelder.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `UnfallID` | `Integer` |
| `Freifeld0` | `String` |
| `Freifeld1` | `String` |
| `Freifeld2` | `String` |
| `Freifeld3` | `String` |
| `Freifeld4` | `String` |
| `Freifeld5` | `String` |
| `Freifeld6` | `String` |
| `Freifeld7` | `String` |
| `Freifeld8` | `String` |
| `Freifeld9` | `String` |
| `Freifeld10` | `String` |
| `Freifeld11` | `String` |
| `Freifeld12` | `String` |
| `Freifeld13` | `String` |
| `Freifeld14` | `String` |
| `Freifeld15` | `String` |
| `Freifeld16` | `String` |
| `Freifeld17` | `String` |
| `Freifeld18` | `String` |
| `Freifeld19` | `String` |
| `Freifeld20` | `Date` |
| `Freifeld21` | `Date` |
| `Freifeld22` | `Date` |
| `Freifeld23` | `Date` |
| `Freifeld24` | `Date` |
| `Freifeld25` | `Boolean` |
| `Freifeld26` | `Boolean` |
| `Freifeld27` | `Boolean` |
| `Freifeld28` | `Boolean` |
| `Freifeld29` | `Boolean` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.GetAccidentsList

Liste aller Unfälle.

**Rückgabe:** `FleetERP.Accidents.Accident_Response()`.

| Parameter | Typ |
| --- | --- |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.GetAccidentsListOpen

Liste offene Unfälle.

**Rückgabe:** `FleetERP.Accidents.Accident_Response()`.

| Parameter | Typ |
| --- | --- |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.GetAccidentsListClosed

Liste erledigte Unfälle.

**Rückgabe:** `FleetERP.Accidents.Accident_Response()`.

| Parameter | Typ |
| --- | --- |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.GetAccidentsListVehicle

Liste Unfälle eines Fahrzeuges.

**Rückgabe:** `FleetERP.Accidents.Accident_Response()`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `Integer` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.GetAccidentDetails

Details Unfall.

**Rückgabe:** `FleetERP.Accidents.AccidentDetail_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.CreateAccidentDocument

Bild/Dokument zu Unfall erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `UnfallID` | `Integer` |
| `Bezeichnung` | `String` |
| `Dateiname` | `String` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `Base64Stream` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.UpdateAccidentDocument

Bild/Dokument zu Unfall ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `Bezeichnung` | `String` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.DeleteAccidentDocument

Bild/Dokument zu Unfall löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### FleetAccidents.GetAccidentDocuments

Bilder/Dokumente Mangel abrufen.

**Rückgabe:** `General.Files.Base64File_Response()`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `UnfallID` | `Integer` |
| `NoBase64Stream` | `Boolean` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

## Anmeldung und Geräteaktivierung

Endpunkt: `GeneralRegistration.asmx` · WSDL: `GeneralRegistration.asmx?WSDL`

### GeneralRegistration.ListUserLogins

Liste Benutzer mit Anmeldung.

**Rückgabe:** `General.Registration.UserLogins_Response()`.

| Parameter | Typ |
| --- | --- |
| Keine | – |

### GeneralRegistration.ValidateMobileDeviceLogin

Anmeldung von mobilem Gerät.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### GeneralRegistration.ActivateMobileDevice

Mobiles Gerät aktivieren.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `Aktivierungscode` | `String` |
| `GeräteID` | `String` |
| `Kurzbezeichnung` | `String` |
| `User` | `String` |
| `Password` | `String` |

### GeneralRegistration.GetParameter

Parameter abfragen.

**Rückgabe:** `General.Parameter.Parameter_Response`.

| Parameter | Typ |
| --- | --- |
| `Nummer` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

## Personalstammdaten

Endpunkt: `StaffMasterData.asmx` · WSDL: `StaffMasterData.asmx?WSDL`

### StaffMasterData.GetStaffMasterData

Personalstammdaten einer Person.

**Rückgabe:** `Staff.MasterData.MasterData_Response`.

| Parameter | Typ |
| --- | --- |
| `PersonalID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### StaffMasterData.GetStaffList

Personalstammdaten aller Personen.

**Rückgabe:** `Staff.MasterData.MasterData_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### StaffMasterData.GetStaffListActive

Personalstammdaten aller aktiven Personen.

**Rückgabe:** `Staff.MasterData.MasterData_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### StaffMasterData.GetStaffListDrivers

Personalstammdaten aller Fahrer.

**Rückgabe:** `Staff.MasterData.MasterData_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### StaffMasterData.GetStaffListDriversActive

Personalstammdaten aller aktiven Fahrer.

**Rückgabe:** `Staff.MasterData.MasterData_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### StaffMasterData.GetStaffListUsers

Personalstammdaten aller Benutzer.

**Rückgabe:** `Staff.MasterData.MasterData_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### StaffMasterData.GetStaffListUsersActive

Personalstammdaten aller aktiven Benutzer.

**Rückgabe:** `Staff.MasterData.MasterData_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### StaffMasterData.CurrentAssignedVehicles

Aktuell zugeordnete Fahrzeuge einer Person.

**Rückgabe:** `Staff.MasterData.AssignedVehicles_Response()`.

| Parameter | Typ |
| --- | --- |
| `PersonalID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

## Lieferantenstammdaten

Endpunkt: `SupplierMasterData.asmx` · WSDL: `SupplierMasterData.asmx?WSDL`

### SupplierMasterData.GetSupplierMasterData

Lieferantenstammdaten eines Lieferanten.

**Rückgabe:** `Supplier.MasterData.MasterData_Response`.

| Parameter | Typ |
| --- | --- |
| `LieferantenNr` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### SupplierMasterData.GetSupplierList

Lieferantenstammdaten aller Lieferanten.

**Rückgabe:** `Supplier.MasterData.MasterData_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

## Fahrzeugstammdaten

Endpunkt: `VehicleMasterData.asmx` · WSDL: `VehicleMasterData.asmx?WSDL`

### VehicleMasterData.GetVehicleMasterData

Fahrzeugstammdaten eines Fahrzeuges.

**Rückgabe:** `Vehicle.MasterData.MasterData_Response`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### VehicleMasterData.GetVehicleList

Fahrzeugstammdaten aller Fahrzeuges.

**Rückgabe:** `Vehicle.MasterData.MasterData_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

## Mängel

Endpunkt: `WorkshopFaults.asmx` · WSDL: `WorkshopFaults.asmx?WSDL`

### WorkshopFaults.CreateFault

Mangel erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `Integer` |
| `MNr` | `String` |
| `MBez` | `String` |
| `Kilometerstand` | `Integer` |
| `LauflEinheit` | `Integer` |
| `Datum` | `Date` |
| `Zeitvorgabe` | `Integer` |
| `Erledigt` | `Boolean` |
| `ErledigtDatum` | `Date` |
| `PersonalID` | `Integer` |
| `FahrerID` | `Integer` |
| `Priorität` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.UpdateFault

Mangel ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `KFZNr` | `Integer` |
| `MNr` | `String` |
| `MBez` | `String` |
| `Kilometerstand` | `Integer` |
| `LauflEinheit` | `Integer` |
| `Datum` | `Date` |
| `Zeitvorgabe` | `Integer` |
| `Erledigt` | `Boolean` |
| `ErledigtDatum` | `Date` |
| `PersonalID` | `Integer` |
| `FahrerID` | `Integer` |
| `Priorität` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.DeleteFault

Mangel löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.ListUserFields

Liste der benutzerdefinierten Freifelder.

**Rückgabe:** `General.Parameter.UserFields_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.UpdateUserFields

Ändern der benutzerdefinierten Freifelder.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `MAID` | `Integer` |
| `Freifeld0` | `String` |
| `Freifeld1` | `String` |
| `Freifeld2` | `String` |
| `Freifeld3` | `String` |
| `Freifeld4` | `String` |
| `Freifeld5` | `String` |
| `Freifeld6` | `String` |
| `Freifeld7` | `String` |
| `Freifeld8` | `String` |
| `Freifeld9` | `String` |
| `Freifeld10` | `String` |
| `Freifeld11` | `String` |
| `Freifeld12` | `String` |
| `Freifeld13` | `String` |
| `Freifeld14` | `String` |
| `Freifeld15` | `String` |
| `Freifeld16` | `String` |
| `Freifeld17` | `String` |
| `Freifeld18` | `String` |
| `Freifeld19` | `String` |
| `Freifeld20` | `Date` |
| `Freifeld21` | `Date` |
| `Freifeld22` | `Date` |
| `Freifeld23` | `Date` |
| `Freifeld24` | `Date` |
| `Freifeld25` | `Boolean` |
| `Freifeld26` | `Boolean` |
| `Freifeld27` | `Boolean` |
| `Freifeld28` | `Boolean` |
| `Freifeld29` | `Boolean` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.GetFaultsList

Liste alle Mängel.

**Rückgabe:** `WorkshopERP.Faults.Fault_Response()`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `String` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.GetFaultsListOpen

Liste offene Mängel.

**Rückgabe:** `WorkshopERP.Faults.Fault_Response()`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `String` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.GetFaultsListClosed

Liste erledigte Mängel.

**Rückgabe:** `WorkshopERP.Faults.Fault_Response()`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `String` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.GetFaultDetails

Details Mangel.

**Rückgabe:** `WorkshopERP.Faults.Fault_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.GetFaultDetailsByDC

Details Mangel anhand Abfahrtskontrolle.

**Rückgabe:** `WorkshopERP.Faults.Fault_Response`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `Integer` |
| `AbfahrtskontrolleAufgabeID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.CreateFaultDocument

Bild/Dokument zu Mangel erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `MAID` | `Integer` |
| `Bezeichnung` | `String` |
| `Dateiname` | `String` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `Base64Stream` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.UpdateFaultDocument

Bild/Dokument zu Mangel ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `Bezeichnung` | `String` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.DeleteFaultDocument

Bild/Dokument zu Mangel löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopFaults.GetFaultDocuments

Bilder/Dokumente Mangel abrufen.

**Rückgabe:** `General.Files.Base64File_Response()`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `MAID` | `Integer` |
| `NoBase64Stream` | `Boolean` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

## Artikel, Lager und Etikettendruck

Endpunkt: `WorkshopItems.asmx` · WSDL: `WorkshopItems.asmx?WSDL`

### WorkshopItems.GetItemMasterData

Artikelstammdaten eines Artikel.

**Rückgabe:** `WorkshopERP.Items.MasterData_Response`.

| Parameter | Typ |
| --- | --- |
| `ArtikelID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.GetItemMasterDataID

Artikelstammdaten eines Artikel.

**Rückgabe:** `WorkshopERP.Items.MasterData_Response`.

| Parameter | Typ |
| --- | --- |
| `ArtikelID` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.GetItemMasterDataMatchcode

Artikelstammdaten mehrerer Artikel.

**Rückgabe:** `WorkshopERP.Items.MasterData_Response()`.

| Parameter | Typ |
| --- | --- |
| `Matchcode` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.GetStockData

Lagerstellen.

**Rückgabe:** `WorkshopERP.Items.StockData_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.GetItemStockPositions

Lagerstellen eines Artikel.

**Rückgabe:** `WorkshopERP.Warehouse.ItemPosition_Response()`.

| Parameter | Typ |
| --- | --- |
| `ArtikelID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.GetItemInventoryList

Inventurliste.

**Rückgabe:** `WorkshopERP.Warehouse.ItemInventory_Response()`.

| Parameter | Typ |
| --- | --- |
| `ArtikelID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.GetStockInventoryList

Lagerbestandsliste.

**Rückgabe:** `WorkshopERP.Warehouse.StockInventory_Response()`.

| Parameter | Typ |
| --- | --- |
| `ArtikelID` | `String` |
| `Lagerstelle` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.CreateInventoryPosition

Inventurposition erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `ArtikelID` | `Integer` |
| `Lagerstelle` | `String` |
| `IstBestand` | `Double` |
| `Datum` | `Date` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.UpdateInventoryPosition

Inventurposition ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ArtikelID` | `Integer` |
| `Lagerstelle` | `String` |
| `IstBestand` | `Double` |
| `Datum` | `Date` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.DeleteInventoryPosition

Inventurposition löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ArtikelID` | `Integer` |
| `Lagerstelle` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.CreateReceiptPosition

Lagerzugang Wareneingang erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `ArtikelID` | `Integer` |
| `LieferantenNr` | `Integer` |
| `Menge` | `Double` |
| `EPreis` | `Double` |
| `Lagerstelle` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.DeleteReceiptPosition

Lagerzugang Wareneingang löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.GetLabelPrinters

Etikettendrucker für Lagerzugang abrufen.

**Rückgabe:** `WorkshopERP.Warehouse.LabelPrinter_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopItems.PrintReceiptLabel

Lagerzugang-Etikett drucken.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |
| `ReceiptPositionID` | `Integer` |
| `PrinterID` | `Integer` |
| `Copies` | `Integer` |

## Werkstattaufträge

Endpunkt: `WorkshopOrders.asmx` · WSDL: `WorkshopOrders.asmx?WSDL`

### WorkshopOrders.CreateOrder

Auftrag erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `Integer` |
| `KundenNr` | `Integer` |
| `WANr` | `String` |
| `WABez` | `String` |
| `Kilometerstand` | `Integer` |
| `LauflEinheit` | `Integer` |
| `freiesKennzeichen` | `String` |
| `freieZulassung` | `String` |
| `freieFahrgestellNr` | `String` |
| `Datum` | `Date` |
| `Zeitvorgabe` | `Integer` |
| `Erledigt` | `Boolean` |
| `Fremdauftrag` | `Boolean` |
| `PersonalID` | `Integer` |
| `TerminVon` | `Date` |
| `TerminBis` | `Date` |
| `Gebucht` | `Boolean` |
| `Standort` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.UpdateOrder

Auftrag ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `KFZNr` | `Integer` |
| `KundenNr` | `Integer` |
| `WANr` | `String` |
| `WABez` | `String` |
| `Kilometerstand` | `Integer` |
| `LauflEinheit` | `Integer` |
| `freiesKennzeichen` | `String` |
| `freieZulassung` | `String` |
| `freieFahrgestellNr` | `String` |
| `Datum` | `Date` |
| `Zeitvorgabe` | `Integer` |
| `Erledigt` | `Boolean` |
| `Fremdauftrag` | `Boolean` |
| `PersonalID` | `Integer` |
| `TerminVon` | `Date` |
| `TerminBis` | `Date` |
| `Gebucht` | `Boolean` |
| `Standort` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.DeleteOrder

Werkstattauftrag löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.GetOrdersList

Liste alle Aufträge.

**Rückgabe:** `WorkshopERP.Orders.Order_Response()`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `String` |
| `KundenNr` | `String` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.GetOrdersListOpen

Liste offene Aufträge.

**Rückgabe:** `WorkshopERP.Orders.Order_Response()`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `String` |
| `KundenNr` | `String` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.GetOrdersListClosed

Liste erledigte Aufträge.

**Rückgabe:** `WorkshopERP.Orders.Order_Response()`.

| Parameter | Typ |
| --- | --- |
| `KFZNr` | `String` |
| `KundenNr` | `String` |
| `SortByField` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.GetOrderDetails

Details Auftrag.

**Rückgabe:** `WorkshopERP.Orders.Order_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.ListUserFields

Liste der benutzerdefinierten Freifelder.

**Rückgabe:** `General.Parameter.UserFields_Response()`.

| Parameter | Typ |
| --- | --- |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.UpdateUserFields

Ändern der benutzerdefinierten Freifelder.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `WAID` | `Integer` |
| `Freifeld0` | `String` |
| `Freifeld1` | `String` |
| `Freifeld2` | `String` |
| `Freifeld3` | `String` |
| `Freifeld4` | `String` |
| `Freifeld5` | `String` |
| `Freifeld6` | `String` |
| `Freifeld7` | `String` |
| `Freifeld8` | `String` |
| `Freifeld9` | `String` |
| `Freifeld10` | `String` |
| `Freifeld11` | `String` |
| `Freifeld12` | `String` |
| `Freifeld13` | `String` |
| `Freifeld14` | `String` |
| `Freifeld15` | `String` |
| `Freifeld16` | `String` |
| `Freifeld17` | `String` |
| `Freifeld18` | `String` |
| `Freifeld19` | `String` |
| `Freifeld20` | `Date` |
| `Freifeld21` | `Date` |
| `Freifeld22` | `Date` |
| `Freifeld23` | `Date` |
| `Freifeld24` | `Date` |
| `Freifeld25` | `Boolean` |
| `Freifeld26` | `Boolean` |
| `Freifeld27` | `Boolean` |
| `Freifeld28` | `Boolean` |
| `Freifeld29` | `Boolean` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.CreateOrderDocument

Bild/Dokument zu Auftrag erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `WAID` | `Integer` |
| `Bezeichnung` | `String` |
| `Dateiname` | `String` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `Base64Stream` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.UpdateOrderDocument

Bild/Dokument zu Auftrag ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `Bezeichnung` | `String` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.DeleteOrderDocument

Bild/Dokument zu Auftrag löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.GetOrderDocuments

Bilder/Dokumente zu Auftrag abrufen.

**Rückgabe:** `General.Files.Base64File_Response()`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `WAID` | `Integer` |
| `NoBase64Stream` | `Boolean` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.CreateOrderItemPosition

Artikelposition zu Auftrag erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `WAID` | `Integer` |
| `ArtikelID` | `Integer` |
| `Menge` | `Double` |
| `EPreis` | `Double` |
| `Lagerstelle` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.UpdateOrderItemPosition

Artikelposition zu Auftrag ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `ArtikelID` | `Integer` |
| `Menge` | `Double` |
| `EPreis` | `Double` |
| `Lagerstelle` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.DeleteOrderItemPosition

Artikelposition zu Auftrag löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.GetOrderItemPositions

Artikelpositionen zu Auftrag abrufen.

**Rückgabe:** `WorkshopERP.Orders.OrderItemPosition_Response()`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `WAID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.CreateOrderWorkPosition

Lohnposition zu Auftrag erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `WAID` | `Integer` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `Menge` | `Double` |
| `EPreis` | `Double` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.UpdateOrderWorkPosition

Lohnposition zu Auftrag ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `PersonalID` | `Integer` |
| `Datum` | `Date` |
| `Menge` | `Double` |
| `EPreis` | `Double` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.DeleteOrderWorkPosition

Lohnposition zu Auftrag löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopOrders.GetOrderWorkPositions

Lohnpositionen zu Auftrag abrufen.

**Rückgabe:** `WorkshopERP.Orders.OrderWorkPosition_Response()`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `WAID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

## Werkstattzeiterfassung

Endpunkt: `WorkshopTimeTracking.asmx` · WSDL: `WorkshopTimeTracking.asmx?WSDL`

### WorkshopTimeTracking.CreateBookingPosition

Zeiterfassungsposition zu Auftrag erstellen.

**Rückgabe:** `General.Database.Insert_Response`.

| Parameter | Typ |
| --- | --- |
| `WAID` | `Integer` |
| `PersonalID` | `Integer` |
| `Beginn` | `Date` |
| `Ende` | `Date` |
| `GeräteID` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopTimeTracking.UpdateBookingPosition

Zeiterfassungsposition zu Auftrag ändern.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `PersonalID` | `Integer` |
| `Beginn` | `Date` |
| `Ende` | `Date` |
| `GeräteID` | `String` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopTimeTracking.DeleteBookingPosition

Zeiterfassungsposition zu Auftrag löschen.

**Rückgabe:** `General.General_Response`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |

### WorkshopTimeTracking.GetBookingPositions

Zeiterfassungspositionen zu Auftrag abrufen.

**Rückgabe:** `WorkshopERP.TimeTracking.BookingPosition_Response()`.

| Parameter | Typ |
| --- | --- |
| `ID` | `Integer` |
| `WAID` | `Integer` |
| `User` | `String` |
| `Password` | `String` |
| `DeviceID` | `String` |
