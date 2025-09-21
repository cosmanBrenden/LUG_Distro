# LUG Distro - Fedora/RHEL/CentOS Installation Guide

## Prerequisites

### Install Docker

#### Fedora
```bash
sudo dnf install docker docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

#### RHEL/CentOS 8+
```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

#### CentOS 7
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

### Install Build Dependencies

#### For Container Building
```bash
sudo dnf install make git
```

#### For ISO Generation
```bash
sudo dnf install xorriso grub2-tools-extra squashfs-tools
```

#### For Testing (Optional)
```bash
sudo dnf install qemu-system-x86
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

### SELinux Issues
If you encounter SELinux issues:
```bash
sudo setsebool -P container_manage_cgroup on
```

### Firewall Issues
```bash
sudo firewall-cmd --permanent --zone=trusted --add-interface=docker0
sudo firewall-cmd --reload
```

### Missing Dependencies
Install all required packages:

#### Fedora
```bash
sudo dnf install docker docker-compose make git xorriso grub2-tools-extra squashfs-tools qemu-system-x86
```

#### RHEL/CentOS
```bash
sudo dnf install make git xorriso grub2-tools-extra squashfs-tools qemu-system-x86
```

### ISO Build Fails
Ensure all dependencies are installed:
```bash
make check-iso-deps
```

## Distribution-Specific Notes

### Fedora
- Uses dnf package manager
- Docker is available in default repositories
- All ISO tools are readily available

### RHEL 8+
- Requires Docker CE from Docker's repository
- May need EPEL repository for some tools:
```bash
sudo dnf install epel-release
```

### CentOS 7
- Uses yum package manager
- Requires Docker CE installation
- May need additional repositories

### CentOS Stream
- Similar to RHEL 8+ instructions
- Uses dnf package manager

## Package Information

| Package | Purpose | Fedora | RHEL/CentOS |
|---------|---------|--------|-------------|
| docker | Container runtime | ✓ | External repo |
| docker-compose | Multi-container management | ✓ | Plugin version |
| make | Build automation | ✓ | ✓ |
| git | Version control | ✓ | ✓ |
| xorriso | ISO creation | ✓ | ✓ |
| grub2-tools-extra | Bootloader tools | ✓ | ✓ |
| squashfs-tools | Filesystem compression | ✓ | ✓ |
| qemu-system-x86 | Virtual machine testing | ✓ | ✓ |