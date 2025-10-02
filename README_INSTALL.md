# Repositorio APT CX3C

Este repositorio contiene paquetes CX3C para Ubuntu, Debian y Proxmox.

---

## Instalación

Ejecuta el siguiente comando:

curl -fsSL https://soportecx3c-oss.github.io/cx3c-apt/scripts/install-cx3c-repo.sh | bash

El script:
- Descarga e instala la llave GPG desde keyring/cx3c.asc
- Configura /etc/apt/sources.list.d/cx3c-tools.list
- Ejecuta apt-get update

---

## Validación

Verifica que el repositorio quedó habilitado:

sudo gpg --no-default-keyring --keyring /etc/apt/keyrings/cx3c.gpg --list-keys
cat /etc/apt/sources.list.d/cx3c-tools.list
sudo apt-get update
apt-cache policy cx3c-tools cx3c-pve-tools

Debes ver que los paquetes provienen de https://soportecx3c-oss.github.io/cx3c-apt

---

## Instalación de paquetes

Ejemplo:

sudo apt-get install -y cx3c-pve-tools

---

## Reparaciones recurrentes

### 1. Error de NO_PUBKEY
sudo curl -fsSL https://soportecx3c-oss.github.io/cx3c-apt/keyring/cx3c.asc | sudo gpg --dearmor -o /etc/apt/keyrings/cx3c.gpg |
sudo apt-get update

### 2. Cambios en Origin/Label/Codename
sudo apt-get update --allow-releaseinfo-change

### 3. Forzar limpieza de índices
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update

---

## Checklist de Verificación Rápida

1. gpg --no-default-keyring --keyring /etc/apt/keyrings/cx3c.gpg --list-keys
2. cat /etc/apt/sources.list.d/cx3c-tools.list
3. sudo apt-get update
4. apt-cache policy cx3c-tools cx3c-pve-tools
5. sudo apt-get install -y cx3c-pve-tools
