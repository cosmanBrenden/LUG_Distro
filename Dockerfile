# LUG Distribution ISO Builder
# Debian-based build environment with all dependencies for creating live ISOs

FROM debian:bookworm

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Build arguments
ARG BUILD_DATE
ARG VERSION=1.0.0

# Labels
LABEL maintainer="LUG Development Team"
LABEL description="Build environment for LUG Linux Distribution"
LABEL version="${VERSION}"
LABEL build_date="${BUILD_DATE}"

# Update system and install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Core build tools
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-common \
    systemd-boot \
    # Utilities
    wget \
    curl \
    git \
    rsync \
    vim \
    nano \
    ca-certificates \
    gnupg \
    # Compression tools
    gzip \
    bzip2 \
    xz-utils \
    # File system tools
    dosfstools \
    mtools \
    # Debugging and development
    less \
    file \
    tree \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create working directories
RUN mkdir -p /build/iso \
    && mkdir -p /build/chroot \
    && mkdir -p /build/config \
    && mkdir -p /build/output \
    && mkdir -p /scripts

# Set working directory
WORKDIR /build

# Copy build scripts
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# Copy configuration files
COPY config/ /build/config/

# Set default command
CMD ["/bin/bash"]
