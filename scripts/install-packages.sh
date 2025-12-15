#!/usr/bin/env bash

# Install packages from backup lists
# Usage: ./install-packages.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils.sh"

install_system_packages() {
    local pkg_dir="$DOTFILES_ROOT/packages"
    local pm="$(detect_package_manager)"

    log_info "Installing system packages..."

    case "$pm" in
        apt)
            if [ -f "$pkg_dir/apt.txt" ]; then
                log_info "Updating package database..."
                sudo apt update

                log_info "Installing APT packages..."
                # Filter out packages that might not exist on this system
                while IFS= read -r package; do
                    if [ -n "$package" ]; then
                        sudo apt install -y "$package" 2>/dev/null || log_warning "Failed to install: $package"
                    fi
                done < "$pkg_dir/apt.txt"
            fi
            ;;
        dnf)
            if [ -f "$pkg_dir/dnf.txt" ]; then
                log_info "Installing DNF packages..."
                while IFS= read -r package; do
                    if [ -n "$package" ]; then
                        sudo dnf install -y "$package" 2>/dev/null || log_warning "Failed to install: $package"
                    fi
                done < "$pkg_dir/dnf.txt"
            fi
            ;;
        pacman)
            if [ -f "$pkg_dir/pacman.txt" ]; then
                log_info "Updating package database..."
                sudo pacman -Sy

                log_info "Installing Pacman packages..."
                # Read packages line by line and install
                while IFS= read -r package; do
                    if [[ -n "$package" ]] && [[ ! "$package" = "#"* ]]; then
                        sudo pacman -S --needed --noconfirm "$package" 2>/dev/null || log_warning "Failed to install: $package"
                    fi
                done < "$pkg_dir/pacman.txt"
            fi
            ;;
        *)
            log_error "Unknown package manager: $pm"
            return 1
            ;;
    esac

    log_success "System packages installation completed"
}

install_aur_packages() {
    local pkg_dir="$DOTFILES_ROOT/packages"

    # Only run on Arch-based systems
    local pm="$(detect_package_manager)"
    if [ "$pm" != "pacman" ]; then
        return
    fi

    if ! command_exists yay; then
        log_warning "yay not installed, skipping AUR packages"
        return
    fi

    if [ ! -f "$pkg_dir/aur.txt" ]; then
        log_info "No AUR packages to install"
        return
    fi

    log_info "Installing AUR packages..."

    while IFS= read -r package; do
        if [[ -n "$package" ]] && [[ ! "$package" = "#"* ]]; then
            yay -S --needed --noconfirm "$package" 2>/dev/null || log_warning "Failed to install: $package"
        fi
    done < "$pkg_dir/aur.txt"

    log_success "AUR packages installation completed"
}

install_flatpak_packages() {
    local pkg_dir="$DOTFILES_ROOT/packages"

    if ! command_exists flatpak; then
        log_warning "Flatpak not installed, skipping Flatpak packages"
        return
    fi

    if [ ! -f "$pkg_dir/flatpak.txt" ]; then
        log_info "No Flatpak packages to install"
        return
    fi

    log_info "Installing Flatpak packages..."

    # Add Flathub repository if not already added
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    while IFS= read -r package; do
        if [ -n "$package" ]; then
            flatpak install -y flathub "$package" 2>/dev/null || log_warning "Failed to install: $package"
        fi
    done < "$pkg_dir/flatpak.txt"

    log_success "Flatpak packages installation completed"
}

install_snap_packages() {
    local pkg_dir="$DOTFILES_ROOT/packages"

    if ! command_exists snap; then
        log_warning "Snap not installed, skipping Snap packages"
        return
    fi

    if [ ! -f "$pkg_dir/snap.txt" ]; then
        log_info "No Snap packages to install"
        return
    fi

    log_info "Installing Snap packages..."

    while IFS= read -r package; do
        if [ -n "$package" ] && [ "$package" != "snapd" ]; then
            sudo snap install "$package" 2>/dev/null || log_warning "Failed to install: $package"
        fi
    done < "$pkg_dir/snap.txt"

    log_success "Snap packages installation completed"
}

install_pip_packages() {
    local pkg_dir="$DOTFILES_ROOT/packages"

    if ! command_exists pip3; then
        log_warning "pip3 not installed, skipping Python packages"
        return
    fi

    if [ ! -f "$pkg_dir/pip.txt" ]; then
        log_info "No pip packages to install"
        return
    fi

    log_info "Installing pip packages..."

    # Install packages using the requirements file format
    pip3 install --user -r "$pkg_dir/pip.txt" 2>/dev/null || log_warning "Some pip packages failed to install"

    log_success "pip packages installation completed"
}

install_npm_packages() {
    local pkg_dir="$DOTFILES_ROOT/packages"

    if ! command_exists npm; then
        log_warning "npm not installed, skipping NPM packages"
        return
    fi

    if [ ! -f "$pkg_dir/npm.txt" ]; then
        log_info "No NPM packages to install"
        return
    fi

    log_info "Installing NPM global packages..."

    while IFS= read -r package; do
        if [ -n "$package" ]; then
            sudo npm install -g "$package" 2>/dev/null || log_warning "Failed to install: $package"
        fi
    done < "$pkg_dir/npm.txt"

    log_success "NPM packages installation completed"
}

install_vscode_extensions() {
    local config_dir="$DOTFILES_ROOT/configs/vscode"

    if ! command_exists code; then
        log_warning "VS Code not installed, skipping extensions"
        return
    fi

    if [ ! -f "$config_dir/extensions.txt" ]; then
        log_info "No VS Code extensions list found"
        return
    fi

    log_info "Installing VS Code extensions..."

    while IFS= read -r extension; do
        if [ -n "$extension" ]; then
            code --install-extension "$extension" 2>/dev/null || log_warning "Failed to install: $extension"
        fi
    done < "$config_dir/extensions.txt"

    log_success "VS Code extensions installation completed"
}

install_prerequisites() {
    log_info "Installing prerequisites..."

    # Install GNU Stow
    if ! command_exists stow; then
        log_info "Installing GNU Stow..."
        install_package stow
    fi

    # Install git if not present
    if ! command_exists git; then
        log_info "Installing git..."
        install_package git
    fi

    # Install yay for AUR packages (Arch Linux)
    local pm="$(detect_package_manager)"
    if [ "$pm" = "pacman" ] && ! command_exists yay; then
        log_info "Installing yay (AUR helper)..."
        log_info "This is required for AUR packages installation"

        if confirm "Install yay now?"; then
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -si --noconfirm
            cd -
            rm -rf "$temp_dir"
            log_success "yay installed successfully"
        else
            log_warning "Skipping yay installation. AUR packages won't be installed."
        fi
    fi

    log_success "Prerequisites installed"
}

main() {
    log_info "Starting package installation..."
    log_info "Dotfiles root: $DOTFILES_ROOT"

    if [ ! -d "$DOTFILES_ROOT/packages" ]; then
        log_error "No packages directory found. Run backup.sh first."
        exit 1
    fi

    # Install prerequisites first
    install_prerequisites

    # Ask for confirmation
    echo ""
    log_warning "This will install all packages from your backup."
    if ! confirm "Do you want to continue?"; then
        log_info "Installation cancelled"
        exit 0
    fi

    # Install packages
    install_system_packages
    install_aur_packages
    install_flatpak_packages
    install_snap_packages
    install_pip_packages
    install_npm_packages
    install_vscode_extensions

    log_success "All packages installed successfully!"
}

main "$@"

