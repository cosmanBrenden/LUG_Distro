# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LUG is a Debian-based Linux distribution featuring a live KDE Plasma 5.27 desktop environment. It uses systemd as the init system and APT/dpkg for package management. The distribution is designed as a pure live environment (no persistence) with essential desktop packages.

### Core Specifications
- **Base**: Debian Bookworm Stable
- **Desktop**: KDE Plasma 5.27 (latest available in Bookworm) with Wayland (preferred) and X11 fallback
- **Display Manager**: SDDM with auto-login enabled
- **Target ISO Size**: Standard 4-5 GB
- **Bootloader**: systemd-boot (UEFI)
- **Network**: NetworkManager with plasma-nm integration
- **Installer**: Calamares (for permanent installation option)
- **Default Filesystem**: ext4
- **Localization**: English only
- **Firmware**: Include all common proprietary firmware/drivers
- **Updates**: Disabled/blocked in live environment
- **Theming**: Stock KDE Plasma (Breeze) theme

## Build System

The LUG distribution is built using Docker containers with live-build tools. All build dependencies are containerized for consistency and reproducibility.

### npm Commands (Recommended)

The project uses npm scripts as a command manager for easy access to build operations:

```bash
# Build the Docker image
npm run build

# Build the ISO (main command)
npm run build:iso
npm start                    # Alias for build:iso

# Open development shell in builder container
npm run dev
npm run shell               # Alternative

# View build logs
npm run logs

# Clean up
npm run clean              # Remove ISO files and Docker volumes
npm run clean:all          # Remove everything including images

# Test ISO in QEMU (requires QEMU setup)
npm run test:boot
```

### Direct Docker Compose Commands

```bash
# Build the builder image
docker-compose build

# Build the ISO
docker-compose run --rm iso-builder

# Get interactive shell in build environment
docker-compose run --rm iso-builder /bin/bash

# Run development environment
docker-compose run --rm dev-env

# Clean up
docker-compose down -v
```

### Build Script

The main build logic is in `scripts/build-iso.sh`, which:
1. Configures live-build for Debian Bookworm
2. Sets up package lists (Plasma 5.27, applications, firmware)
3. Configures SDDM auto-login via hooks
4. Disables automatic updates
5. Builds the ISO using live-build
6. Generates checksums

Output ISO location: `build/lug-live-{version}-amd64.iso`

## Architecture

### Current Development Approach
The distribution is developed using Docker containers for rapid iteration and testing. The Dockerfile in `docker/Dockerfile` defines the base system configuration.

### Required Applications
The following applications must be included:
- **Web Browsers**: Firefox and/or Chromium
- **Office Suite**: LibreOffice (Writer, Calc, Impress)
- **Graphics**: GIMP (image editing) and Inkscape (vector graphics)
- **Development**: GCC, git, build tools, text editors

### Key Components
- **Base System**: Debian Bookworm + Backports repository
- **Desktop**: KDE Plasma 6 (Wayland preferred, X11 available)
- **Display Manager**: SDDM configured for auto-login
- **User Setup**: Default live user with auto-login enabled
- **Network**: NetworkManager + plasma-nm applet
- **Firmware**: Non-free firmware for WiFi, NVIDIA, and other hardware

## Directory Structure

```
LUG_Distro/
├── scripts/
│   └── build-iso.sh           # Main ISO build script
├── config/                    # System configuration files
├── build/                     # Build output (generated)
│   └── lug-live-*.iso        # Generated ISO files
├── Dockerfile                 # Build environment definition
├── docker-compose.yml         # Container orchestration
├── package.json              # npm command manager
├── .dockerignore             # Docker build exclusions
├── .gitignore                # Git exclusions
├── README.md                 # User documentation
└── CLAUDE.md                 # AI assistant guidance
```

## Development Workflow

### Making Changes

1. **Modify package list**: Edit `scripts/build-iso.sh` in the package list section
2. **Add configuration hooks**: Create files in `config/hooks/` for system customization
3. **Test build**: Run `npm start` or `npm run build:iso`
4. **Iterate**: Use `npm run dev` to get shell access for debugging

### Essential KDE Plasma 5.27 Packages

These packages are installed via the build script in `scripts/build-iso.sh`:

**Core Desktop:**
- `plasma-desktop`, `plasma-workspace`, `kde-plasma-desktop`
- `sddm`, `sddm-theme-breeze`
- `konsole`, `dolphin`, `kate`
- `plasma-nm`, `plasma-pa`, `kscreen`, `powerdevil`, `bluedevil`
- `breeze`, `breeze-gtk-theme`, `qt5-wayland`

**Applications:**
- `firefox-esr`, `chromium`
- `libreoffice`, `libreoffice-kde5`
- `gimp`, `inkscape`
- `gcc`, `g++`, `make`, `git`, `vim`, `build-essential`, `cmake`

**System:**
- `network-manager`, `network-manager-gnome`
- `firmware-linux-nonfree`, `firmware-misc-nonfree`
- `firmware-iwlwifi`, `firmware-realtek`, `firmware-atheros`
- `pulseaudio`, `bluez`, `cups`, `sudo`, `wget`, `curl`
- `calamares` (installer)

### Adding/Removing Packages

Edit the package list in `scripts/build-iso.sh` around line 60:

```bash
cat > config/package-lists/desktop.list.chroot <<EOF
# Add your packages here
package-name
another-package
EOF
```

