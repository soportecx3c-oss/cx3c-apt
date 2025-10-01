# README_MANTENIMIENTO — CX3C APT REPO

Guía interna para mantener el repositorio APT publicado en:
https://soportecx3c-oss.github.io/cx3c-apt

Estructura esperada:
- dists/stable/...
- pool/main/<paquete>/<paquete>_<version>_<arch>.deb
- keyring/cx3c.asc  (llave pública ASCII)
- keyring/cx3c.gpg  (llave pública en formato keyring)

============================================================
0) PRERREQUISITOS (en el servidor de mantenimiento/gtw)
============================================================
sudo apt-get update
sudo apt-get install -y gnupg apt-utils apt-ftparchive gzip

# La llave privada para firmar debe existir:
gpg --list-secret-keys --keyid-format=long
# Anotar KEYID (ejemplo): FB228B7C557103C091F6B254AF60143310F741D2

============================================================
1) AÑADIR UN NUEVO .DEB AL REPO
============================================================
# Copiar el .deb a pool/main/<nombre>/
# Ejemplo:
# cp ./build/cx3c-tools_0.2.0_all.deb pool/main/cx3c-tools/
# Verificar metadatos:
dpkg-deb -f pool/main/*/*.deb Package Version Architecture

============================================================
2) REGENERAR ÍNDICES Packages / Packages.gz
============================================================
# Architecture: all
mkdir -p dists/stable/main/binary-all
apt-ftparchive packages pool > dists/stable/main/binary-all/Packages
gzip -f -k dists/stable/main/binary-all/Packages

# (Opcional) Si hubiera paquetes amd64:
mkdir -p dists/stable/main/binary-amd64
apt-ftparchive packages pool | awk '
  BEGIN{p=0}
  /^Architecture: amd64$/{p=1}
  /^$/{if(p){print buf}; buf=""; p=0; next}
  {buf=buf $0 "\n"}
' > dists/stable/main/binary-amd64/Packages || true
[ -s dists/stable/main/binary-amd64/Packages ] && gzip -f -k dists/stable/main/binary-amd64/Packages || true

ls -lh dists/stable/main/binary-*/Packages*

============================================================
3) (UNA VEZ O SI CAMBIAS METADATOS) apt.conf
============================================================
cat > apt.conf <<'EOC'
APT::FTPArchive::Release::Origin "CX3C";
APT::FTPArchive::Release::Label "CX3C APT";
APT::FTPArchive::Release::Suite "stable";
APT::FTPArchive::Release::Codename "stable";
APT::FTPArchive::Release::Architectures "amd64 all";
APT::FTPArchive::Release::Components "main";
APT::FTPArchive::Release::Description "CX3C APT Repository";
EOC

============================================================
4) REGENERAR Release / InRelease / Release.gpg (FIRMAR)
============================================================
cd dists/stable
apt-ftparchive -c ../../apt.conf release . > Release
KID="FB228B7C557103C091F6B254AF60143310F741D2"
gpg --local-user "$KID" --clearsign -o InRelease Release
gpg --local-user "$KID" --armor --detach-sign -o Release.gpg Release
gpg --verify InRelease
head -n 12 Release
cd ../../

============================================================
5) PUBLICAR A GITHUB (commit & push)
============================================================
git add \
  apt.conf \
  dists/stable/Release dists/stable/InRelease dists/stable/Release.gpg \
  dists/stable/main/binary-all/Packages dists/stable/main/binary-all/Packages.gz \
  dists/stable/main/binary-amd64/Packages dists/stable/main/binary-amd64/Packages.gz
git commit -m "Publish APT: update Packages and re-sign Release/InRelease"
git push origin HEAD

============================================================
6) VALIDAR PUBLICACIÓN (desde Internet)
============================================================
BASE="https://soportecx3c-oss.github.io/cx3c-apt"
curl -I $BASE/keyring/cx3c.asc
curl -I $BASE/dists/stable/Release
curl -I $BASE/dists/stable/InRelease
curl -I $BASE/dists/stable/main/binary-all/Packages.gz
curl -I $BASE/dists/stable/main/binary-amd64/Packages.gz

# Vista previa (opcional)
curl -s $BASE/dists/stable/main/binary-all/Packages.gz | gzip -d | head

============================================================
7) VALIDAR EN UN CLIENTE (Ubuntu/Debian/Proxmox)
============================================================
# Si es la primera vez:
# curl -fsSL https://soportecx3c-oss.github.io/cx3c-apt/scripts/install-cx3c-repo.sh | bash

sudo apt-get update
# Si APT informa cambio de Origin/Label/Suite/Codename:
sudo apt-get update --allow-releaseinfo-change
apt-cache policy cx3c-tools cx3c-pve-tools
# Prueba de instalación:
# sudo apt-get install -y cx3c-tools
# sudo apt-get install -y cx3c-pve-tools

============================================================
8) TROUBLESHOOTING RÁPIDO
============================================================
- NO_PUBKEY:
  * Re-firma Release/InRelease con la llave publicada en keyring.
  * En el cliente reinstala el keyring:
    sudo curl -fsSL $BASE/keyring/cx3c.asc | sudo gpg --dearmor -o /etc/apt/keyrings/cx3c.gpg
    sudo apt-get update

- Conflicting distribution (Origin/Label/Codename/Suite):
  sudo apt-get update --allow-releaseinfo-change

- 404 en Packages.gz:
  * Repite el Paso 2 y publica (Paso 5).

- Firmas válidas pero APT no actualiza:
  sudo rm -rf /var/lib/apt/lists/*
  sudo apt-get update

============================================================
9) ROTACIÓN/RENOVACIÓN DE LLAVE GPG
============================================================
# Genera una nueva llave con antelación, publica su .asc/.gpg en keyring/,
# re-firma Release con la nueva, y comunica a clientes ejecutar:
sudo apt-get update --allow-releaseinfo-change

============================================================
10) SCRIPT OPCIONAL DE PUBLICACIÓN (plantilla)
============================================================
# scripts/publish-apt.sh (ajusta KID)
# ---------------------------------------------------------
#!/usr/bin/env bash
set -euo pipefail
KID="FB228B7C557103C091F6B254AF60143310F741D2"
BASE_DIR="$(cd "$(dirname "$0")/.."; pwd)"
cd "$BASE_DIR"
mkdir -p dists/stable/main/binary-all dists/stable/main/binary-amd64
apt-ftparchive packages pool > dists/stable/main/binary-all/Packages
gzip -f -k dists/stable/main/binary-all/Packages
apt-ftparchive -c apt.conf release dists/stable > dists/stable/Release
gpg --local-user "$KID" --clearsign -o dists/stable/InRelease dists/stable/Release
gpg --local-user "$KID" --armor --detach-sign -o dists/stable/Release.gpg dists/stable/Release
git add apt.conf dists/stable/Release dists/stable/InRelease dists/stable/Release.gpg \
        dists/stable/main/binary-all/Packages dists/stable/main/binary-all/Packages.gz \
        dists/stable/main/binary-amd64/Packages dists/stable/main/binary-amd64/Packages.gz || true
git commit -m "Publish APT (auto)" || true
git push origin HEAD
echo "Publicación completada."
# ---------------------------------------------------------
