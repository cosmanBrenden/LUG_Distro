#!/usr/bin/env python3
import os
import sys
import yaml  # pyright: ignore[reportMissingModuleSource] we have it installed in the container
import subprocess
import shutil
# from pathlib import Path

ISO_URL = "https://files.kde.org/neon/images/user/20251127-0745/neon-user-20251127-0745.iso"
OUTPUT_DIR = "/output/container"
PREBUILD_ISO = f"{OUTPUT_DIR}/prebuild.iso"
BUILD_ISO = f"{OUTPUT_DIR}/build.iso"
EXTRACT_DIR = f"{OUTPUT_DIR}/iso-extract"
SQUASHFS_DIR = f"{OUTPUT_DIR}/squashfs-root"
MOUNT_DIR = f"{OUTPUT_DIR}/iso-mount"

def run_command(cmd, check=True):
    """Execute a shell command"""
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and result.returncode != 0:
        print(f"Error: {result.stderr}")
        sys.exit(1)
    return result

def download_iso():
    """Download the ISO file"""
    # create output dir if needed
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    if os.path.exists(PREBUILD_ISO):
        print(f"{PREBUILD_ISO} already exists, skipping download")
        return
    
    print(f"Downloading ISO from {ISO_URL}...")
    run_command(f"wget -O {PREBUILD_ISO} {ISO_URL}")
    print("Download complete!")

def extract_iso():
    """Extract ISO contents"""
    print("Extracting ISO contents...")
    os.makedirs(EXTRACT_DIR, exist_ok=True)
    os.makedirs(MOUNT_DIR, exist_ok=True)
    
    # Mount the ISO
    run_command(f"mount -o loop {PREBUILD_ISO} {MOUNT_DIR}")
    
    # Copy contents
    run_command(f"rsync -a {MOUNT_DIR}/ {EXTRACT_DIR}/")
    
    # Unmount
    run_command(f"umount {MOUNT_DIR}")
    
    # Make writable
    run_command(f"chmod -R u+w {EXTRACT_DIR}")
    print("ISO extracted successfully!")

def extract_squashfs():
    """Extract the squashfs filesystem"""
    print("Extracting squashfs filesystem...")
    squashfs_path = f"{EXTRACT_DIR}/casper/filesystem.squashfs"
    
    if not os.path.exists(squashfs_path):
        print(f"Error: {squashfs_path} not found!")
        sys.exit(1)
    
    run_command(f"unsquashfs -d {SQUASHFS_DIR} {squashfs_path}")
    
    # copy dns config into chroot so network works
    print("Setting up network for chroot...")
    shutil.copy("/etc/resolv.conf", f"{SQUASHFS_DIR}/etc/resolv.conf")
    
    print("Squashfs extracted successfully!")

