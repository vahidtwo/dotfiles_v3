#!/usr/bin/env bash

# Backup script - Export all system configurations, packages, and settings
# Usage: ./backup.sh [--packages|--gnome|--configs|--all]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils.sh"

# Backup packages
backup_packages() {
    log_info "Backing up package lists..."

    local pkg_dir="$DOTFILES_ROOT/packages"
    ensure_dir "$pkg_dir"

    local pm="$(detect_package_manager)"

    # System packages
    case "$pm" in
        apt)
            log_info "Exporting APT packages..."
            apt list --installed 2>/dev/null | grep -v "Listing..." | cut -d'/' -f1 > "$pkg_dir/apt.txt"
            dpkg --get-selections | grep -v deinstall | awk '{print $1}' > "$pkg_dir/apt-selections.txt"
            ;;
        dnf)
            log_info "Exporting DNF packages..."
            dnf list installed | awk '{print $1}' | tail -n +2 > "$pkg_dir/dnf.txt"
            ;;
        pacman)
            log_info "Exporting Pacman packages..."
            pacman -Qqe > "$pkg_dir/pacman.txt"
            pacman -Qqm > "$pkg_dir/pacman-aur.txt"
            ;;
    esac

    # Flatpak packages
    if command_exists flatpak; then
        log_info "Exporting Flatpak packages..."
        flatpak list --app --columns=application > "$pkg_dir/flatpak.txt" 2>/dev/null || touch "$pkg_dir/flatpak.txt"
    fi

    # Snap packages
    if command_exists snap; then
        log_info "Exporting Snap packages..."
        snap list | tail -n +2 | awk '{print $1}' > "$pkg_dir/snap.txt" 2>/dev/null || touch "$pkg_dir/snap.txt"
    fi

    # Python packages (global)
    if command_exists pip3; then
        log_info "Exporting pip packages..."
        pip3 list --format=freeze > "$pkg_dir/pip.txt" 2>/dev/null || touch "$pkg_dir/pip.txt"
    fi

    # NPM global packages
    if command_exists npm; then
        log_info "Exporting NPM global packages..."
        npm list -g --depth=0 --json 2>/dev/null | grep -o '"[^"]*":' | grep -v "^\"npm\":" | sed 's/[":]*//g' > "$pkg_dir/npm.txt" || touch "$pkg_dir/npm.txt"
    fi

    # Cargo packages
    if command_exists cargo && [ -f "$HOME/.cargo/bin" ]; then
        log_info "Exporting Cargo packages..."
        ls "$HOME/.cargo/bin" > "$pkg_dir/cargo.txt" 2>/dev/null || touch "$pkg_dir/cargo.txt"
    fi

    log_success "Package lists backed up to $pkg_dir"
}

