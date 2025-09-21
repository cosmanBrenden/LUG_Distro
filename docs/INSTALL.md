# LUG Distro - Installation Guide

This guide helps you set up the build environment for LUG Distro on various Linux distributions.

## Quick Start

1. **Choose your distribution guide:**
   - [Arch Linux](INSTALL-ARCH.md)
   - [Debian/Ubuntu](INSTALL-DEBIAN.md)
   - [Fedora/RHEL/CentOS](INSTALL-FEDORA.md)

2. **Build the distro:**
   ```bash
   make build
   make iso
   ```

3. **Test the result:**
   ```bash
   qemu-system-x86_64 -cdrom build/lug-distro-1.0.0.iso -m 2G
   ```

## Requirements

### Minimum System Requirements
- 4GB RAM (8GB recommended for ISO building)
- 10GB free disk space
- x86_64 architecture
- Linux kernel 3.10+

### Required Software
- Docker 20.10+
- Make
- Git
- GRUB tools
- XorrISO
- SquashFS tools

## Build Process Overview

1. **Container Build**: Creates a minimal Debian-based container
2. **Filesystem Extraction**: Extracts the container filesystem
3. **ISO Generation**: Creates a bootable ISO with GRUB bootloader
4. **Live System**: Boots as a live system from ISO/USB

## Available Commands

### Container Management
```bash
make build          # Build Docker image
make run             # Run container interactively
make daemon          # Run container as daemon
make shell           # Get shell in running container
make stop            # Stop container
make clean           # Remove container and images
```

### ISO Building
```bash
make iso             # Build bootable ISO
make extract-rootfs  # Extract filesystem only
make check-iso-deps  # Verify dependencies
```

### Development
```bash
make dev-build       # Build development image
make rebuild         # Clean rebuild everything
```

## Output Files

- **Docker Image**: `lug-distro:latest`
- **ISO File**: `build/lug-distro-1.0.0.iso`
- **Filesystem**: `build/rootfs/` and `build/lug-distro-rootfs.tar.gz`

## Testing Options

### 1. Container Testing
```bash
make run
```
Test the distro in a container environment.

### 2. Virtual Machine Testing
```bash
qemu-system-x86_64 -cdrom build/lug-distro-1.0.0.iso -m 2G -enable-kvm
```
Test the ISO in a virtual machine.

### 3. Physical Hardware Testing
```bash
sudo dd if=build/lug-distro-1.0.0.iso of=/dev/sdX bs=4M status=progress
```
Create a bootable USB drive for testing on real hardware.

## Customization

### Adding Packages
Edit `docker/Dockerfile` and add packages to the `apt-get install` command.

### Custom Configuration
Place configuration files in `config/` directory and copy them in the Dockerfile.

### Boot Configuration
Modify `scripts/build-iso.sh` to customize GRUB menu entries.

## Troubleshooting

### Common Issues

#### Docker Permission Denied
```bash
sudo usermod -aG docker $USER
newgrp docker
```

#### Missing Dependencies
Run the dependency check:
```bash
make check-iso-deps
```

#### Build Failures
Check Docker daemon status:
```bash
sudo systemctl status docker
```

#### ISO Won't Boot
Verify ISO integrity:
```bash
file build/lug-distro-1.0.0.iso
```

### Getting Help

1. Check the distribution-specific guides
2. Verify all dependencies are installed
3. Ensure Docker daemon is running
4. Check available disk space (minimum 10GB)

## Advanced Usage

### Custom ISO Labels
Edit `scripts/build-iso.sh` and modify the volume label:
```bash
VOLUME_LABEL="Custom-LUG-Distro"
```

### Multi-Architecture Support
Currently supports x86_64 only. ARM64 support planned for future releases.

### Persistence Support
The live system is read-only by default. Persistent storage can be added by modifying the live-boot configuration.

## Distribution Support Matrix

| Distribution | Package Manager | Docker Source | Status |
|--------------|----------------|---------------|---------|
| Arch Linux | pacman | Official repos | ✅ Supported |
| Debian 11+ | apt | Official repos | ✅ Supported |
| Ubuntu 20.04+ | apt | Official repos | ✅ Supported |
| Fedora 35+ | dnf | Official repos | ✅ Supported |
| RHEL 8+ | dnf | Docker CE | ✅ Supported |
| CentOS Stream | dnf | Docker CE | ✅ Supported |
| CentOS 7 | yum | Docker CE | ⚠️ Limited |

## Security Considerations

- The distro includes SSH with default credentials (change in production)
- Root access is enabled (for development purposes)
- No firewall is configured by default
- Live system is ephemeral (changes are lost on reboot)