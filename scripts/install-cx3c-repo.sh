#!/usr/bin/env bash
set -euo pipefail

REPO_BASE="https://soportecx3c-oss.github.io/cx3c-apt"
KEY_URL_GPG="$REPO_BASE/KEY.gpg"
KEYRING_DIR="/etc/apt/keyrings"
KEYRING="$KEYRING_DIR/cx3c.gpg"
LIST="/etc/apt/sources.list.d/cx3c-tools.list"

echo "[CX3C] Forzando IPv4 para apt (si aplica)"
mkdir -p /etc/apt/apt.conf.d
printf 'Acquire::ForceIPv4 "true";\n' >/etc/apt/apt.conf.d/99force-ipv4 || true

echo "[CX3C] Creando directorio de keyrings: $KEYRING_DIR"
install -d -m 0755 "$KEYRING_DIR"

echo "[CX3C] Descargando llave GPG del repositorio"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$KEY_URL_GPG" -o "$KEYRING"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$KEYRING" "$KEY_URL_GPG"
else
  echo "[ERROR] Necesitas curl o wget" >&2
  exit 1
fi

# Si accidentalmente llega ASCII-armored, convertir a binario .gpg
if file "$KEYRING" | grep -qi "PGP.*public.*key.*block"; then
  echo "[CX3C] Detectada llave ASCII (armored), convirtiendo a formato binario .gpg"
  tmpasc="$(mktemp)"
  mv "$KEYRING" "$tmpasc"
  gpg --dearmor -o "$KEYRING" "$tmpasc"
  rm -f "$tmpasc"
fi
chmod 0644 "$KEYRING"

echo "[CX3C] Escribiendo lista APT: $LIST"
cat > "$LIST" <<LISTEOF
deb [arch=amd64 signed-by=$KEYRING] $REPO_BASE stable main
LISTEOF

echo "[CX3C] Ejecutando apt update"
apt-get update -y

echo "[CX3C] Listo. Instalación de ejemplo:"
echo "       sudo apt install -y cx3c-pve-tools"
