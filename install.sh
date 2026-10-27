#!/usr/bin/env bash
# Public downloader for the source-private, data-free Price Studio customer bundle.
# Version and SHA-256 are pinned; no secrets or customer data are downloaded.
set -Eeuo pipefail
umask 077
fail(){ printf 'Price Studio: BLOCK: %s\n' "$*" >&2; exit 1; }
[[ $EUID -eq 0 ]] || fail 'Bitte mit sudo ausführen.'
[[ -r /etc/os-release ]] || fail 'Ubuntu 24.04 amd64 erforderlich.'
. /etc/os-release
[[ "$ID" = ubuntu && "$VERSION_ID" = 24.04 && "$(uname -m)" = x86_64 ]] || fail 'Dieses Paket ist für Ubuntu 24.04 amd64 gebaut.'
DEST=/opt/price-studio/release
if [[ -d "$DEST" ]]; then
  [[ -f "$DEST/setup.sh" && -f "$DEST/package-files.sha256" ]] || fail 'Unvollständige Vorinstallation gefunden. Nicht überschreiben.'
  exec bash "$DEST/setup.sh" "$@"
fi
for tool in tar sha256sum openssl; do
  command -v "$tool" >/dev/null || fail "Fehlendes Basisprogramm: $tool"
done
if ! command -v curl >/dev/null; then
  if command -v wget >/dev/null; then DOWNLOADER=wget; else
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl
    DOWNLOADER=curl
  fi
else DOWNLOADER=curl; fi
VERSION=v2026.10.27
ASSET=price-studio-onprem-v2026.10.27.tar.gz
URL=https://github.com/Meilleur-Tech/Price-Studio-Releases/releases/download/v2026.10.27/price-studio-onprem-v2026.10.27.tar.gz
SHA256=c2d597c23178636178165b42fc52a2339295519d1b9020c2970be6e0b7b0356b
install -d -m 0700 /opt/price-studio
TMP=$(mktemp -d /opt/price-studio/.download.XXXXXXXX) || fail 'Temporäres Verzeichnis konnte nicht angelegt werden.'
trap 'rm -rf "$TMP"' EXIT
printf 'Price Studio: Lade geprüftes Paket %s herunter.\n' "$VERSION"
if [[ "$DOWNLOADER" = curl ]]; then
  curl --fail --location --retry 3 --connect-timeout 20 --output "$TMP/archive.tar.gz" "$URL" || fail 'Download fehlgeschlagen.'
else
  wget -q --tries=3 --timeout=20 -O "$TMP/archive.tar.gz" "$URL" || fail 'Download fehlgeschlagen.'
fi
printf '%s  %s\n' "$SHA256" "$TMP/archive.tar.gz" | sha256sum -c - || fail 'Download-Prüfsumme stimmt nicht.'
install -d -m 0700 "$TMP/release"
tar --no-same-owner --no-same-permissions -xzf "$TMP/archive.tar.gz" -C "$TMP/release" || fail 'Paket konnte nicht entpackt werden.'
(cd "$TMP/release" && sha256sum -c package-files.sha256 && sha256sum -c images.sha256) || fail 'Paketintegrität verletzt.'
[[ -f "$TMP/release/setup.sh" && -f "$TMP/release/ubuntu-bootstrap.sh" && ! -e "$TMP/release/.env" && ! -e "$TMP/release/secrets" ]] || fail 'Unerwarteter Paketinhalt.'
[[ ! -e "$DEST" ]] || fail 'Installationsverzeichnis wurde inzwischen angelegt.'
mv "$TMP/release" "$DEST" || fail 'Installationsverzeichnis konnte nicht angelegt werden.'
chmod 0700 "$DEST"
printf 'Price Studio: Paketprüfung erfolgreich. Starte CSR-/Installationsassistent.\n'
exec bash "$DEST/setup.sh" "$@"
