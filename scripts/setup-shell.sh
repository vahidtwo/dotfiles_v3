#!/usr/bin/env bash

# Setup shell configurations
# Usage: ./setup-shell.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils.sh"

setup_zsh() {
    log_info "Setting up Zsh..."

    if ! command_exists zsh; then
        log_warning "Zsh is not installed. Installing..."
        install_package zsh
    fi

    # Get the path to zsh
    local zsh_path=$(which zsh)

    # Check if zsh is in /etc/shells
    if ! grep -q "^${zsh_path}$" /etc/shells; then
        log_info "Adding zsh to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    # Change default shell to zsh
    if [ "$SHELL" != "$zsh_path" ]; then
        log_info "Changing default shell to zsh..."
        chsh -s "$zsh_path"
        log_success "Default shell changed to zsh"
        log_warning "You need to log out and log back in for this to take effect"
    else
        log_info "Zsh is already the default shell"
    fi
}

setup_oh_my_zsh() {
    log_info "Setting up Oh My Zsh..."

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        if confirm "Install Oh My Zsh?"; then
            log_info "Installing Oh My Zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            log_success "Oh My Zsh installed"
        else
            log_info "Skipping Oh My Zsh installation"
        fi
    else
        log_info "Oh My Zsh is already installed"
    fi

    # Install popular plugins
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]; then
        if confirm "Install zsh-autosuggestions plugin?"; then
            log_info "Installing zsh-autosuggestions..."
            git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
        fi
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]; then
        if confirm "Install zsh-syntax-highlighting plugin?"; then
            log_info "Installing zsh-syntax-highlighting..."
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
        fi
    fi
}

setup_pyenv() {
    log_info "Setting up pyenv..."

    if [ ! -d "$HOME/.pyenv" ]; then
        if confirm "Install pyenv?"; then
            log_info "Installing pyenv..."
            curl https://pyenv.run | bash
            log_success "pyenv installed"

            log_info "Adding pyenv to shell configuration..."

            # Add to .bashrc if it exists
            if [ -f "$HOME/.bashrc" ] && ! grep -q "PYENV_ROOT" "$HOME/.bashrc"; then
                cat >> "$HOME/.bashrc" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
            fi

            # Add to .zshrc if it exists
            if [ -f "$HOME/.zshrc" ] && ! grep -q "PYENV_ROOT" "$HOME/.zshrc"; then
                cat >> "$HOME/.zshrc" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
            fi

            log_warning "Please restart your shell or run:"
            log_info "  export PYENV_ROOT=\"\$HOME/.pyenv\""
            log_info "  export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
            log_info "  eval \"\$(pyenv init -)\""
        else
            log_info "Skipping pyenv installation"
        fi
    else
        log_info "pyenv is already installed"
    fi

    # Install pyenv build dependencies
    if command_exists pyenv; then
        log_info "Installing pyenv build dependencies..."
        local pm="$(detect_package_manager)"

        case "$pm" in
            apt)
                sudo apt install -y build-essential libssl-dev zlib1g-dev \
                    libbz2-dev libreadline-dev libsqlite3-dev curl \
                    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
                    libffi-dev liblzma-dev
                ;;
            dnf)
                sudo dnf install -y gcc make patch zlib-devel bzip2 bzip2-devel \
                    readline-devel sqlite sqlite-devel openssl-devel tk-devel \
                    libffi-devel xz-devel
                ;;
            pacman)
                sudo pacman -S --needed --noconfirm base-devel openssl zlib xz tk
                ;;
        esac

        log_success "pyenv build dependencies installed"
    fi
}

setup_starship() {
    log_info "Setting up Starship prompt..."

    if ! command_exists starship; then
        if confirm "Install Starship prompt?"; then
            log_info "Installing Starship..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
            log_success "Starship installed"
        else
            log_info "Skipping Starship installation"
            return
        fi
    else
        log_info "Starship is already installed"
    fi

    # Add to shells
    if [ -f "$HOME/.bashrc" ] && ! grep -q "starship init" "$HOME/.bashrc"; then
        echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
    fi

    if [ -f "$HOME/.zshrc" ] && ! grep -q "starship init" "$HOME/.zshrc"; then
        echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
    fi
}

main() {
    log_info "Starting shell setup..."

    setup_zsh
    echo ""

    setup_oh_my_zsh
    echo ""

    setup_pyenv
    echo ""

    setup_starship
    echo ""

    log_success "Shell setup completed!"
    echo ""
    log_warning "IMPORTANT: Log out and log back in for shell changes to take effect"
}

main "$@"

