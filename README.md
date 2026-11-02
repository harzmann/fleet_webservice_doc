# FLEET Webservice Kundenportal

Öffentliche Kundendokumentation mit MkDocs Material und GitHub Pages:
https://harzmann.github.io/fleet_webservice_doc/

Inhalte, Funktionsreferenz, ChangeLog und IIS-Skripte werden aus dem Webservice-Quellprojekt generiert.
Änderungen dort in `customer-docs/` bzw. `scripts/` vornehmen und über
`Publish-EHFleetWebserviceDocs.ps1 -DocsRepoPath <lokaler Clone>` synchronisieren.

Lokal prüfen:

```powershell
python -m pip install -r requirements.txt
python -m mkdocs build --strict
```

Push auf `main` veröffentlicht die Seite über GitHub Actions.
