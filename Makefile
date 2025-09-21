DISTRO_NAME = lug-distro
DISTRO_VERSION = 1.0.0
IMAGE_NAME = $(DISTRO_NAME):$(DISTRO_VERSION)
IMAGE_LATEST = $(DISTRO_NAME):latest
CONTAINER_NAME = $(DISTRO_NAME)-container

.PHONY: help build run stop clean shell logs pull-base iso extract-rootfs check-iso-deps

help:
	@echo "LUG Distro Build System"
	@echo "======================="
	@echo ""
	@echo "Available targets:"
	@echo "  build        - Build the distro Docker image"
	@echo "  run          - Run the distro container interactively"
	@echo "  daemon       - Run the distro container as daemon"
	@echo "  stop         - Stop the running container"
	@echo "  clean        - Remove container and images"
	@echo "  shell        - Get a shell in running container"
	@echo "  logs         - Show container logs"
	@echo "  pull-base    - Pull latest Debian base image"
	@echo "  rebuild      - Clean and rebuild everything"
	@echo "  iso          - Build bootable ISO image"
	@echo "  extract-rootfs - Extract filesystem from Docker image"
	@echo "  check-iso-deps - Check ISO build dependencies"
	@echo ""

build:
	@echo "Building $(IMAGE_NAME)..."
	docker build -t $(IMAGE_NAME) -t $(IMAGE_LATEST) -f docker/Dockerfile .
	@echo "Build complete!"

pull-base:
	@echo "Pulling latest Debian base image..."
	docker pull debian:bookworm-slim

run:
	@echo "Running $(CONTAINER_NAME) interactively..."
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		--hostname lug-distro \
		--privileged \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-p 2222:22 \
		$(IMAGE_LATEST)

daemon:
	@echo "Starting $(CONTAINER_NAME) as daemon..."
	docker run -d \
		--name $(CONTAINER_NAME) \
		--hostname lug-distro \
		--privileged \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-p 2222:22 \
		$(IMAGE_LATEST) \
		/sbin/init

stop:
	@echo "Stopping $(CONTAINER_NAME)..."
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)

clean: stop
	@echo "Cleaning up images and containers..."
	-docker rmi $(IMAGE_NAME) $(IMAGE_LATEST)
	-docker system prune -f

shell:
	@echo "Getting shell in $(CONTAINER_NAME)..."
	docker exec -it $(CONTAINER_NAME) /bin/bash

logs:
	@echo "Showing logs for $(CONTAINER_NAME)..."
	docker logs -f $(CONTAINER_NAME)

rebuild: clean pull-base build
	@echo "Rebuild complete!"

dev-build:
	@echo "Building development image..."
	docker build --no-cache -t $(DISTRO_NAME):dev -f docker/Dockerfile .

iso: build check-iso-deps
	@echo "Building ISO image..."
	./scripts/build-iso.sh

extract-rootfs: build
	@echo "Extracting filesystem..."
	./scripts/extract-rootfs.sh

check-iso-deps:
	@echo "Checking ISO build dependencies..."
	@command -v xorriso >/dev/null 2>&1 || { echo "Error: xorriso not found. Install with: sudo apt install xorriso"; exit 1; }
	@command -v grub-mkrescue >/dev/null 2>&1 || { echo "Error: grub-mkrescue not found. Install with: sudo apt install grub-pc-bin grub-efi-amd64-bin"; exit 1; }
	@command -v mksquashfs >/dev/null 2>&1 || { echo "Error: mksquashfs not found. Install with: sudo apt install squashfs-tools"; exit 1; }
	@echo "All dependencies found!"

install:
	@echo "Installation scripts not yet implemented"
	@echo "This would create installation media"