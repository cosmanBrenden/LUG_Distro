#!/bin/bash
set -e

# LUG Distribution ISO Build Script
# This script builds a bootable live ISO using live-build

echo "========================================="
echo "LUG Distribution ISO Builder"
echo "========================================="
echo ""

# Configuration
DISTRO_NAME="${DISTRO_NAME:-LUG}"
DISTRO_VERSION="${DISTRO_VERSION:-1.0.0}"
DEBIAN_RELEASE="${DEBIAN_RELEASE:-bookworm}"
ISO_NAME="${ISO_NAME:-lug-live-${DISTRO_VERSION}-amd64.iso}"
BUILD_DIR="/build"
OUTPUT_DIR="/build/output"
CHROOT_DIR="${BUILD_DIR}/chroot"
ISO_DIR="${BUILD_DIR}/iso"

echo "Build Configuration:"
echo "  Distribution: ${DISTRO_NAME}"
echo "  Version: ${DISTRO_VERSION}"
echo "  Debian Release: ${DEBIAN_RELEASE}"
echo "  ISO Name: ${ISO_NAME}"
echo ""

# Clean previous build if exists
echo "[1/9] Cleaning previous build..."
rm -rf "${CHROOT_DIR}" "${ISO_DIR}"
mkdir -p "${CHROOT_DIR}" "${ISO_DIR}" "${OUTPUT_DIR}"

# Initialize live-build configuration
echo "[2/9] Initializing live-build configuration..."
cd "${BUILD_DIR}"

# Create live-build config
lb config noauto \
    --distribution "${DEBIAN_RELEASE}" \
    --architectures amd64 \
    --linux-flavours amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --debian-installer false \
    --bootappend-live "boot=live components quiet splash" \
    --bootloader syslinux \
    --binary-images iso-hybrid \
    --mode debian \
    --system live \
    --memtest none \
    --apt-recommends false \
    --apt-indices false \
    --checksums sha256 \
    --zsync false

echo "[3/9] Configuring package lists..."
# Create package list for KDE Plasma 5.27
mkdir -p config/package-lists
cat > config/package-lists/desktop.list.chroot <<EOF
# Core System
systemd
network-manager
network-manager-gnome
firmware-linux-nonfree
firmware-misc-nonfree
firmware-iwlwifi
firmware-realtek
firmware-atheros

kde-plasma-desktop
sddm
sddm-theme-breeze
qtwayland5

# Applications
firefox-esr
chromium
libreoffice
libreoffice-plasma
gimp
inkscape

# Development tools
gcc
g++
make
git
vim
build-essential
cmake

# Utilities
sudo
wget
curl
pulseaudio
bluez
cups
calamares

# Additional tools
nano
htop
tree
less
EOF

echo "[4/9] Configuring hooks..."
# Create configuration hook for SDDM autologin
mkdir -p config/hooks/normal
cat > config/hooks/normal/0100-configure-sddm.hook.chroot <<'EOF'
#!/bin/bash
set -e

# Configure SDDM for auto-login
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/autologin.conf <<SDDM
[Autologin]
User=user
Session=plasma
SDDM

# Enable SDDM
systemctl enable sddm

# Disable automatic updates
systemctl mask apt-daily.timer apt-daily-upgrade.timer
systemctl disable unattended-upgrades || true

# Create live user
useradd -m -s /bin/bash -G sudo,audio,video,plugdev user
echo "user:live" | chpasswd
echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user
chmod 0440 /etc/sudoers.d/user
EOF

chmod +x config/hooks/normal/0100-configure-sddm.hook.chroot

echo "[5/9] Building chroot environment (this will take a while)..."
lb build 2>&1 | tee "${OUTPUT_DIR}/build.log"

echo "[6/9] Checking for generated ISO..."
if [ -f "live-image-amd64.hybrid.iso" ]; then
    echo "[7/9] Moving ISO to output directory..."
    mv live-image-amd64.hybrid.iso "${OUTPUT_DIR}/${ISO_NAME}"

    echo "[8/9] Generating checksums..."
    cd "${OUTPUT_DIR}"
    sha256sum "${ISO_NAME}" > "${ISO_NAME}.sha256"

    echo "[9/9] Build complete!"
    echo ""
    echo "========================================="
    echo "ISO Location: ${OUTPUT_DIR}/${ISO_NAME}"
    echo "Checksum: ${OUTPUT_DIR}/${ISO_NAME}.sha256"
    echo "========================================="
    echo ""
    ls -lh "${OUTPUT_DIR}/${ISO_NAME}"
    cat "${OUTPUT_DIR}/${ISO_NAME}.sha256"
else
    echo "ERROR: ISO file not generated!"
    exit 1
fi
