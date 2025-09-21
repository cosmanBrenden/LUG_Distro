# LUG Distro - Debian/Ubuntu Installation Guide

## Prerequisites

### Install Docker
```bash
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

### Install Build Dependencies

#### For Container Building
```bash
sudo apt install make git
```

#### For ISO Generation
```bash
sudo apt install xorriso grub-pc-bin grub-efi-amd64-bin squashfs-tools
```

#### For Testing (Optional)
```bash
sudo apt install qemu-system-x86
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

### Docker Daemon Not Running
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Missing Dependencies
Install all required packages:
```bash
sudo apt update
sudo apt install docker.io docker-compose make git xorriso grub-pc-bin grub-efi-amd64-bin squashfs-tools qemu-system-x86
```

### ISO Build Fails
Ensure all dependencies are installed:
```bash
make check-iso-deps
```

### Legacy Docker Builder Warning
To use the new builder:
```bash
sudo apt install docker-buildx-plugin
docker buildx install
```

## Distribution-Specific Notes

### Ubuntu 20.04+
Docker.io package is recommended over docker-ce for simplicity.

### Debian 11+
All packages are available in the default repositories.

### Older Versions
For older distributions, you may need to install Docker from Docker's official repository:
```bash
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```

## Package Information

| Package | Purpose |
|---------|---------|
| docker.io | Container runtime |
| docker-compose | Multi-container management |
| make | Build automation |
| git | Version control |
| xorriso | ISO creation |
| grub-pc-bin | BIOS bootloader |
| grub-efi-amd64-bin | UEFI bootloader |
| squashfs-tools | Filesystem compression |
| qemu-system-x86 | Virtual machine testing |