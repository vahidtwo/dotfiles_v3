#!/usr/bin/env bash

# First-time setup helper
# This script helps you get started with your dotfiles repository

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║                                                        ║"
    echo "║          Dotfiles V3 - First Time Setup                ║"
    echo "║                                                        ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

confirm() {
    read -p "$1 [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

main() {
    clear
    print_header

    echo "Welcome! This script will help you set up your dotfiles repository."
    echo ""

    # Step 1: Check location
    print_step "Step 1: Verify repository location"
    echo "Current location: $SCRIPT_DIR"

    echo ""

    # Step 2: Make scripts executable
    print_step "Step 2: Making scripts executable"
    chmod +x "$SCRIPT_DIR/install.sh"
    chmod +x "$SCRIPT_DIR/scripts"/*.sh
    print_info "✓ All scripts are now executable"
    echo ""

    # Step 3: Git configuration
    print_step "Step 3: Git configuration"

    if git remote get-url origin &> /dev/null; then
        print_info "✓ Git remote already configured"
        git remote -v
    else
        print_warning "No git remote configured"
        if confirm "Do you want to add a git remote now?"; then
            read -p "Enter your git repository URL: " repo_url
            git remote add origin "$repo_url"
            print_info "✓ Git remote added: $repo_url"
        else
            print_info "You can add it later with: git remote add origin <URL>"
        fi
    fi
    echo ""

    # Step 4: User information
    print_step "Step 4: What would you like to do?"
    echo ""
    echo "1) Backup current system (first-time setup on existing machine)"
    echo "2) Install dotfiles (migrating to a new machine)"
    echo "3) Just show me the documentation"
    echo "4) Exit"
    echo ""

    read -p "Enter your choice (1-4): " choice

    case $choice in
        1)
            echo ""
            print_step "Starting backup process..."
            print_info "This will backup your:"
            echo "  • Installed packages (apt/dnf/pacman, flatpak, snap, pip, npm)"
            echo "  • GNOME settings and extensions"
            echo "  • Application configurations"
            echo ""

            if confirm "Continue with backup?"; then
                ./scripts/backup.sh

                echo ""
                print_step "Backup complete! Next steps:"
                echo ""
                echo "1. Review what was backed up:"
                echo "   git status"
                echo ""
                echo "2. Check for any sensitive files:"
                echo "   make check"
                echo ""
                echo "3. Commit your changes:"
                echo "   git add ."
                echo "   git commit -m 'Initial backup from $(hostname)'"
                echo ""
                echo "4. Push to remote (if configured):"
                echo "   git push -u origin main"
                echo ""
                print_info "See QUICKSTART.md for more details"
            fi
            ;;
        2)
            echo ""
            print_step "Starting installation process..."
            print_warning "This will install packages and modify your system"
            echo ""

            if confirm "Continue with installation?"; then
                ./install.sh
            fi
            ;;
        3)
            echo ""
            print_step "Documentation files:"
            echo ""
            echo "📖 README.md              - Main documentation"
            echo "🚀 QUICKSTART.md          - Quick start guide"
            echo "✅ MIGRATION-CHECKLIST.md - Complete migration checklist"
            echo "🔧 CONTRIBUTING.md        - Customization guide"
            echo ""
            echo "📁 Directory README files:"
            echo "   • configs/README.md"
            echo "   • gnome/README.md"
            echo "   • packages/README.md"
            echo ""
            print_info "You can also run 'make help' to see available commands"
            ;;
        4)
            print_info "Exiting. You can run this script again anytime."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac

    echo ""
    print_step "Setup helper complete!"
    echo ""
    print_info "Useful commands:"
    echo "  make help          - Show all available commands"
    echo "  make backup        - Backup your system"
    echo "  make install       - Install on new machine"
    echo "  make sync          - Full sync (pull, backup, commit, push)"
    echo ""
    print_info "For more information, see the documentation files listed above."
}

main "$@"

