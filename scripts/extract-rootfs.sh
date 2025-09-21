#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
DISTRO_NAME="lug-distro"

echo "============================================="
echo "LUG Distro Filesystem Extractor"
echo "============================================="

cd "$PROJECT_ROOT"

mkdir -p "$BUILD_DIR"

if ! docker images | grep -q "$DISTRO_NAME:latest"; then
    echo "Docker image not found. Building first..."
    make build
fi

echo "Creating temporary container..."
CONTAINER_ID=$(docker create "$DISTRO_NAME:latest")

echo "Extracting filesystem to $BUILD_DIR/rootfs..."
rm -rf "$BUILD_DIR/rootfs"
mkdir -p "$BUILD_DIR/rootfs"
docker export "$CONTAINER_ID" | tar -xf - -C "$BUILD_DIR/rootfs"

echo "Cleaning up container..."
docker rm "$CONTAINER_ID"

echo "Creating filesystem tarball..."
cd "$BUILD_DIR"
tar -czf "lug-distro-rootfs.tar.gz" -C rootfs .

echo "============================================="
echo "Filesystem extracted successfully!"
echo "============================================="
echo "Directory: $BUILD_DIR/rootfs"
echo "Tarball: $BUILD_DIR/lug-distro-rootfs.tar.gz"
echo "Size: $(du -sh rootfs | cut -f1)"
echo "============================================="