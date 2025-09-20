# CX3C APT Repository (stable)

Guía oficial para **instalar** el repositorio `cx3c-apt` en cualquier máquina Ubuntu/Debian y **resolver avisos/errores** comunes relacionados únicamente con la instalación del repo.

---

## Instalación rápida (una línea)
```bash
curl -fsSL https://soportecx3c-oss.github.io/cx3c-apt/scripts/install-cx3c-repo.sh | bash
```

## Instalación manual
> Úsala si prefieres hacerlo paso a paso o para automatizaciones sin Internet interactivo.

### 1) Keyring
```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://soportecx3c-oss.github.io/cx3c-apt/dists/stable/cx3c.asc \
 | sudo gpg --dearmor -o /etc/apt/keyrings/cx3c.gpg
sudo chmod 0644 /etc/apt/keyrings/cx3c.gpg
```

### 2) Entrada APT
```bash
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/cx3c.gpg] https://soportecx3c-oss.github.io/cx3c-apt stable main' \
 | sudo tee /etc/apt/sources.list.d/cx3c.list
```

### 3) Actualizar índices
```bash
sudo apt update
```

---

## Verificación e instalación de paquetes CX3C
```bash
apt-cache policy cx3c-tools
sudo apt install -y cx3c-tools

# comandos incluidos actualmente:
#   - full-upgrade-cx3c
#   - vm-trim-cx3c
```

---

## Solución de problemas (solo instalación del repo)

### A) Aviso: “configured multiple times”
Hay entradas duplicadas del repo. Deja **solo** `/etc/apt/sources.list.d/cx3c.list`.
```bash
sudo rm -f /etc/apt/sources.list.d/cx3c-tools.list
grep -Hn "cx3c" /etc/apt/sources.list /etc/apt/sources.list.d/*.list || true
sudo rm -f /var/lib/apt/lists/*soportecx3c-oss* /var/lib/apt/lists/partial/*soportecx3c-oss* 2>/dev/null || true
sudo apt update
```

### B) Aviso: “Conflicting distribution: … expected stable but got”
Metadatos antiguos en el cliente. Limpia listas y actualiza:
```bash
sudo rm -f /var/lib/apt/lists/*soportecx3c-oss* /var/lib/apt/lists/partial/*soportecx3c-oss* 2>/dev/null || true
sudo apt update
```

### C) Error: **Hash Sum mismatch**
El cliente mezcló caché mientras se publicaba. Fuerza actualización sin caché:
```bash
sudo rm -f /var/lib/apt/lists/*soportecx3c-oss* /var/lib/apt/lists/partial/*soportecx3c-oss* 2>/dev/null || true
sudo apt -o Acquire::https::No-Cache=true -o Acquire::http::No-Cache=true -o Acquire::http::No-Store=true update
```

### D) Error: **NO_PUBKEY … repo is not signed**
Reinstala la llave pública:
```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://soportecx3c-oss.github.io/cx3c-apt/dists/stable/cx3c.asc \
 | sudo gpg --dearmor -o /etc/apt/keyrings/cx3c.gpg
sudo chmod 0644 /etc/apt/keyrings/cx3c.gpg
sudo apt update
```

### E) “Unable to locate package cx3c-tools”
1) Verifica que el repo esté operativo:
```bash
curl -I https://soportecx3c-oss.github.io/cx3c-apt/dists/stable/InRelease
curl -I https://soportecx3c-oss.github.io/cx3c-apt/dists/stable/main/binary-amd64/Packages
```
2) Refresca índices localmente:
```bash
sudo apt update
apt-cache policy cx3c-tools
```

---

## Quitar el repo CX3C (opcional)
```bash
sudo rm -f /etc/apt/sources.list.d/cx3c.list /etc/apt/keyrings/cx3c.gpg
sudo rm -f /var/lib/apt/lists/*soportecx3c-oss* /var/lib/apt/lists/partial/*soportecx3c-oss* 2>/dev/null || true
sudo apt update
```
