#!/usr/bin/env bash

# Restore fonts - Install custom fonts from backup
# Usage: ./restore-fonts.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/utils.sh"

restore_fonts() {
    log_info "Restoring custom fonts..."

    local fonts_source="$DOTFILES_ROOT/fonts/files"
    local fonts_dest="$HOME/.local/share/fonts"

    # Check if fonts backup exists
    if [ ! -d "$fonts_source" ]; then
        log_error "No fonts backup found at $fonts_source"
        log_info "Please run './scripts/backup.sh' first or download fonts manually"
        return 1
    fi

    # Create destination directory
    ensure_dir "$fonts_dest"

    # Copy fonts
    log_info "Copying fonts to $fonts_dest..."
    cp -r "$fonts_source"/* "$fonts_dest/" 2>/dev/null || {
        log_error "Failed to copy fonts"
        return 1
    }

    # Update font cache
    if command_exists fc-cache; then
        log_info "Updating font cache..."
        fc-cache -f -v "$fonts_dest" >/dev/null 2>&1
        log_success "Font cache updated"
    else
        log_warning "fc-cache not found. Install fontconfig package."
    fi

    # Count installed fonts
    local font_count=$(find "$fonts_dest" -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | wc -l)
    log_success "Restored $font_count fonts to $fonts_dest"

    # List fonts for verification
    log_info "Installed fonts:"
    fc-list | grep -i "$fonts_dest" | head -10 || true
}

main() {
    log_info "Font Restoration Script"
    log_info "======================="

    restore_fonts

    log_success "Font restoration completed!"
    log_info ""
    log_info "To verify fonts are installed, run:"
    log_info "  fc-list | grep -i 'Hack\\|Vazir\\|Roboto'"
}

main "$@"

