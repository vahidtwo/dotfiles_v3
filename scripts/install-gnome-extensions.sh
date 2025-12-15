#!/usr/bin/env bash

# Install GNOME extensions from a list
# Usage: ./install-gnome-extensions.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils.sh"

# Extension installation function using gext CLI tool
install_extension_with_gext() {
    local extension_uuid="$1"

    if ! command_exists gext; then
        return 1
    fi

    log_info "Installing $extension_uuid..."
    gext install "$extension_uuid" 2>/dev/null || return 1
    return 0
}

# Install gext if needed
install_gext() {
    if command_exists gext; then
        log_success "gext is already installed"
        return 0
    fi

    log_info "Installing gext (GNOME Extension CLI installer)..."

    if command_exists pipx; then
        pipx install gnome-extensions-cli || return 1
    elif command_exists pip; then
        pip install --user gnome-extensions-cli || return 1
    else
        log_error "Neither pipx nor pip is available. Cannot install gext."
        return 1
    fi

    # Add to PATH if needed
    if ! command_exists gext; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    if command_exists gext; then
        log_success "gext installed successfully"
        return 0
    else
        log_error "Failed to install gext"
        return 1
    fi
}

# Install Extension Manager
install_extension_manager() {
    log_info "Installing Extension Manager..."

    if command_exists flatpak; then
        if flatpak list | grep -q "com.mattjakeman.ExtensionManager"; then
            log_success "Extension Manager is already installed"
            return 0
        fi

        log_info "Installing Extension Manager via Flatpak..."
        flatpak install -y flathub com.mattjakeman.ExtensionManager 2>/dev/null || {
            log_warning "Failed to install via Flatpak"
            return 1
        }
        log_success "Extension Manager installed"
        return 0
    fi

    local pm="$(detect_package_manager)"
    case "$pm" in
        pacman)
            if pacman -Q extension-manager &>/dev/null; then
                log_success "Extension Manager is already installed"
                return 0
            fi

            if command_exists yay; then
                log_info "Installing Extension Manager from AUR..."
                yay -S --needed --noconfirm extension-manager || {
                    log_warning "Failed to install from AUR"
                    return 1
                }
                log_success "Extension Manager installed"
                return 0
            fi
            ;;
        dnf)
            log_info "Installing gnome-extensions-app..."
            sudo dnf install -y gnome-extensions-app || return 1
            ;;
        apt)
            log_info "Installing gnome-shell-extension-manager..."
            sudo apt install -y gnome-shell-extension-manager || return 1
            ;;
    esac
}

# Main installation function
install_extensions_from_list() {
    local ext_file="$DOTFILES_ROOT/gnome/extensions/installed.txt"

    if [ ! -f "$ext_file" ]; then
        log_error "Extension list not found: $ext_file"
        return 1
    fi

    log_info "Reading extension list from: $ext_file"
    echo ""

    local total=0
    local installed=0
    local skipped=0
    local failed=0

    # Count total extensions
    while IFS= read -r extension; do
        if [[ -n "$extension" ]] && [[ ! "$extension" = "#"* ]]; then
            ((total++))
        fi
    done < "$ext_file"

    log_info "Found $total extensions to process"
    echo ""

    # Process each extension
    while IFS= read -r extension; do
        if [[ -z "$extension" ]] || [[ "$extension" = "#"* ]]; then
            continue
        fi

        # Check if already installed
        if gnome-extensions list 2>/dev/null | grep -q "^${extension}$"; then
            echo "  ✓ $extension (already installed)"
            ((skipped++))
            continue
        fi

        # Try to install
        if install_extension_with_gext "$extension"; then
            log_success "Installed: $extension"
            ((installed++))
        else
            echo "  ✗ $extension (installation failed)"
            ((failed++))
        fi

    done < "$ext_file"

    echo ""
    echo "═══════════════════════════════════════"
    log_info "Installation Summary:"
    echo "  Total extensions: $total"
    echo "  Already installed: $skipped"
    echo "  Newly installed: $installed"
    echo "  Failed: $failed"
    echo "═══════════════════════════════════════"
    echo ""

    if [ $failed -gt 0 ]; then
        log_warning "Some extensions failed to install."
        log_info "You can install them manually using Extension Manager or from:"
        echo "  https://extensions.gnome.org"
        return 1
    fi

    return 0
}

main() {
    if ! is_gnome; then
        log_error "This script requires GNOME desktop environment"
        exit 1
    fi

    if ! command_exists gnome-extensions; then
        log_error "gnome-extensions command not found. Please install gnome-shell package first."
        exit 1
    fi

    echo ""
    log_info "GNOME Extensions Installation Tool"
    echo "═══════════════════════════════════════"
    echo ""

    # Offer installation methods
    echo "Choose installation method:"
    echo "  1) Automatic installation using gext (recommended)"
    echo "  2) Install Extension Manager GUI only"
    echo "  3) Show list for manual installation"
    echo "  4) Exit"
    echo ""
    read -p "Enter choice [1-4]: " choice

    case "$choice" in
        1)
            echo ""
            log_info "Installing extensions automatically..."

            # Install gext if needed
            if ! install_gext; then
                log_error "Failed to install gext. Falling back to Extension Manager."
                install_extension_manager
                exit 1
            fi

            # Install extensions
            install_extensions_from_list

            # Offer to enable them
            echo ""
            if confirm "Enable all installed extensions now?"; then
                bash "$SCRIPT_DIR/setup-gnome.sh"
            fi
            ;;
        2)
            install_extension_manager
            log_info "You can now open Extension Manager to install extensions manually."
            ;;
        3)
            log_info "Extensions to install:"
            echo ""
            cat "$DOTFILES_ROOT/gnome/extensions/installed.txt"
            echo ""
            log_info "Visit: https://extensions.gnome.org"
            ;;
        4)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac

    log_success "Done!"
}

main "$@"

