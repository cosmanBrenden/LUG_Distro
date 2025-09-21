#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

DISTRO_NAME="lug-distro"
DISTRO_VERSION="1.0.0"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "============================================="
echo "LUG Distro Build Script"
echo "============================================="
echo "Distro Name: $DISTRO_NAME"
echo "Version: $DISTRO_VERSION"
echo "Build Date: $BUILD_DATE"
echo "Project Root: $PROJECT_ROOT"
echo "============================================="

cd "$PROJECT_ROOT"

echo "Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running"
    exit 1
fi

echo "Pulling base image..."
docker pull debian:bookworm-slim

echo "Building distro image..."
docker build \
    -t "$DISTRO_NAME:$DISTRO_VERSION" \
    -t "$DISTRO_NAME:latest" \
    --build-arg BUILD_DATE="$BUILD_DATE" \
    --build-arg VERSION="$DISTRO_VERSION" \
    -f docker/Dockerfile \
    .

echo "============================================="
echo "Build completed successfully!"
echo "============================================="
echo "Image: $DISTRO_NAME:$DISTRO_VERSION"
echo "Also tagged as: $DISTRO_NAME:latest"
echo ""
echo "To run the distro:"
echo "  make run"
echo "  or"
echo "  docker run -it --rm $DISTRO_NAME:latest"
echo "============================================="