#!/usr/bin/env bash

# Test script - Validates the dotfiles setup
# Run this to check if everything is configured correctly

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/utils.sh"

test_count=0
pass_count=0
fail_count=0

run_test() {
    local test_name="$1"
    local test_command="$2"

    ((test_count++))

    if eval "$test_command" &> /dev/null; then
        log_success "✓ $test_name"
        ((pass_count++))
        return 0
    else
        log_error "✗ $test_name"
        ((fail_count++))
        return 1
    fi
}

print_section() {
    echo ""
    log_info "═══════════════════════════════════════"
    log_info "$1"
    log_info "═══════════════════════════════════════"
}

main() {
    log_info "Running dotfiles tests..."
    echo ""

    # Test 1: Directory structure
    print_section "Testing Directory Structure"
    run_test "configs directory exists" "[ -d '$DOTFILES_ROOT/configs' ]"
    run_test "packages directory exists" "[ -d '$DOTFILES_ROOT/packages' ]"
    run_test "gnome directory exists" "[ -d '$DOTFILES_ROOT/gnome' ]"
    run_test "scripts directory exists" "[ -d '$DOTFILES_ROOT/scripts' ]"
    run_test "fonts directory exists" "[ -d '$DOTFILES_ROOT/fonts' ]"

    # Test 2: Script files
    print_section "Testing Script Files"
    run_test "install.sh exists" "[ -f '$DOTFILES_ROOT/install.sh' ]"
    run_test "backup.sh exists" "[ -f '$DOTFILES_ROOT/scripts/backup.sh' ]"
    run_test "install-packages.sh exists" "[ -f '$DOTFILES_ROOT/scripts/install-packages.sh' ]"
    run_test "setup-gnome.sh exists" "[ -f '$DOTFILES_ROOT/scripts/setup-gnome.sh' ]"
    run_test "link-configs.sh exists" "[ -f '$DOTFILES_ROOT/scripts/link-configs.sh' ]"
    run_test "utils.sh exists" "[ -f '$DOTFILES_ROOT/scripts/utils.sh' ]"

    # Test 3: Executability
    print_section "Testing Script Executability"
    run_test "install.sh is executable" "[ -x '$DOTFILES_ROOT/install.sh' ]"
    run_test "backup.sh is executable" "[ -x '$DOTFILES_ROOT/scripts/backup.sh' ]"
    run_test "install-packages.sh is executable" "[ -x '$DOTFILES_ROOT/scripts/install-packages.sh' ]"
    run_test "setup-gnome.sh is executable" "[ -x '$DOTFILES_ROOT/scripts/setup-gnome.sh' ]"
    run_test "link-configs.sh is executable" "[ -x '$DOTFILES_ROOT/scripts/link-configs.sh' ]"

    # Test 4: Documentation
    print_section "Testing Documentation"
    run_test "README.md exists" "[ -f '$DOTFILES_ROOT/README.md' ]"
    run_test "QUICKSTART.md exists" "[ -f '$DOTFILES_ROOT/QUICKSTART.md' ]"
    run_test "CONTRIBUTING.md exists" "[ -f '$DOTFILES_ROOT/CONTRIBUTING.md' ]"
    run_test "MIGRATION-CHECKLIST.md exists" "[ -f '$DOTFILES_ROOT/MIGRATION-CHECKLIST.md' ]"
    run_test "Makefile exists" "[ -f '$DOTFILES_ROOT/Makefile' ]"

    # Test 5: Git
    print_section "Testing Git Configuration"
    run_test "Git repository initialized" "[ -d '$DOTFILES_ROOT/.git' ]"
    run_test ".gitignore exists" "[ -f '$DOTFILES_ROOT/.gitignore' ]"

    # Test 6: System requirements
    print_section "Testing System Requirements"
    run_test "Git is installed" "command_exists git"
    run_test "Bash is available" "command_exists bash"

    # Optional tools
    if command_exists stow; then
        log_success "✓ GNU Stow is installed (required for linking)"
    else
        log_warning "⚠ GNU Stow not installed (will be installed automatically)"
    fi

    if command_exists make; then
        log_success "✓ Make is installed (optional)"
    else
        log_warning "⚠ Make not installed (optional, for Makefile commands)"
    fi

    # Test 7: Syntax check (basic)
    print_section "Testing Script Syntax"
    run_test "install.sh syntax check" "bash -n '$DOTFILES_ROOT/install.sh'"
    run_test "backup.sh syntax check" "bash -n '$DOTFILES_ROOT/scripts/backup.sh'"
    run_test "utils.sh syntax check" "bash -n '$DOTFILES_ROOT/scripts/utils.sh'"

    # Summary
    echo ""
    log_info "═══════════════════════════════════════"
    log_info "Test Summary"
    log_info "═══════════════════════════════════════"
    echo "Total tests: $test_count"
    echo -e "${GREEN}Passed: $pass_count${NC}"

    if [ $fail_count -gt 0 ]; then
        echo -e "${RED}Failed: $fail_count${NC}"
        echo ""
        log_error "Some tests failed. Please review the output above."
        return 1
    else
        echo -e "${RED}Failed: $fail_count${NC}"
        echo ""
        log_success "All tests passed! Your dotfiles repository is ready to use."
        echo ""
        log_info "Next steps:"
        echo "  1. Run './scripts/first-setup.sh' for guided setup"
        echo "  2. Or run './scripts/backup.sh' to backup your system"
        echo "  3. See 'make help' for available commands"
    fi
}

main "$@"

