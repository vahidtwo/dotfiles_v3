#!/usr/bin/env bash

# Restore GNOME settings and extensions
# Usage: ./setup-gnome.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils.sh"

install_gnome_extensions() {
    log_info "Setting up GNOME extensions..."

    local gnome_dir="$DOTFILES_ROOT/gnome"

    if ! is_gnome; then
        log_warning "Not running GNOME desktop, skipping GNOME setup"
        return
    fi

    if [ ! -f "$gnome_dir/extensions/installed.txt" ]; then
        log_warning "No extensions list found"
        return
    fi

    # Install gnome-shell-extension-installer if not present
    if ! command_exists gnome-extensions; then
        log_error "gnome-extensions command not found. Please install gnome-shell-extensions package"
        return 1
    fi

    # Read extension UUIDs from the list
    log_info "Installing GNOME extensions..."
    log_warning "Note: Extensions need to be installed manually from extensions.gnome.org"
    log_info "Or use a tool like gnome-shell-extension-installer"

    # Try to install extensions using gnome-extensions if possible
    # Most reliable way is to list them for manual installation
    cat "$gnome_dir/extensions/installed.txt"

    # Install extension manager if available
    local pm="$(detect_package_manager)"
    case "$pm" in
        apt)
            if ! dpkg -l | grep -q gnome-shell-extension-manager; then
                log_info "Consider installing Extension Manager: sudo apt install gnome-shell-extension-manager"
            fi
            ;;
        dnf)
            log_info "Consider installing Extension Manager from Flathub"
            ;;
    esac
}

restore_gnome_settings() {
    log_info "Restoring GNOME settings..."

    local gnome_dir="$DOTFILES_ROOT/gnome/settings"

    if ! is_gnome; then
        log_warning "Not running GNOME desktop, skipping settings restore"
        return
    fi

    if [ ! -d "$gnome_dir" ]; then
        log_warning "No GNOME settings found"
        return
    fi

    # Restore dconf settings
    if [ -f "$gnome_dir/gnome-settings.dconf" ]; then
        log_info "Restoring GNOME desktop settings..."
        dconf load /org/gnome/ < "$gnome_dir/gnome-settings.dconf"
    fi

    if [ -f "$gnome_dir/gtk-settings.dconf" ]; then
        log_info "Restoring GTK settings..."
        dconf load /org/gtk/ < "$gnome_dir/gtk-settings.dconf"
    fi

    # Restore keybindings
    if [ -f "$gnome_dir/keybindings-wm.dconf" ]; then
        log_info "Restoring window manager keybindings..."
        dconf load /org/gnome/desktop/wm/keybindings/ < "$gnome_dir/keybindings-wm.dconf"
    fi

    if [ -f "$gnome_dir/keybindings-media.dconf" ]; then
        log_info "Restoring media keybindings..."
        dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$gnome_dir/keybindings-media.dconf"
    fi

    # Restore favorite apps
    if [ -f "$gnome_dir/favorite-apps.txt" ]; then
        log_info "Restoring favorite apps..."
        favorite_apps=$(cat "$gnome_dir/favorite-apps.txt")
        gsettings set org.gnome.shell favorite-apps "$favorite_apps"
    fi

    log_success "GNOME settings restored"
}

restore_extension_settings() {
    log_info "Restoring extension settings..."

    local ext_dir="$DOTFILES_ROOT/gnome/extensions"

    if [ ! -d "$ext_dir" ]; then
        return
    fi

    # Restore individual extension settings
    for dconf_file in "$ext_dir"/*.dconf; do
        if [ -f "$dconf_file" ]; then
            ext_name=$(basename "$dconf_file" .dconf)
            if [ "$ext_name" != "installed" ] && [ "$ext_name" != "enabled" ]; then
                log_info "Restoring settings for $ext_name..."
                dconf load "/org/gnome/shell/extensions/$ext_name/" < "$dconf_file" 2>/dev/null || true
            fi
        fi
    done
}

enable_extensions() {
    log_info "Enabling GNOME extensions..."

    local ext_file="$DOTFILES_ROOT/gnome/extensions/enabled.txt"

    if [ ! -f "$ext_file" ]; then
        return
    fi

    while IFS= read -r extension; do
        if [ -n "$extension" ]; then
            gnome-extensions enable "$extension" 2>/dev/null || log_warning "Could not enable: $extension"
        fi
    done < "$ext_file"

    log_success "Extensions enabled"
}

install_themes() {
    log_info "Setting up themes..."

    # Common theme installations
    local pm="$(detect_package_manager)"

    case "$pm" in
        apt)
            log_info "You may want to install themes manually:"
            echo "  - Adwaita (default)"
            echo "  - gnome-themes-extra"
            echo "  - arc-theme"
            echo "  - papirus-icon-theme"
            ;;
        dnf)
            log_info "You may want to install themes manually:"
            echo "  - gnome-themes-extra"
            echo "  - arc-theme"
            echo "  - papirus-icon-theme"
            ;;
    esac
}

main() {
    log_info "Starting GNOME setup..."
    log_info "Dotfiles root: $DOTFILES_ROOT"

    if ! is_gnome; then
        log_error "This script is for GNOME desktop environment only"
        exit 1
    fi

    # Restore settings
    restore_gnome_settings
    install_gnome_extensions
    restore_extension_settings
    enable_extensions
    install_themes

    log_success "GNOME setup completed!"
    echo ""
    log_info "You may need to:"
    echo "  1. Log out and log back in for some changes to take effect"
    echo "  2. Manually install extensions from extensions.gnome.org"
    echo "  3. Install themes and icon packs separately"
}

main "$@"

