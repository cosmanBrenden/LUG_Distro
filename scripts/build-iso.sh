#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ISO_DIR="$PROJECT_ROOT/iso"
BUILD_DIR="$PROJECT_ROOT/build"
DISTRO_NAME="lug-distro"
DISTRO_VERSION="1.0.0"
ISO_NAME="$DISTRO_NAME-$DISTRO_VERSION.iso"

echo "============================================="
echo "LUG Distro ISO Builder"
echo "============================================="
echo "Building ISO: $ISO_NAME"
echo "============================================="

cd "$PROJECT_ROOT"

if ! command -v xorriso &> /dev/null; then
    echo "Error: xorriso is required for ISO creation"
    echo "Install with: sudo apt install xorriso"
    exit 1
fi

if ! command -v grub-mkrescue &> /dev/null; then
    echo "Error: grub-mkrescue is required for ISO creation"
    echo "Install with: sudo apt install grub-pc-bin grub-efi-amd64-bin"
    exit 1
fi

mkdir -p "$BUILD_DIR"

echo "Extracting filesystem from Docker image..."
if ! docker images | grep -q "$DISTRO_NAME:latest"; then
    echo "Docker image not found. Building first..."
    make build
fi

echo "Creating temporary container..."
CONTAINER_ID=$(docker create "$DISTRO_NAME:latest")

echo "Extracting filesystem..."
rm -rf "$BUILD_DIR/rootfs"
mkdir -p "$BUILD_DIR/rootfs"
docker export "$CONTAINER_ID" | tar -xf - -C "$BUILD_DIR/rootfs"

echo "Cleaning up container..."
docker rm "$CONTAINER_ID"

echo "Creating live filesystem..."
rm -rf "$BUILD_DIR/live"
mkdir -p "$BUILD_DIR/live"

echo "Creating squashfs..."
if ! command -v mksquashfs &> /dev/null; then
    echo "Error: mksquashfs is required"
    echo "Install with: sudo apt install squashfs-tools"
    exit 1
fi

mksquashfs "$BUILD_DIR/rootfs" "$BUILD_DIR/live/filesystem.squashfs" \
    -e boot \
    -comp xz \
    -b 1M

echo "Setting up boot files..."
cp -r "$BUILD_DIR/rootfs/boot"/* "$ISO_DIR/boot/" 2>/dev/null || true

echo "Creating GRUB configuration..."
cat > "$ISO_DIR/boot/grub/grub.cfg" << 'EOF'
set timeout=10
set default=0

menuentry "LUG Distro Live" {
    linux /boot/vmlinuz boot=live live-media-path=/live
    initrd /boot/initrd.img
}

menuentry "LUG Distro Live (Safe Mode)" {
    linux /boot/vmlinuz boot=live live-media-path=/live acpi=off noapic nolapic
    initrd /boot/initrd.img
}
EOF

echo "Copying live filesystem..."
cp -r "$BUILD_DIR/live" "$ISO_DIR/"

echo "Creating ISO..."
grub-mkrescue -o "$BUILD_DIR/$ISO_NAME" "$ISO_DIR"

echo "============================================="
echo "ISO created successfully!"
echo "============================================="
echo "File: $BUILD_DIR/$ISO_NAME"
echo "Size: $(du -h "$BUILD_DIR/$ISO_NAME" | cut -f1)"
echo ""
echo "To test with QEMU:"
echo "  qemu-system-x86_64 -cdrom $BUILD_DIR/$ISO_NAME -m 2G"
echo "============================================="