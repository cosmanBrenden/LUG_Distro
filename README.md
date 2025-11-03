# LUG Distribution

A Debian Bookworm-based Linux distribution featuring KDE Plasma 5.27 desktop environment. Designed as a live ISO with a modern desktop experience and essential applications.

## Features

- **Desktop**: KDE Plasma 5.27 with Wayland and X11 support
- **Base**: Debian Bookworm Stable
- **Applications**: Firefox, Chromium, LibreOffice, GIMP, Inkscape, development tools
- **Installer**: Calamares for permanent installation
- **Firmware**: Includes proprietary drivers for maximum hardware compatibility
- **Size**: ~4-5 GB ISO

## Quick Start

### Prerequisites

- Docker
- Docker Compose
- Node.js/npm (for command shortcuts)

### Building the ISO

```bash
# Install dependencies (first time only)
npm install

# Build the ISO
npm start

# Or use docker-compose directly
docker-compose run --rm iso-builder
```

### Available Commands

```bash
# Build the Docker image
npm run build

# Build the ISO
npm run build:iso
npm start              # Alias for build:iso

# Open development shell
npm run dev
npm run shell          # Alternative

# View logs
npm run logs

# Clean build artifacts
npm run clean          # Remove ISO files and volumes
npm run clean:all      # Remove everything including Docker images

# Test ISO in QEMU (requires setup)
npm run test:boot
```

## Project Structure

```
LUG_Distro/
├── scripts/
│   └── build-iso.sh           # Main ISO build script
├── config/                    # Configuration files (future)
├── build/                     # Build output (generated)
│   └── lug-live-*.iso        # Generated ISO
├── Dockerfile                 # Build environment
├── docker-compose.yml         # Container orchestration
└── package.json              # Command shortcuts
```

## Build Process

The ISO is built inside a Docker container with all necessary dependencies:

1. **Debootstrap**: Creates base Debian Bookworm system
2. **Package Installation**: Installs KDE Plasma 5.27 and applications
3. **Configuration**: Sets up SDDM auto-login, disables updates
4. **Squashfs**: Creates compressed filesystem
5. **ISO Generation**: Packages everything into bootable ISO

## Configuration

### Environment Variables

Set these in your shell or in a `.env` file:

```bash
VERSION=1.0.0                  # Distribution version
DISTRO_NAME=LUG               # Distribution name
DEBIAN_RELEASE=bookworm        # Debian release
```

### Customization

- **Packages**: Edit `scripts/build-iso.sh` package list section
- **Configuration**: Add files to `config/` directory
- **Hooks**: Customize `config/hooks/` for additional setup

## System Requirements

### Build Requirements
- 8GB+ RAM recommended
- 20GB+ free disk space
- Docker with privileged mode support

### ISO Boot Requirements
- UEFI-capable system
- 4GB+ RAM
- USB drive or DVD for installation

## Technical Details

- **Bootloader**: SYSLINUX (live), systemd-boot (installed)
- **Init**: systemd
- **Display Manager**: SDDM with auto-login
- **Network**: NetworkManager with plasma-nm
- **Package Manager**: APT/dpkg
- **Default Filesystem**: ext4

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the ISO build
5. Submit a pull request

## License

ISC License - See repository for details

## Support

- Issues: https://github.com/cosmanBrenden/LUG_Distro/issues
- Documentation: See CLAUDE.md for development guidance
