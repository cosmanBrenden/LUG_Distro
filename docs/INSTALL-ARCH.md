# LUG Distro - Arch Linux Installation Guide

## Prerequisites

### Install Docker
```bash
sudo pacman -S docker docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

### Install Build Dependencies

#### For Container Building
```bash
sudo pacman -S make git
```

#### For ISO Generation
```bash
sudo pacman -S xorriso grub squashfs-tools
```

#### For Testing (Optional)
```bash
sudo pacman -S qemu-desktop
```

## Building the Distro

### Clone and Build
```bash
git clone <repository-url>
cd lug-distro
make build
```

### Build ISO
```bash
make iso
```

## Testing

### Test in Container
```bash
make run
```

### Test ISO with QEMU
```bash
qemu-system-x86_64 -cdrom build/lug-distro-1.0.0.iso -m 2G
```

### Create Bootable USB
```bash
sudo dd if=build/lug-distro-1.0.0.iso of=/dev/sdX bs=4M status=progress
```

## Troubleshooting

### Docker Permission Issues
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Missing Dependencies
Install all required packages:
```bash
sudo pacman -S docker docker-compose make git xorriso grub squashfs-tools qemu-desktop
```

### ISO Build Fails
Ensure all dependencies are installed:
```bash
make check-iso-deps
```

## Package Information

| Package | Purpose |
|---------|---------|
| docker | Container runtime |
| docker-compose | Multi-container management |
| make | Build automation |
| git | Version control |
| xorriso | ISO creation |
| grub | Bootloader for ISO |
| squashfs-tools | Filesystem compression |
| qemu-desktop | Virtual machine testing |