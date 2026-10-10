# OpenCode Portable (Windows 10 / 11) - Versión 2

[![Licencia MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Plataforma](https://img.shields.io/badge/plataforma-Windows%2010%20%7C%2011-0078D6.svg)](https://microsoft.com/windows)
[![OpenCode v2](https://img.shields.io/badge/OpenCode-v2.0-8A2BE2.svg)](https://opencode.ai/v2)

[English](README.md) | **Español**

Edición portable, autocontenida y autónoma de **OpenCode v2** diseñada específicamente para Windows 10 y Windows 11. Puede ejecutarse directamente desde un pendrive USB o disco externo en cualquier equipo, reteniendo el 100% de tus configuraciones, credenciales y sesiones sin tocar ni depender del sistema anfitrión.

> **Cero dependencias de terceros:** Los binarios y herramientas se obtienen directamente de los canales oficiales de [anomalyco/opencode](https://github.com/anomalyco/opencode), [opencode.ai](https://opencode.ai), [Git for Windows](https://github.com/git-for-windows/git) y [Node.js](https://nodejs.org).

---

## 🚀 Características Principales

1. **100% Portable (Plug & Play USB):**
   - Ejecutable desde cualquier letra de unidad (`D:`, `E:`, `F:`, etc.).
   - Rutas relativas dinámicas sin anclarse a rutas absolutas del host.

2. **Aislamiento Total y Persistencia de Datos:**
   - Tus credenciales (`/connect`), historial de sesiones, agentes y configuraciones residen dentro de la carpeta `data/` en el pendrive.
   - Variables de entorno de Windows (`USERPROFILE`, `APPDATA`, `LOCALAPPDATA`, `TEMP`, `TMP`, `HOME`) redirigidas a la unidad USB.
   - Cumple con la especificación XDG Base Directory (`XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_STATE_HOME`) y las variables oficiales de OpenCode v2 (`OPENCODE_CONFIG_DIR`, `OPENCODE_DATA_DIR`, etc.).
   - **No deja rastros ni archivos temporales en el disco `C:` del equipo anfitrión.**

3. **Herramientas Autocontenidas (Zero-Host-Dependency):**
   - **OpenCode v2 oficial:** Binario nativo compilado de 64 bits para Windows (`bin/opencode.exe`).
   - **Git Portable integrado:** [MinGit](https://github.com/git-for-windows/git) con busybox en `tools/git/` para diffs, estado y operaciones de repositorio sin requerir Git en el host.
   - **Node.js Portable LTS:** Runtime oficial de Node.js en `tools/node/` para dar soporte a servidores MCP (`npx`, `npm`) y plugins.

4. **Integración con Windows Terminal (Sin defectos de caracteres):**
   - Detecta automáticamente **Windows Terminal (`wt.exe`)** y lo prioriza para renderizado DirectWrite acelerado por GPU, soporte UTF-8 real y bordes TUI perfectos.
   - Si Windows Terminal no está instalado, conmuta limpiamente a un puente PowerShell 5.1+ con codificación UTF-8, eliminando defectos de caracteres de la consola CMD clásica.
   - El shell interno para la terminal y herramientas de OpenCode está preconfigurado en **PowerShell** en `data/config/opencode/opencode.jsonc`.

5. **Autoactualizador Oficial Integrado:**
   - Comprueba y actualiza OpenCode a la versión más reciente en 1 clic.
   - Conserva intactas todas tus configuraciones, sesiones y datos en `data/`.
   - Soporta rollback automático ante interrupciones de red.


---

## 📁 Estructura del Directorio

```text
opencode-portable/
│
├── opencode.bat                 # Lanzador principal (doble clic o desde CMD / Terminal)
├── opencode.ps1                 # Lanzador nativo para PowerShell
├── update.bat                   # Autoactualizador rápido con doble clic
├── shell.bat                    # Consola aislada con OpenCode, Git y Node en el PATH
│
├── bin/
│   └── opencode.exe             # Binario nativo oficial de OpenCode v2
│
├── tools/
│   ├── git/                     # Git Portable oficial (MinGit + Busybox)
│   └── node/                    # Node.js Portable LTS oficial
│
├── data/                        # 💾 TODOS TUS DATOS PORTABLES PERSISTEN AQUÍ
│   ├── config/
│   │   ├── opencode/
│   │   │   ├── opencode.example.jsonc # Plantilla de configuración
│   │   │   └── opencode.jsonc   # Tu archivo de configuración activo
│   │   └── .gitconfig           # Configuración de Git portable
│   ├── share/                   # Bases de datos y sesiones guardadas
│   ├── cache/                   # Caché de modelos y búsquedas
│   ├── state/                   # Estado de OpenCode
│   ├── logs/                    # Registros de OpenCode
│   ├── profile/                 # Perfil de usuario aislado
│   ├── appdata/                 # Datos de aplicaciones aislados (Roaming y Local)
│   └── temp/                    # Archivos temporales aislados
│
└── scripts/
    ├── env.bat                  # Configurador y aislador de variables de entorno
    ├── setup.ps1                # Aprovisionador inicial del kit portable
    ├── update.ps1               # Lógica de autoactualización segura
    └── package-release.ps1      # Generador de zip para GitHub Releases
```

---

## ⚡ Guía de Inicio Rápido (Paso a Paso)

No necesitas tener nada instalado previamente en tu computadora (ni Node.js, ni Git, ni Python). Todo lo necesario se ejecuta de manera autocontenida dentro de tu memoria USB.

### Paso 1: Preparar tu Memoria USB

Conecta tu memoria USB o pendrive a cualquier puerto de tu PC con **Windows 10 o 11** (64 bits). Recomendamos un pendrive con al menos **1 a 2 GB** de espacio libre.

Elige **una de las dos opciones** para colocar los archivos en tu memoria:

#### Opción A (Recomendada para la mayoría): Descargar el ZIP oficial
1. Ve a la sección de **[Releases de GitHub](https://github.com/cgmark101/opencode-portable/releases/latest)**.
2. Descarga el archivo comprimido: `opencode-portable-windows-x64.zip`.
3. Abre tu memoria USB (por ejemplo la unidad `E:\` o `D:\`) y descomprime el archivo ahí.  
   Te quedará una carpeta como `E:\opencode-portable` (o en la raíz del USB).

#### Opción B (Para desarrolladores): Clonar con Git
Si tienes Git en tu máquina actual y prefieres clonar el repositorio directamente:
```cmd
cd /d E:\
git clone https://github.com/cgmark101/opencode-portable.git
cd opencode-portable
```

---

### Paso 2: Primer Arranque (Instalación Automática)

1. Abre la carpeta `opencode-portable` en tu memoria USB.
2. Haz **doble clic en `opencode.bat`** (o en PowerShell: `.\opencode.ps1`).
3. **¿Qué sucederá automáticamente?**
   * El asistente detectará que es el primer inicio en el USB.
   * Descargará de forma segura y directa desde los servidores oficiales el ejecutable de **OpenCode v2** (`bin\opencode.exe`), **Git Portable** y **Node.js Portable LTS**.
   * Creará tu estructura de carpetas aislada dentro de la carpeta `data/`.
   * En menos de 1 minuto, la interfaz interactiva (TUI) de OpenCode se abrirá en tu pantalla.

---

### Paso 3: Conectar tus Proveedores de IA

Una vez dentro de la terminal de OpenCode:
1. Escribe el comando:
   ```text
   /connect
   ```
2. Selecciona tu proveedor preferido (OpenAI, Anthropic Claude, Google Gemini, Groq, Ollama local, etc.).
3. Pega tu API Key cuando te la solicite.
4. **¡Listo!** Tus credenciales se almacenan cifradas dentro de la carpeta `data/` de tu USB. **Nunca se guardan en el disco `C:\` de la computadora.**

---

### Paso 4: ¿Cómo usarlo en OTRA computadora diferente? (Plug & Play)

Cuando quieras trabajar en otra computadora (en la oficina, universidad, portátil de un amigo, etc.):
1. **Expulsa de forma segura tu pendrive** de la máquina actual.
2. **Conéctalo a la nueva PC**.
3. Abre tu memoria USB y simplemente haz doble clic en:
   ```cmd
   opencode.bat
   ```
4. **¡Magia!** OpenCode detecta la nueva letra de unidad automáticamente (`F:`, `G:`, etc.). Tus sesiones previas, historial, archivos de configuración y credenciales de `/connect` estarán exactamente donde los dejaste, listos para trabajar, y **sin dejar ningún rastro en la computadora anfitriona**.

---

## 🛠️ Comandos y Herramientas Útiles

* **Ejecutar una tarea rápida por línea de comandos:**
  ```cmd
  opencode.bat run "Crea una función para validar emails en TypeScript"
  ```
* **Ver lista de modelos disponibles:**
  ```cmd
  opencode.bat models
  ```
* **Actualizar a la última versión oficial de OpenCode v2:**
  Haz doble clic en `update.bat` o ejecuta:
  ```cmd
  opencode.bat update
  ```
  *(El actualizador preserva el 100% de tus datos, sesiones y credenciales en `data/`)*.
* **Terminal de Desarrollador Portátil:**
  Haz doble clic en `shell.bat` para abrir una consola CMD aislada donde `opencode`, `git` y `node` ya están disponibles en el PATH sin alterar el sistema operativo anfitrión.

---

## ⚙️ Personalización y Configuración

Edita el archivo:
```text
data/config/opencode/opencode.jsonc
```
Ejemplo con modelo por defecto y configuración personalizada:
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  // Shell predeterminado: PowerShell 5.1+ evita defectos de caracteres en CMD
  "shell": "powershell.exe",

  // Modelo preferido
  "model": "opencode/big-pickle",
  
  // Notificar cuando existan nuevas versiones
  "autoupdate": "notify"
}
```

Para conectar tus proveedores de IA (OpenAI, Anthropic, Gemini, Groq, Ollama, etc.), dentro de la TUI ejecuta el comando:
```text
/connect
```
Tus claves API se guardarán dentro de la carpeta `data/` del pendrive.

---

## 🔒 Privacidad y Seguridad

- **Cifrado de la Unidad (Altamente Recomendado):** OpenCode almacena tokens de autenticación local (`service.json`), bases de datos de conversaciones (`opencode.db`) y registros de prompts en `data/`. Si transportas tu pendrive en público, te recomendamos encarecidamente cifrar la memoria con **BitLocker To Go** (incluido en Windows 10/11 Pro y Enterprise) o **VeraCrypt** (gratuito y de código abierto) para evitar accesos no autorizados en caso de pérdida o robo del pendrive.
- Todo el entorno se ejecuta de forma autocontenida en la unidad USB.
- Nunca compartas ni subas tu carpeta `data/` a repositorios públicos; contiene tus credenciales y sesiones.
- El archivo `.gitignore` incluido ya protege automáticamente contra la subida accidental de tus datos personales.

