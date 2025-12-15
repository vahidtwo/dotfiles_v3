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
    local ext_list_file="$gnome_dir/extensions/installed.txt"
    local enabled_file="$gnome_dir/extensions/enabled.txt"

    if ! is_gnome; then
        log_warning "Not running GNOME desktop, skipping GNOME setup"
        return
    fi

    # Check for extension lists
    local has_installed_list=false
    local has_enabled_list=false

    if [ -f "$ext_list_file" ]; then
        has_installed_list=true
    fi

    if [ -f "$enabled_file" ]; then
        has_enabled_list=true
    fi

    if [ "$has_installed_list" = false ] && [ "$has_enabled_list" = false ]; then
        log_warning "No extensions list found. Creating from currently installed extensions..."

        # Create the lists from currently installed extensions
        if command_exists gnome-extensions; then
            mkdir -p "$gnome_dir/extensions"
            gnome-extensions list > "$ext_list_file" 2>/dev/null || true
            gnome-extensions list --enabled > "$enabled_file" 2>/dev/null || true

            if [ -f "$ext_list_file" ]; then
                log_success "Created extension lists from your current setup"
            fi
        fi
        return
    fi

    # Install gnome-shell-extension-installer if not present
    if ! command_exists gnome-extensions; then
        log_error "gnome-extensions command not found. Please install gnome-shell package"
        return 1
    fi

    # Suggest Extension Manager
    log_info "For easy extension installation, we recommend Extension Manager:"
    echo ""
    echo "  Install with: flatpak install flathub com.mattjakeman.ExtensionManager"
    echo "  Or: sudo pacman -S extension-manager (Arch)"
    echo "  Or: sudo dnf install gnome-extensions-app (Fedora)"
    echo ""

    if confirm "Install Extension Manager now?"; then
        if command_exists flatpak; then
            log_info "Installing Extension Manager via Flatpak..."
            flatpak install -y flathub com.mattjakeman.ExtensionManager 2>/dev/null || log_warning "Failed to install Extension Manager"
        else
            local pm="$(detect_package_manager)"
            case "$pm" in
                pacman)
                    log_info "Installing gnome-shell-extensions..."
                    sudo pacman -S --needed --noconfirm gnome-shell-extensions 2>/dev/null || true
                    if command_exists yay; then
                        log_info "Installing extension-manager from AUR..."
                        yay -S --needed --noconfirm extension-manager 2>/dev/null || true
                    fi
                    ;;
                dnf)
                    log_info "Installing gnome-extensions-app..."
                    sudo dnf install -y gnome-extensions-app 2>/dev/null || true
                    ;;
                apt)
                    log_info "Installing gnome-shell-extension-manager..."
                    sudo apt install -y gnome-shell-extension-manager 2>/dev/null || true
                    ;;
            esac
        fi
    fi

    # List extensions to install manually
    echo ""
    log_info "Extensions that should be installed:"
    echo ""

    local list_file="${enabled_file}"
    if [ ! -f "$list_file" ]; then
        list_file="${ext_list_file}"
    fi

    if [ -f "$list_file" ]; then
        while IFS= read -r extension_uuid; do
            if [[ -n "$extension_uuid" ]] && [[ ! "$extension_uuid" = "#"* ]]; then
                # Check if already installed
                if gnome-extensions list 2>/dev/null | grep -q "^${extension_uuid}$"; then
                    echo "  ✓ $extension_uuid (already installed)"
                else
                    echo "  ✗ $extension_uuid (needs installation)"
                fi
            fi
        done < "$list_file"
    fi

    echo ""
    log_info "To install missing extensions:"
    echo "  1. Open Extension Manager (if installed)"
    echo "  2. Or visit: https://extensions.gnome.org"
    echo "  3. Search for each extension by its UUID"
    echo ""

    if confirm "Open extensions list in a text file for reference?"; then
        if [ -f "$list_file" ]; then
            echo ""
            echo "=== Extensions List ==="
            cat "$list_file"
            echo "======================="
        fi
    fi
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
        log_warning "No enabled extensions list found at: $ext_file"
        return
    fi

    local enabled_count=0
    local failed_count=0
    local not_installed=()

    while IFS= read -r extension; do
        if [ -n "$extension" ] && [[ ! "$extension" = "#"* ]]; then
            # Check if extension is installed
            if gnome-extensions list 2>/dev/null | grep -q "^${extension}$"; then
                if gnome-extensions enable "$extension" 2>/dev/null; then
                    log_success "Enabled: $extension"
                    ((enabled_count++))
                else
                    log_warning "Could not enable: $extension"
                    ((failed_count++))
                fi
            else
                not_installed+=("$extension")
            fi
        fi
    done < "$ext_file"

    echo ""
    if [ ${#not_installed[@]} -gt 0 ]; then
        log_warning "The following extensions are not installed yet:"
        for ext in "${not_installed[@]}"; do
            echo "  ✗ $ext"
        done
        echo ""
        log_info "To install these extensions:"
        echo "  1. Use Extension Manager (recommended):"
        echo "     flatpak install flathub com.mattjakeman.ExtensionManager"
        echo "  2. Or visit: https://extensions.gnome.org"
        echo "  3. After installing, run this script again to enable them"
        echo ""
    fi

    log_success "Enabled $enabled_count extension(s)"
    if [ $failed_count -gt 0 ]; then
        log_warning "$failed_count extension(s) failed to enable"
    fi
    if [ ${#not_installed[@]} -gt 0 ]; then
        log_warning "${#not_installed[@]} extension(s) not installed"
    fi
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

    echo ""
    log_info "This will restore GNOME settings and configure extensions."
    echo ""

    # Check if we should install extensions first
    if [ -f "$DOTFILES_ROOT/gnome/extensions/installed.txt" ]; then
        local installed_count=$(gnome-extensions list 2>/dev/null | wc -l)
        local needed_count=$(grep -v "^#" "$DOTFILES_ROOT/gnome/extensions/installed.txt" | grep -v "^$" | wc -l)

        if [ $installed_count -lt $needed_count ]; then
            log_warning "Some extensions are not installed yet ($installed_count of $needed_count)"
            echo ""
            if confirm "Would you like to install missing extensions now?"; then
                bash "$SCRIPT_DIR/install-gnome-extensions.sh"
                echo ""
            fi
        fi
    fi

    # Restore settings
    if confirm "Restore GNOME desktop settings?"; then
        restore_gnome_settings
    fi

    echo ""
    if confirm "Restore extension settings?"; then
        restore_extension_settings
    fi

    echo ""
    if confirm "Enable extensions?"; then
        enable_extensions
    fi

    log_success "GNOME setup completed!"
    echo ""
    log_info "You may need to:"
    echo "  1. Log out and log back in (or press Alt+F2, type 'r', press Enter)"
    echo "  2. Manually install any missing extensions from extensions.gnome.org"
    echo "  3. Use Extension Manager for easier extension management"
    echo ""
    log_info "To install missing extensions, run:"
    echo "  ./scripts/install-gnome-extensions.sh"
}

main "$@"

