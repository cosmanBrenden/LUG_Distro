FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required tools for ISO manipulation
RUN apt-get update && apt-get install -y \
    wget \
    rsync \
    curl \
    xorriso \
    squashfs-tools \
    genisoimage \
    isolinux \
    syslinux-utils \
    python3 \
    python3-pip \
    python3-yaml \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /iso-builder

# Copy configuration files
COPY docker/dependencies.yml docker/setup.yml ./

# Copy the build script
COPY docker/build.py ./

# Set the entrypoint
ENTRYPOINT ["python3", "build.py"]
