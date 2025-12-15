#!/usr/bin/env bash

# Quick Fix Script - Addresses common installation issues
# Run this if you've already installed but some components didn't work

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/utils.sh"

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║     Dotfiles Quick Fix Script                  ║"
echo "║     Fix common installation issues             ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Check if on Arch Linux
if [ "$(detect_package_manager)" != "pacman" ]; then
    log_error "This quick fix script is designed for Arch Linux"
    exit 1
fi

# Issue 1: Install yay and AUR packages
fix_aur_packages() {
    log_info "Checking AUR package installation..."

    if ! command_exists yay; then
        log_warning "yay not found. Installing..."

        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd -
        rm -rf "$temp_dir"
        log_success "yay installed"
    else
        log_success "yay is already installed"
    fi

    if [ -f "$DOTFILES_ROOT/packages/pacman-aur.txt" ]; then
        if confirm "Install AUR packages from pacman-aur.txt?"; then
            log_info "Installing AUR packages..."
            yay -S --needed --noconfirm - < "$DOTFILES_ROOT/packages/pacman-aur.txt"
            log_success "AUR packages installed"
        fi
    fi
}

# Issue 2: Fix zsh default shell
fix_zsh_shell() {
    log_info "Checking default shell..."

    if ! command_exists zsh; then
        log_warning "Zsh not installed. Installing..."
        sudo pacman -S --noconfirm zsh
    fi

    local zsh_path=$(which zsh)

    if [ "$SHELL" != "$zsh_path" ]; then
        log_warning "Zsh is not the default shell"

        if ! grep -q "^${zsh_path}$" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi

        if confirm "Change default shell to zsh?"; then
            chsh -s "$zsh_path"
            log_success "Default shell changed to zsh"
            log_warning "Log out and log back in for this to take effect"
        fi
    else
        log_success "Zsh is already the default shell"
    fi
}

# Issue 3: Install pyenv
fix_pyenv() {
    log_info "Checking pyenv installation..."

    if [ ! -d "$HOME/.pyenv" ]; then
        log_warning "pyenv not installed"

        if confirm "Install pyenv?"; then
            log_info "Installing pyenv..."
            curl https://pyenv.run | bash

            # Add to shell configs
            for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
                if [ -f "$rc_file" ] && ! grep -q "PYENV_ROOT" "$rc_file"; then
                    cat >> "$rc_file" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
                fi
            done

            log_success "pyenv installed"
            log_info "Restart your shell to use pyenv"
        fi
    else
        log_success "pyenv is already installed"
    fi
}

# Issue 4: Fix GNOME extensions
fix_gnome_extensions() {
    if ! is_gnome; then
        log_info "Not running GNOME, skipping extension setup"
        return
    fi

    log_info "Checking GNOME extensions..."

    if confirm "Attempt to install GNOME Extension Manager?"; then
        if ! flatpak list | grep -q "ExtensionManager"; then
            log_info "Installing Extension Manager..."
            flatpak install -y flathub com.mattjakeman.ExtensionManager
            log_success "Extension Manager installed"
            log_info "Use Extension Manager to install extensions from:"
            log_info "  gnome/extensions/installed.txt"
        else
            log_success "Extension Manager already installed"
        fi
    fi
}

# Issue 5: Fix PyCharm installation
fix_pycharm() {
    log_info "Checking PyCharm installation..."

    if ! command_exists pycharm; then
        log_warning "PyCharm not found"

        if ! command_exists yay; then
            log_error "yay is required. Run the AUR packages fix first."
            return
        fi

        echo ""
        echo "PyCharm options:"
        echo "  1) PyCharm Professional (AUR, requires license)"
        echo "  2) PyCharm Community Edition (free)"
        echo "  3) Skip"
        echo ""

        read -p "Choose option (1-3): " choice

        case $choice in
            1)
                log_info "Installing PyCharm Professional..."
                yay -S --noconfirm pycharm-professional
                ;;
            2)
                log_info "Installing PyCharm Community Edition..."
                sudo pacman -S --noconfirm pycharm-community-edition
                ;;
            *)
                log_info "Skipping PyCharm installation"
                ;;
        esac
    else
        log_success "PyCharm is already installed"
    fi
}

# Main menu
main() {
    echo "What would you like to fix?"
    echo ""
    echo "  1) Install yay and AUR packages"
    echo "  2) Set zsh as default shell"
    echo "  3) Install pyenv"
    echo "  4) Setup GNOME extensions"
    echo "  5) Install PyCharm"
    echo "  6) Fix all of the above"
    echo "  7) Exit"
    echo ""

    read -p "Enter your choice (1-7): " choice
    echo ""

    case $choice in
        1)
            fix_aur_packages
            ;;
        2)
            fix_zsh_shell
            ;;
        3)
            fix_pyenv
            ;;
        4)
            fix_gnome_extensions
            ;;
        5)
            fix_pycharm
            ;;
        6)
            log_info "Running all fixes..."
            echo ""
            fix_aur_packages
            echo ""
            fix_zsh_shell
            echo ""
            fix_pyenv
            echo ""
            fix_gnome_extensions
            echo ""
            fix_pycharm
            ;;
        7)
            log_info "Exiting"
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac

    echo ""
    log_success "Fix completed!"
    echo ""
    log_info "Next steps:"
    echo "  - Log out and log back in for shell changes"
    echo "  - Restart GNOME Shell for extension changes (Alt+F2, then type 'r')"
    echo "  - Run 'source ~/.zshrc' or 'source ~/.bashrc' to reload shell"
}

main "$@"

