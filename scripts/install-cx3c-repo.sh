#!/usr/bin/env bash
# install-cx3c-repo.sh — Añade el repo APT de CX3C y/o instala cx3c-tools
# Uso:
#   curl -fsSL https://soportecx3c-oss.github.io/cx3c-apt/scripts/install-cx3c-repo.sh | bash
set -euo pipefail

REPO_URL="https://soportecx3c-oss.github.io/cx3c-apt"
KEYRING="/etc/apt/keyrings/cx3c.gpg"
LISTFILE="/etc/apt/sources.list.d/cx3c-tools.list"

need_sudo() { [ "$(id -u)" -ne 0 ] && echo sudo || true; }
SUDO="$(need_sudo)"

echo "[+] Preparando keyring..."
$SUDO install -d -m 0755 /etc/apt/keyrings
curl -fsSL "$REPO_URL/keys/cx3c.asc" | gpg --dearmor | $SUDO tee "$KEYRING" >/dev/null
$SUDO chmod 0644 "$KEYRING"

echo "[+] Configurando repo APT..."
echo "deb [arch=amd64 signed-by=$KEYRING] $REPO_URL stable main" | $SUDO tee "$LISTFILE" >/dev/null

# Si el host NO tiene default route IPv6, forzar IPv4 solo para APT
if ! ip -6 route show default >/dev/null 2>&1 || [ -z "$(ip -6 route show default || true)" ]; then
  echo "[i] IPv6 no detectado: forzando IPv4 en APT"
  $SUDO tee /etc/apt/apt.conf.d/99force-ipv4 >/dev/null <<'CFG'
Acquire::ForceIPv4 "true";
CFG
fi

echo "[+] Actualizando índices..."
$SUDO apt update -y

echo "[+] Instalando cx3c-tools..."
$SUDO apt install -y cx3c-tools

echo "[✓] Listo. Comandos disponibles:"
echo "    - full-upgrade-cx3c"
