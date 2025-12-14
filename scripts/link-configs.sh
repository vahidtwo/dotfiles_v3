#!/usr/bin/env bash

# Link configuration files using GNU Stow
# Usage: ./link-configs.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils.sh"

link_configs() {
    log_info "Linking configuration files..."

    local config_dir="$DOTFILES_ROOT/configs"

    if [ ! -d "$config_dir" ]; then
        log_warning "No configs directory found"
        return
    fi

    # Check if stow is installed
    if ! command_exists stow; then
        log_error "GNU Stow is not installed. Please install it first."
        exit 1
    fi

    cd "$config_dir"

    # Get list of all config directories
    local configs=($(find . -maxdepth 1 -type d -not -name "." -not -name ".." -exec basename {} \;))

    if [ ${#configs[@]} -eq 0 ]; then
        log_warning "No configuration directories found in $config_dir"
        return
    fi

    log_info "Found ${#configs[@]} configuration packages"

    # Stow each config directory
    for config in "${configs[@]}"; do
        log_info "Linking $config..."

        # Check for conflicts
        if stow -n -v -t "$HOME" "$config" 2>&1 | grep -q "WARNING\|ERROR"; then
            log_warning "Conflicts detected for $config. Use --adopt to merge or backup existing files."

            if confirm "Adopt existing files for $config? (This will modify your dotfiles repo)"; then
                stow --adopt -v -t "$HOME" "$config"
                log_success "Adopted and linked: $config"
            elif confirm "Skip $config and continue?"; then
                log_info "Skipped: $config"
                continue
            else
                log_error "Aborted by user"
                exit 1
            fi
        else
            # No conflicts, proceed with stowing
            stow -v -t "$HOME" "$config"
            log_success "Linked: $config"
        fi
    done

    cd - > /dev/null
}

backup_existing_configs() {
    log_info "Backing up existing configuration files..."

    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    ensure_dir "$backup_dir"

    # Common config files that might exist
    local files=(
        ".bashrc"
        ".bash_profile"
        ".zshrc"
        ".gitconfig"
        ".vimrc"
        ".tmux.conf"
    )

    local backed_up=false

    for file in "${files[@]}"; do
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            cp "$HOME/$file" "$backup_dir/"
            log_info "Backed up: $file"
            backed_up=true
        fi
    done

    if [ "$backed_up" = true ]; then
        log_success "Existing configs backed up to: $backup_dir"
    else
        rmdir "$backup_dir"
        log_info "No existing configs to backup"
    fi
}

unlink_configs() {
    log_info "Unlinking configuration files..."

    local config_dir="$DOTFILES_ROOT/configs"

    if [ ! -d "$config_dir" ]; then
        log_warning "No configs directory found"
        return
    fi

    cd "$config_dir"

    local configs=($(find . -maxdepth 1 -type d -not -name "." -not -name ".." -exec basename {} \;))

    for config in "${configs[@]}"; do
        log_info "Unlinking $config..."
        stow -D -v -t "$HOME" "$config" 2>/dev/null || log_warning "Failed to unlink: $config"
    done

    cd - > /dev/null
    log_success "Configs unlinked"
}

main() {
    local action="${1:-link}"

    case "$action" in
        link)
            log_info "Starting config linking..."
            log_info "Dotfiles root: $DOTFILES_ROOT"

            # Offer to backup existing configs
            if confirm "Backup existing config files before linking?"; then
                backup_existing_configs
            fi

            link_configs

            log_success "Configuration linking completed!"
            ;;
        unlink)
            if confirm "Unlink all dotfiles?"; then
                unlink_configs
            else
                log_info "Cancelled"
            fi
            ;;
        *)
            log_error "Unknown action: $action"
            echo "Usage: $0 [link|unlink]"
            exit 1
            ;;
    esac
}

main "$@"

