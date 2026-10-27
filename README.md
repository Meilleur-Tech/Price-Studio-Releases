# Meilleur Price Studio · Kundeninstallation

Dieses **öffentliche Release-Repository enthält ausschließlich kundenseitig installierbare Softwarepakete**, nicht den privaten Entwicklungs-Quellcode, keine produktiven Datenbanken, keine Artikelbilder und keine Geheimnisse. Software und Container sind proprietär und ausschließlich gemäß gesondert vereinbarten Nutzungsrechten zu verwenden.

## Ubuntu 24.04 LTS amd64

Auf einer neuen Ubuntu-VM mit administrativem SSH-Zugang:

```bash
curl -fsSLo /tmp/price-studio-install.sh https://raw.githubusercontent.com/Meilleur-Tech/Price-Studio-Releases/v2026.10.27/install.sh && sudo bash /tmp/price-studio-install.sh
```

Der Downloader lädt das versionierte, SHA256-gepinnte Paket, prüft auch dessen internes Dateimanifest und startet `/opt/price-studio/release/setup.sh`.

**Phase 1:** Interaktive Eingabe von FQDN und bestehender Admin-Mailadresse; automatischer CSR unter `/etc/price-studio/tls/server.csr`, privater Schlüssel bleibt auf dem Zielsystem unter `/etc/price-studio/tls/server.key`. Nur CSR an die Zertifizierungsstelle übermitteln.

**Phase 2:** Nach Rückgabe der signierten vollständigen Zertifikatskette `fullchain.pem` diese sicher nach `/opt/price-studio/release/fullchain.pem` übertragen. PROD-Snapshot separat unter `/root/lexit-transfer/prod-snapshot/` bereitstellen (Dateien: `prod-db.dump`, `uploads.tar.gz`, `SHA256SUMS`). Danach denselben Befehl `sudo bash /opt/price-studio/release/setup.sh` ausführen. Die Quelle-PROD wird nicht verändert.

**Wichtig:** Es wird kein öffentliches Kundendaten-Backup zum Download angeboten. Für die anschließende Kundenfreigabe sind echtes PKI-/DNS-Vertrauen, Login, PDF/Preislisten, Offsite-Backup und Restore-Abnahme erforderlich. Adminpasswörter der übernommenen PROD-Accounts bleiben erhalten.

Keine Docker-Compose-Installation auf Unraid erforderlich. Docker wird ausschließlich auf der Ubuntu-Ziel-VM installiert.