# Backup GNOME settings
backup_gnome() {
    log_info "Backing up GNOME settings..."

    local gnome_dir="$DOTFILES_ROOT/gnome"
    ensure_dir "$gnome_dir/extensions"
    ensure_dir "$gnome_dir/settings"

    if ! is_gnome; then
        log_warning "Not running GNOME desktop, skipping GNOME backup"
        return
    fi

    # GNOME Shell extensions
    if command_exists gnome-extensions; then
        log_info "Exporting GNOME extensions list..."
        gnome-extensions list > "$gnome_dir/extensions/installed.txt"
        gnome-extensions list --enabled > "$gnome_dir/extensions/enabled.txt"

        # Backup extension settings
        local ext_dir="$HOME/.local/share/gnome-shell/extensions"
        if [ -d "$ext_dir" ]; then
            log_info "Backing up extension configurations..."
            for ext in "$ext_dir"/*; do
                if [ -d "$ext" ]; then
                    ext_name="$(basename "$ext")"
                    # Export dconf settings for this extension
                    dconf dump "/org/gnome/shell/extensions/$ext_name/" > "$gnome_dir/extensions/${ext_name}.dconf" 2>/dev/null || true
                fi
            done
        fi
    fi

    # Dconf settings
    log_info "Exporting dconf settings..."
    dconf dump /org/gnome/ > "$gnome_dir/settings/gnome-settings.dconf"
    dconf dump /org/gtk/ > "$gnome_dir/settings/gtk-settings.dconf"

    # Keybindings
    log_info "Exporting custom keybindings..."
    dconf dump /org/gnome/desktop/wm/keybindings/ > "$gnome_dir/settings/keybindings-wm.dconf"
    dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "$gnome_dir/settings/keybindings-media.dconf"

    # Favorite apps
    gsettings get org.gnome.shell favorite-apps > "$gnome_dir/settings/favorite-apps.txt"

    log_success "GNOME settings backed up to $gnome_dir"
}

# Backup application configs
backup_configs() {
    log_info "Backing up application configurations..."

    local config_dir="$DOTFILES_ROOT/configs"
    ensure_dir "$config_dir"

    # Common config files and directories to backup
    local configs=(
        # Shell
        ".bashrc:bash/.bashrc"
        ".bash_profile:bash/.bash_profile"
        ".zshrc:zsh/.zshrc"
        ".zshenv:zsh/.zshenv"
        ".zprofile:zsh/.zprofile"
        ".oh-my-zsh:zsh/.oh-my-zsh"

        # Git
        ".gitconfig:git/.gitconfig"
        ".gitignore_global:git/.gitignore_global"

        # Vim/Neovim
        ".vimrc:vim/.vimrc"
        ".vim:vim/.vim"
        ".config/nvim:nvim/.config/nvim"
        ".config/lvim:lvim/.config/lvim"
        ".ideavimrc:vim/.ideavimrc"

        # VS Code
        ".config/Code/User/settings.json:vscode/.config/Code/User/settings.json"
        ".config/Code/User/keybindings.json:vscode/.config/Code/User/keybindings.json"
        ".config/Code/User/snippets:vscode/.config/Code/User/snippets"

        # JetBrains IDEs (PyCharm, IntelliJ, etc.)
        ".config/JetBrains:jetbrains/.config/JetBrains"
        ".ideavimrc:jetbrains/.ideavimrc"
        "pycharm-settings:jetbrains/pycharm-settings"

        # Oh-My-Posh
        ".oh-my-posh.conf.toml:oh-my-posh/.oh-my-posh.conf.toml"
        ".config/ohmyposh:oh-my-posh/.config/ohmyposh"

        # Terminal emulators
        ".config/alacritty:alacritty/.config/alacritty"
        ".config/kitty:kitty/.config/kitty"
        ".config/terminator:terminator/.config/terminator"

        # Other apps
        ".config/gtk-3.0:gtk-3.0/.config/gtk-3.0"
        ".config/gtk-4.0:gtk-4.0/.config/gtk-4.0"
        ".tmux.conf:tmux/.tmux.conf"
        ".config/htop:htop/.config/htop"
        ".config/ranger:ranger/.config/ranger"
        ".config/btop:btop/.config/btop"
        ".config/atuin:atuin/.config/atuin"
    )

    for config in "${configs[@]}"; do
        IFS=':' read -r source dest <<< "$config"
        source_path="$HOME/$source"
        dest_path="$config_dir/$dest"

        if [ -e "$source_path" ]; then
            backup_item "$source_path" "$dest_path"
        fi
    done

    # Export VS Code extensions list
    if command_exists code; then
        log_info "Exporting VS Code extensions..."
        ensure_dir "$config_dir/vscode"
        code --list-extensions > "$config_dir/vscode/extensions.txt"
    fi

    # Export Cursor extensions list (if different from VS Code)
    if command_exists cursor; then
        log_info "Exporting Cursor extensions..."
        ensure_dir "$config_dir/cursor"
        cursor --list-extensions > "$config_dir/cursor/extensions.txt" 2>/dev/null || true
    fi

    # Export JetBrains plugins list
    if [ -d "$HOME/.config/JetBrains" ]; then
        log_info "Exporting JetBrains plugins..."
        ensure_dir "$config_dir/jetbrains"

        # Find the latest PyCharm version directory
        local pycharm_dir=$(find "$HOME/.config/JetBrains" -maxdepth 1 -type d -name "PyCharm*" | sort -V | tail -1)
        if [ -n "$pycharm_dir" ] && [ -d "$pycharm_dir/plugins" ]; then
            ls "$pycharm_dir/plugins" > "$config_dir/jetbrains/pycharm-plugins.txt" 2>/dev/null || true
        fi

        # Find the latest IntelliJ IDEA version directory
        local idea_dir=$(find "$HOME/.config/JetBrains" -maxdepth 1 -type d -name "IntelliJIdea*" | sort -V | tail -1)
        if [ -n "$idea_dir" ] && [ -d "$idea_dir/plugins" ]; then
            ls "$idea_dir/plugins" > "$config_dir/jetbrains/idea-plugins.txt" 2>/dev/null || true
        fi
    fi

    # Export Oh-My-Posh themes and config
    if command_exists oh-my-posh; then
        log_info "Exporting Oh-My-Posh configuration..."
        ensure_dir "$config_dir/oh-my-posh"
        oh-my-posh version > "$config_dir/oh-my-posh/version.txt" 2>/dev/null || true

        # Note which theme is being used (if we can extract it from config)
        if [ -f "$HOME/.oh-my-posh.conf.toml" ]; then
            grep -i "theme" "$HOME/.oh-my-posh.conf.toml" > "$config_dir/oh-my-posh/active-theme.txt" 2>/dev/null || true
        fi
    fi

    log_success "Application configs backed up to $config_dir"
}

# Backup fonts
backup_fonts() {
    log_info "Backing up custom fonts..."

    local fonts_dir="$DOTFILES_ROOT/fonts"
    ensure_dir "$fonts_dir"

    if [ -d "$HOME/.local/share/fonts" ]; then
        # Create font list for reference
        find "$HOME/.local/share/fonts" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.woff" -o -name "*.woff2" \) > "$fonts_dir/font-list.txt"

        # Copy actual font files (preserving directory structure)
        log_info "Copying font files..."
        rsync -av --include='*.ttf' --include='*.otf' --include='*.woff' --include='*.woff2' \
              --include='*/' --exclude='*' \
              "$HOME/.local/share/fonts/" "$fonts_dir/files/" 2>/dev/null || {
            # Fallback if rsync fails - use cp
            mkdir -p "$fonts_dir/files"
            cp -r "$HOME/.local/share/fonts"/* "$fonts_dir/files/" 2>/dev/null || true
        }

        local font_count=$(cat "$fonts_dir/font-list.txt" | wc -l)
        local font_size=$(du -sh "$fonts_dir/files" 2>/dev/null | cut -f1)
        log_success "Backed up $font_count fonts (~$font_size)"
    else
        log_warning "No custom fonts directory found at ~/.local/share/fonts"
    fi
}

# Main backup function
main() {
    log_info "Starting dotfiles backup..."
    log_info "Dotfiles root: $DOTFILES_ROOT"

    local backup_all=true
    local backup_packages_only=false
    local backup_gnome_only=false
    local backup_configs_only=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --packages)
                backup_all=false
                backup_packages_only=true
                shift
                ;;
            --gnome)
                backup_all=false
                backup_gnome_only=true
                shift
                ;;
            --configs)
                backup_all=false
                backup_configs_only=true
                shift
                ;;
            --all)
                backup_all=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Usage: $0 [--packages|--gnome|--configs|--all]"
                exit 1
                ;;
        esac
    done

    # Execute backups
    if [ "$backup_all" = true ] || [ "$backup_packages_only" = true ]; then
        backup_packages
    fi

    if [ "$backup_all" = true ] || [ "$backup_gnome_only" = true ]; then
        backup_gnome
    fi

    if [ "$backup_all" = true ] || [ "$backup_configs_only" = true ]; then
        backup_configs
        backup_fonts
    fi

    log_success "Backup completed successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. Review changes: cd $DOTFILES_ROOT && git status"
    echo "  2. Commit changes: git add . && git commit -m 'Update dotfiles'"
    echo "  3. Push to remote: git push"
}

main "$@"

