#!/usr/bin/env bash

# Main installation script for dotfiles
# Usage: ./install.sh [--skip-packages] [--skip-gnome] [--skip-configs]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$SCRIPT_DIR"

# Source utilities
source "$SCRIPT_DIR/scripts/utils.sh"

# Parse arguments
SKIP_PACKAGES=false
SKIP_GNOME=false
SKIP_CONFIGS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-packages)
            SKIP_PACKAGES=true
            shift
            ;;
        --skip-gnome)
            SKIP_GNOME=true
            shift
            ;;
        --skip-configs)
            SKIP_CONFIGS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-packages   Skip package installation"
            echo "  --skip-gnome      Skip GNOME setup"
            echo "  --skip-configs    Skip configuration linking"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_banner() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   Dotfiles V3 Installation Script     ║"
    echo "║   Automated Linux Migration System     ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if git is installed
    if ! command_exists git; then
        log_error "Git is not installed. Please install git first."
        exit 1
    fi

    # Check if we're in a git repository
    if [ ! -d "$DOTFILES_ROOT/.git" ]; then
        log_warning "Not in a git repository. Consider initializing git for version control."
    fi

    # Detect system information
    local distro=$(detect_distro)
    local pm=$(detect_package_manager)

    log_info "Detected OS: $distro"
    log_info "Package manager: $pm"

    if is_gnome; then
        log_info "Desktop environment: GNOME"
    else
        log_warning "Not running GNOME. Some features may be skipped."
    fi

    log_success "Prerequisites check completed"
}

install_packages() {
    if [ "$SKIP_PACKAGES" = true ]; then
        log_info "Skipping package installation"
        return
    fi

    log_info "Installing packages..."

    if [ ! -d "$DOTFILES_ROOT/packages" ]; then
        log_warning "No packages directory found. Skipping package installation."
        return
    fi

    if confirm "Install system packages and applications?"; then
        bash "$DOTFILES_ROOT/scripts/install-packages.sh"
    else
        log_info "Skipped package installation"
    fi
}

setup_gnome() {
    if [ "$SKIP_GNOME" = true ]; then
        log_info "Skipping GNOME setup"
        return
    fi

    if ! is_gnome; then
        log_info "Not running GNOME, skipping GNOME setup"
        return
    fi

    log_info "Setting up GNOME..."

    if [ ! -d "$DOTFILES_ROOT/gnome" ]; then
        log_warning "No GNOME directory found. Skipping GNOME setup."
        return
    fi

    if confirm "Restore GNOME settings and extensions?"; then
        bash "$DOTFILES_ROOT/scripts/setup-gnome.sh"
    else
        log_info "Skipped GNOME setup"
    fi
}

link_configs() {
    if [ "$SKIP_CONFIGS" = true ]; then
        log_info "Skipping configuration linking"
        return
    fi

    log_info "Linking configurations..."

    if [ ! -d "$DOTFILES_ROOT/configs" ]; then
        log_warning "No configs directory found. Skipping configuration linking."
        return
    fi

    if confirm "Link configuration files using GNU Stow?"; then
        bash "$DOTFILES_ROOT/scripts/link-configs.sh" link
    else
        log_info "Skipped configuration linking"
    fi
}

post_install() {
    log_info "Running post-installation tasks..."

    # Reload shell configuration
    if [ -n "$SHELL" ]; then
        log_info "Shell configuration updated. Run 'source ~/.${SHELL##*/}rc' or restart your terminal."
    fi

    # Font cache
    if command_exists fc-cache; then
        log_info "Updating font cache..."
        fc-cache -f
    fi

    log_success "Post-installation completed"
}

print_summary() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║         Installation Complete!         ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    log_info "Your dotfiles have been installed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    echo "  2. Log out and log back in for GNOME changes to take effect"
    echo "  3. Review any warnings or errors above"
    echo "  4. Install GNOME extensions manually from extensions.gnome.org"
    echo ""
    log_info "To update your dotfiles:"
    echo "  cd $DOTFILES_ROOT && git pull"
    echo ""
    log_info "To backup changes:"
    echo "  cd $DOTFILES_ROOT && ./scripts/backup.sh"
    echo ""
}

main() {
    print_banner

    log_info "Starting dotfiles installation..."
    log_info "Dotfiles root: $DOTFILES_ROOT"
    echo ""

    # Confirmation
    if ! confirm "This will install packages and link configuration files. Continue?"; then
        log_info "Installation cancelled"
        exit 0
    fi

    echo ""

    # Run installation steps
    check_prerequisites
    echo ""

    install_packages
    echo ""

    setup_gnome
    echo ""

    link_configs
    echo ""

    post_install
    echo ""

    print_summary
}

main "$@"