After changes, rebuild with `npm start`.

### Configuration Hooks

Hooks are scripts that run during the build process. Located in `scripts/build-iso.sh`:

```bash
cat > config/hooks/normal/0100-configure-sddm.hook.chroot <<'EOF'
#!/bin/bash
# Your customization script here
EOF
```

Examples:
- Configure SDDM auto-login
- Disable system services
- Create users
- Set system defaults

## Important Constraints

### Repository Configuration
- **Enable non-free and non-free-firmware**: Required for proprietary drivers
- Main sources: `main contrib non-free non-free-firmware`
- Backports not required - Plasma 5.27 available in main Bookworm repository

### KDE Plasma 5.27 Requirements
- Available in standard Bookworm repository (no backports needed)
- Uses Qt 5 libraries and KDE Frameworks 5
- SDDM configuration for auto-login in live environment
- Both Wayland and X11 sessions must be available
- Default session: Wayland (with X11 fallback option)

### Live Environment Configuration
- **Pure live**: No persistence support - all changes lost on reboot
- **Auto-login**: SDDM configured to automatically log in live user
- **Updates disabled**: Block apt updates to prevent confusion
- **ISO size target**: 4-5 GB
- **Localization**: English (US) only - no additional language packs

### Bootloader Configuration
- **Use systemd-boot** (not GRUB)
- UEFI-only boot support
- Configure for live media boot parameters

### Network Configuration
- NetworkManager as primary network management
- plasma-nm applet for KDE integration
- Include firmware-iwlwifi and other wireless firmware packages

### Installer Integration
- Include Calamares installer for permanent installation option
- Configure Calamares with ext4 as default filesystem
- Ensure proper partitioning and bootloader setup in Calamares

### Package Management
- Use `apt-get` (not `apt`) in scripts for stability
- Always update package lists before installing
- Use `--no-install-recommends` to keep size under control
- Clean apt cache after installations: `apt-get clean && rm -rf /var/lib/apt/lists/*`
- Install Plasma 5.27 packages from standard Bookworm repository

### Firmware and Drivers
- Include firmware-linux-nonfree for general hardware
- Include nvidia-driver and nvidia-firmware
- Include firmware-iwlwifi, firmware-realtek for WiFi
- Include firmware-misc-nonfree for other devices

### Systemd Integration
- SDDM enabled and configured for auto-start
- Plasma session management through systemd
- Disable unattended-upgrades and update timers
- Service files in `/etc/systemd/system/` or `/usr/lib/systemd/system/`

## ISO Build Process

The live ISO will be built using standard Debian live-build tools or custom scripts. Key steps:

1. **Debootstrap**: Create base Debian bookworm system
2. **Configure repositories**: Add non-free and non-free-firmware
3. **Install packages**: Plasma 5.27, applications, firmware
4. **Configure SDDM**: Set up auto-login for live user
5. **Disable updates**: Mask apt-daily and update services
6. **Configure systemd-boot**: Set up bootloader for UEFI
7. **Install Calamares**: Configure installer with proper settings
8. **Build squashfs**: Create compressed filesystem
9. **Create ISO**: Package with systemd-boot EFI bootloader

## Required Package List

### Core System
- `systemd`, `systemd-boot`
- `network-manager`, `network-manager-gnome` (for tray icon)
- `firmware-linux-nonfree`, `firmware-misc-nonfree`
- `firmware-iwlwifi`, `firmware-realtek`, `firmware-atheros`
- `nvidia-driver` (for NVIDIA graphics cards)

### KDE Plasma 5.27 (from main repository)
- `plasma-desktop`, `plasma-workspace`
- `sddm`, `sddm-theme-breeze`
- `kde-plasma-desktop` (meta-package)
- `konsole`, `dolphin`, `kate`
- `plasma-nm`, `plasma-pa`, `kscreen`, `powerdevil`, `bluedevil`
- `breeze`, `breeze-gtk-theme` (for theming)
- `qt5-wayland` (for Wayland session support)

### Applications
- `firefox-esr` (standard in Bookworm)
- `chromium`
- `libreoffice`, `libreoffice-kde` (KDE integration)
- `gimp`, `inkscape`
- `gcc`, `g++`, `make`, `git`, `vim` or `neovim`
- `build-essential`, `cmake`

### Installer
- `calamares`, `calamares-settings-debian` (if available)

### Utilities
- `sudo`, `wget`, `curl`
- `pulseaudio` or `pipewire` (for audio)
- `bluez` (for Bluetooth)
- `cups` (for printing)

## Configuration Files to Create

### SDDM Auto-login
Create `/etc/sddm.conf.d/autologin.conf`:
```ini
[Autologin]
User=liveuser
Session=plasma
```

### Disable APT Updates
Mask systemd services:
```bash
systemctl mask apt-daily.timer apt-daily-upgrade.timer
systemctl disable unattended-upgrades
```

### Calamares Configuration
Configure in `/etc/calamares/`:
- Set default filesystem to ext4
- Configure bootloader to systemd-boot
- Set up partition schemes
- Configure locale to en_US.UTF-8

## Development Notes

- Stock KDE Breeze theme - no custom theming needed
- Focus on functionality over appearance
- Keep ISO size between 4-5 GB
- Test boot on UEFI systems (systemd-boot requirement)
- Ensure both Wayland and X11 sessions are available in SDDM