def load_yaml(filename):
    """Load YAML configuration file"""
    try:
        with open(filename, 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading {filename}: {e}")
        return {}

def install_dependencies():
    """Install packages from dependencies.yml"""
    print("Installing dependencies...")
    deps = load_yaml('dependencies.yml')
    
    # Prepare chroot script
    script_lines = ["#!/bin/bash", "set -e"]
    
    # Add APT keys
    if deps.get('apt_keys'):
        for key_url in deps['apt_keys']:
            script_lines.append(f"wget -qO- {key_url} | apt-key add -")
    
    # Add repositories
    if deps.get('apt_repositories'):
        script_lines.append("apt-get update")
        for repo in deps['apt_repositories']:
            script_lines.append(f"add-apt-repository -y {repo}")
    
    # Update and install APT packages
    if deps.get('apt_packages'):
        script_lines.append("apt-get update")
        packages = ' '.join(deps['apt_packages'])
        script_lines.append(f"DEBIAN_FRONTEND=noninteractive apt-get install -y {packages}")
    
    # Install snap packages
    if deps.get('snap_packages'):
        for pkg in deps['snap_packages']:
            if isinstance(pkg, dict):
                name = pkg['name']
                classic = '--classic' if pkg.get('classic', False) else ''
                script_lines.append(f"snap install {classic} {name}")
            else:
                script_lines.append(f"snap install {pkg}")
    
    # Install pip packages
    if deps.get('pip_packages'):
        packages = ' '.join(deps['pip_packages'])
        script_lines.append(f"pip3 install {packages}")
    
    # Write and execute script
    script_path = f"{SQUASHFS_DIR}/tmp/install_deps.sh"
    with open(script_path, 'w') as f:
        f.write('\n'.join(script_lines))
    
    os.chmod(script_path, 0o755)
    run_command(f"chroot {SQUASHFS_DIR} /tmp/install_deps.sh")
    os.remove(script_path)
    print("Dependencies installed!")

def copy_files_from_paths_json():
    """Copy files based on files/paths.json mapping"""
    paths_json = "files/paths.json"
    
    if not os.path.exists(paths_json):
        print("No files/paths.json found, skipping file copy...")
        return
    
    print("Copying files from files/ directory...")
    
    try:
        import json
        with open(paths_json, 'r') as f:
            file_mappings = json.load(f)
        
        for filename, dest_path in file_mappings.items():
            src = f"files/{filename}"
            dst = f"{SQUASHFS_DIR}{dest_path}"
            
            if not os.path.exists(src):
                print(f"Warning: {src} not found, skipping...")
                continue
            
            # Create destination directory if it doesn't exist
            dest_dir = os.path.dirname(dst)
            os.makedirs(dest_dir, exist_ok=True)
            
            print(f"  {filename} -> {dest_path}")
            shutil.copy(src, dst)
    
    except Exception as e:
        print(f"Error copying files: {e}")

def run_setup():
    """Execute setup commands from setup.yml"""
    print("Running setup commands...")
    setup = load_yaml('setup.yml')
    
    # Set hostname
    if setup.get('configurations', {}).get('hostname'):
        hostname = setup['configurations']['hostname']
        with open(f"{SQUASHFS_DIR}/etc/hostname", 'w') as f:
            f.write(f"{hostname}\n")
    
    # Copy files from files/paths.json
    copy_files_from_paths_json()
    
    # Copy files from setup.yml (legacy support)
    if setup.get('files'):
        for file_op in setup['files']:
            src = file_op['source']
            dst = f"{SQUASHFS_DIR}{file_op['destination']}"
            
            # Create destination directory if it doesn't exist
            dest_dir = os.path.dirname(dst)
            os.makedirs(dest_dir, exist_ok=True)
            
            shutil.copy(src, dst)
            if file_op.get('permissions'):
                os.chmod(dst, int(file_op['permissions'], 8))
    
    # Execute commands in priority order
    commands = setup.get('commands', [])
    commands.sort(key=lambda x: x.get('priority', 50))
    
    for cmd in commands:
        print(f"[Priority {cmd.get('priority', 50)}] {cmd['name']}: {cmd.get('description', '')}")
        script_path = f"{SQUASHFS_DIR}/tmp/setup_cmd.sh"
        with open(script_path, 'w') as f:
            f.write(f"#!/bin/bash\nset -e\n{cmd['command']}\n")
        os.chmod(script_path, 0o755)
        run_command(f"chroot {SQUASHFS_DIR} /tmp/setup_cmd.sh")
        os.remove(script_path)
    
    print("Setup complete!")

def repack_squashfs():
    """Repack the squashfs filesystem"""
    print("Repacking squashfs...")
    squashfs_path = f"{EXTRACT_DIR}/casper/filesystem.squashfs"
    
    # Remove old squashfs
    os.remove(squashfs_path)
    
    # Create new squashfs
    run_command(f"mksquashfs {SQUASHFS_DIR} {squashfs_path} -comp xz -b 1M")
    
    # Update manifest
    manifest_path = f"{EXTRACT_DIR}/casper/filesystem.manifest"
    run_command(f"chroot {SQUASHFS_DIR} dpkg-query -W --showformat='${{Package}} ${{Version}}\\n' > {manifest_path}")
    
    print("Squashfs repacked!")

def create_iso():
    """Create the final ISO"""
    print("Creating final ISO...")
    
    # Update md5sums
    os.chdir(EXTRACT_DIR)
    run_command("find . -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat > md5sum.txt")
    os.chdir("..")
    
    # Create ISO
    run_command(f"""
        xorriso -as mkisofs \
        -r -V "Custom Neon" \
        -o {BUILD_ISO} \
        -J -l -b isolinux/isolinux.bin \
        -c isolinux/boot.cat -no-emul-boot \
        -boot-load-size 4 -boot-info-table \
        -eltorito-alt-boot -e boot/grub/efi.img \
        -no-emul-boot -isohybrid-gpt-basdat \
        {EXTRACT_DIR}
    """)
    
    print(f"ISO created successfully: {BUILD_ISO}")

def cleanup(keep_extracted):
    """Clean up temporary files"""
    if not keep_extracted:
        print("Cleaning up temporary files...")
        if os.path.exists(EXTRACT_DIR):
            shutil.rmtree(EXTRACT_DIR)
        if os.path.exists(SQUASHFS_DIR):
            shutil.rmtree(SQUASHFS_DIR)
        if os.path.exists(MOUNT_DIR):
            os.rmdir(MOUNT_DIR)
        print("Cleanup complete!")
    else:
        print("Keeping extracted files as requested")

def main():
    """Main execution flow"""
    print("=== ISO Customization Builder ===\n")
    
    # Ask about cleanup preference
    keep_extracted = False
    if len(sys.argv) > 1 and sys.argv[1] == "--keep":
        keep_extracted = True
        print("Will keep extracted files after build\n")
    else:
        print("Will clean extracted files after build (use --keep to preserve)\n")
    
    try:
        download_iso()
        extract_iso()
        extract_squashfs()
        install_dependencies()
        run_setup()
        repack_squashfs()
        create_iso()
        cleanup(keep_extracted)
        
        print("\n=== Build Complete! ===")
        print(f"Your customized ISO is ready: {BUILD_ISO}")
        
    except KeyboardInterrupt:
        print("\n\nBuild interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\nBuild failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()