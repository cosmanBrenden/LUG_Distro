# LUG Distro

A minimal Linux distribution based on Debian, designed for containerized environments and customization.

## Quick Start

### Prerequisites
- Docker
- Docker Compose (optional)
- Make (optional, for convenience)

### Build and Run

#### Using Make (Recommended)
```bash
# Show available commands
make help

# Build the distro
make build

# Run interactively
make run

# Run as daemon (with systemd)
make daemon

# Get shell in running container
make shell

# Stop and clean up
make stop
make clean
```

#### Using Docker directly
```bash
# Build
docker build -t lug-distro:latest -f docker/Dockerfile .

# Run interactively
docker run -it --rm --privileged lug-distro:latest

# Run as daemon
docker run -d --name lug-distro --privileged -p 2222:22 lug-distro:latest /sbin/init
```

#### Using Docker Compose
```bash
# Build and run
docker-compose up -d

# Development mode
docker-compose --profile dev up -d lug-distro-dev

# Stop
docker-compose down
```

#### Using build script
```bash
./scripts/build.sh
```

## Features

- **Minimal Debian base**: Built on `debian:bookworm-slim`
- **Systemd support**: Full init system for daemon mode
- **SSH access**: Enabled on port 2222
- **Non-root user**: Default `luguser` with sudo privileges
- **Development ready**: Includes essential tools and editors

## Access

### SSH Access
```bash
ssh luguser@localhost -p 2222
# Password: luguser
```

### Direct shell access
```bash
docker exec -it lug-distro-container /bin/bash
```

## Project Structure

```
lug-distro/
├── docker/
│   └── Dockerfile           # Main distro definition
├── scripts/
│   └── build.sh            # Build automation script
├── build/                  # Build artifacts (future)
├── config/                 # Configuration files (future)
├── docker-compose.yml      # Multi-container setup
├── Makefile               # Build system
└── README.md              # This file
```

## Customization

### Adding Packages
Edit `docker/Dockerfile` and add packages to the `apt-get install` command:

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # existing packages... \
        your-package-name \
        another-package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Configuration Files
Place custom configuration files in the `config/` directory and copy them in the Dockerfile.

### Build Arguments
The Dockerfile supports build arguments:
- `BUILD_DATE`: Build timestamp
- `VERSION`: Distro version

## Development

### Development Container
Use the development profile for a container with mounted source code:

```bash
docker-compose --profile dev up -d lug-distro-dev
docker exec -it lug-distro-dev /bin/bash
```

### Rebuilding
```bash
make rebuild  # Clean and rebuild everything
```

## License

This project is open source. See individual package licenses for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build
5. Submit a pull request