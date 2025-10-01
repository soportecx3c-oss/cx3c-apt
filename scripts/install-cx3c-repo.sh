#!/usr/bin/env bash
set -euo pipefail

ARCH="$(dpkg --print-architecture)"
KEYRING="/etc/apt/keyrings/cx3c.gpg"
LIST="/etc/apt/sources.list.d/cx3c-tools.list"
BASE="https://soportecx3c-oss.github.io/cx3c-apt"

# Pre-req
sudo mkdir -p /etc/apt/keyrings
sudo apt-get update -y
sudo apt-get install -y curl ca-certificates gnupg

# Import key (desde Pages)
curl -fsSL "$BASE/keyring/cx3c.asc" | sudo gpg --dearmor -o "$KEYRING"
sudo chmod 0644 "$KEYRING"

# Repo entry (stable/main)
echo "deb [arch=${ARCH} signed-by=${KEYRING}] ${BASE} stable main" | sudo tee "$LIST" >/dev/null

# Update
sudo apt-get update -y

# Mostrar políticas de paquetes del repo (visibilidad)
apt-cache policy cx3c-tools cx3c-pve-tools || true

echo "Repo CX3C listo. Instala con: sudo apt-get install -y cx3c-tools  (o cx3c-pve-tools)"
