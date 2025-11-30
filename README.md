# Linux User's Group Distro

This repo provides everything you need to automatically generate a tailored live ISO image based on KDE Neon, and lets us define which packages are installed and which setup command are ran for the LUG distro.

## Requirements

To use this project you only need:

- **[Node.js (Latest LTS recommended)](https://nodejs.org/)**
- **[Docker](https://www.docker.com/)**

## How to use

1. Make sure you have the latest Node.js and Docker installed.
2. Clone this repository.
3. Edit the configs in the `docker/` folder to customize your distro.
4. Build and run:

   ```bash
   npm install
   npm run build
   npm start
   ```

   To keep extracted files for debugging:

   ```bash
   npm run start:keep
   ```

## Customization

- **`docker/dependencies.yml`**: add/remove packages (APT, pip, snap, repositories etc)
- **`docker/setup.yml`**: setup users, run extra commands, copy files, change settings
