#!/usr/bin/env bash

# Utility functions for dotfiles management
# Source this file in other scripts: source "$(dirname "$0")/utils.sh"

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Detect package manager
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Install package if not already installed
install_package() {
    local package="$1"
    local pm="$(detect_package_manager)"

    case "$pm" in
        apt)
            if ! dpkg -l | grep -q "^ii  $package "; then
                log_info "Installing $package..."
                sudo apt install -y "$package"
            fi
            ;;
        dnf)
            if ! rpm -q "$package" &> /dev/null; then
                log_info "Installing $package..."
                sudo dnf install -y "$package"
            fi
            ;;
        pacman)
            if ! pacman -Q "$package" &> /dev/null; then
                log_info "Installing $package..."
                sudo pacman -S --noconfirm "$package"
            fi
            ;;
        *)
            log_error "Unknown package manager. Please install $package manually."
            return 1
            ;;
    esac
}

# Create directory if it doesn't exist
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_info "Created directory: $1"
    fi
}

# Backup file or directory
backup_item() {
    local source="$1"
    local dest="$2"

    if [ -e "$source" ]; then
        ensure_dir "$(dirname "$dest")"
        if [ -L "$source" ]; then
            # If it's a symlink, copy the target
            cp -rL "$source" "$dest" 2>/dev/null || cp -r "$source" "$dest" 2>/dev/null || true
        else
            # Copy recursively, ignoring permission errors
            cp -r "$source" "$dest" 2>/dev/null || true
        fi

        if [ -e "$dest" ]; then
            log_success "Backed up: $source -> $dest"
            return 0
        else
            log_warning "Failed to backup: $source (permission issues?)"
            return 1
        fi
    else
        log_warning "Source not found: $source"
        return 1
    fi
}

# Create symlink (removes existing file/symlink)
create_symlink() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            log_info "Symlink already exists: $target -> $source"
            return 0
        fi
        log_warning "Removing existing: $target"
        rm -rf "$target"
    fi

    ensure_dir "$(dirname "$target")"
    ln -s "$source" "$target"
    log_success "Created symlink: $target -> $source"
}

# Get script directory
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

# Get dotfiles root directory
get_dotfiles_root() {
    cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

# Confirm action with user
confirm() {
    local prompt="$1"
    local response

    read -p "$prompt [y/N] " -n 1 -r response
    echo
    [[ $response =~ ^[Yy]$ ]]
}

# Check if running on GNOME
is_gnome() {
    [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$GDMSESSION" = "gnome" ]
}

# Export all functions
export -f log_info log_success log_warning log_error
export -f detect_distro detect_package_manager
export -f command_exists install_package
export -f ensure_dir backup_item create_symlink
export -f get_script_dir get_dotfiles_root
export -f confirm is_gnome

