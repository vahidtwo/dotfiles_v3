#!/usr/bin/env bash

# Install PyCharm and restore settings
# Usage: ./install-pycharm.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils.sh"

install_pycharm_community() {
    log_info "Installing PyCharm Community Edition..."

    local pm="$(detect_package_manager)"

    case "$pm" in
        apt)
            log_info "Installing PyCharm via snap..."
            if command_exists snap; then
                sudo snap install pycharm-community --classic
            else
                log_warning "Snap not available. Install PyCharm manually from:"
                echo "  https://www.jetbrains.com/pycharm/download/"
                return 1
            fi
            ;;
        dnf)
            log_info "Installing PyCharm via snap..."
            if command_exists snap; then
                sudo snap install pycharm-community --classic
            else
                log_warning "Snap not available. Install PyCharm manually from:"
                echo "  https://www.jetbrains.com/pycharm/download/"
                return 1
            fi
            ;;
        pacman)
            log_info "Installing PyCharm Community from AUR..."
            if command_exists yay; then
                yay -S --needed --noconfirm pycharm-community-edition
            else
                log_warning "yay not available. Install PyCharm manually:"
                echo "  yay -S pycharm-community-edition"
                echo "  OR download from: https://www.jetbrains.com/pycharm/download/"
                return 1
            fi
            ;;
        *)
            log_error "Unknown package manager. Install PyCharm manually from:"
            echo "  https://www.jetbrains.com/pycharm/download/"
            return 1
            ;;
    esac

    log_success "PyCharm installed successfully"
}

install_pycharm_professional() {
    log_info "Installing PyCharm Professional Edition..."

    local pm="$(detect_package_manager)"

    case "$pm" in
        apt|dnf)
            log_info "Installing PyCharm Professional via snap..."
            if command_exists snap; then
                sudo snap install pycharm-professional --classic
            else
                log_warning "Snap not available. Install PyCharm manually from:"
                echo "  https://www.jetbrains.com/pycharm/download/"
                return 1
            fi
            ;;
        pacman)
            log_info "Installing PyCharm Professional from AUR..."
            if command_exists yay; then
                yay -S --needed --noconfirm pycharm-professional
            else
                log_warning "yay not available. Install PyCharm manually:"
                echo "  yay -S pycharm-professional"
                echo "  OR download from: https://www.jetbrains.com/pycharm/download/"
                return 1
            fi
            ;;
        *)
            log_error "Unknown package manager. Install PyCharm manually from:"
            echo "  https://www.jetbrains.com/pycharm/download/"
            return 1
            ;;
    esac

    log_success "PyCharm Professional installed successfully"
}

restore_pycharm_settings() {
    log_info "Restoring PyCharm settings..."

    local pycharm_config_dir="$DOTFILES_ROOT/configs/jetbrains/pycharm-settings"

    if [ ! -d "$pycharm_config_dir" ]; then
        log_warning "No PyCharm settings found to restore"
        return
    fi

    # Find PyCharm config directory
    local pycharm_user_config=""

    # Check common locations for PyCharm config
    for config_dir in ~/.config/JetBrains/PyCharmCE* ~/.config/JetBrains/PyCharm* ~/.PyCharmCE* ~/.PyCharm*; do
        if [ -d "$config_dir" ]; then
            pycharm_user_config="$config_dir"
            break
        fi
    done

    if [ -z "$pycharm_user_config" ]; then
        log_warning "PyCharm config directory not found. Start PyCharm once, then run this script again."
        log_info "Settings are backed up in: $pycharm_config_dir"
        return
    fi

    log_info "Found PyCharm config: $pycharm_user_config"

    # Restore settings
    if [ -d "$pycharm_config_dir/codestyles" ]; then
        cp -r "$pycharm_config_dir/codestyles" "$pycharm_user_config/" 2>/dev/null || true
        log_success "Restored code styles"
    fi

    if [ -d "$pycharm_config_dir/colors" ]; then
        cp -r "$pycharm_config_dir/colors" "$pycharm_user_config/" 2>/dev/null || true
        log_success "Restored color schemes"
    fi

    if [ -d "$pycharm_config_dir/keymaps" ]; then
        cp -r "$pycharm_config_dir/keymaps" "$pycharm_user_config/" 2>/dev/null || true
        log_success "Restored keymaps"
    fi

    if [ -d "$pycharm_config_dir/inspection" ]; then
        cp -r "$pycharm_config_dir/inspection" "$pycharm_user_config/" 2>/dev/null || true
        log_success "Restored inspection profiles"
    fi

    if [ -d "$pycharm_config_dir/options" ]; then
        cp -r "$pycharm_config_dir/options" "$pycharm_user_config/" 2>/dev/null || true
        log_success "Restored options"
    fi

    log_success "PyCharm settings restored"
    log_info "Restart PyCharm for changes to take effect"
}

main() {
    log_info "Starting PyCharm installation..."

    if ! confirm "Install PyCharm?"; then
        log_info "Skipping PyCharm installation"
        exit 0
    fi

    echo ""
    log_info "Which version would you like to install?"
    echo "  1) PyCharm Community Edition (Free)"
    echo "  2) PyCharm Professional Edition (Requires license)"
    echo "  3) Skip installation"
    echo ""
    read -p "Enter choice [1-3]: " choice

    case $choice in
        1)
            install_pycharm_community
            ;;
        2)
            install_pycharm_professional
            ;;
        3)
            log_info "Skipping PyCharm installation"
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac

    echo ""
    if confirm "Restore PyCharm settings from backup?"; then
        restore_pycharm_settings
    fi

    log_success "PyCharm setup completed!"
}

main "$@"

