# Dotfiles V3 Makefile
# Main interface for dotfiles management - use these commands instead of running scripts directly

.PHONY: help install backup setup link unlink clean first-time
.DEFAULT_GOAL := help

# Colors
CYAN := \033[36m
RESET := \033[0m

help:  ## Show all available commands
	@echo "╔════════════════════════════════════════╗"
	@echo "║     Dotfiles V3 - Make Commands       ║"
	@echo "╚════════════════════════════════════════╝"
	@echo ""
	@echo "Main Commands:"
	@echo "  $(CYAN)make install$(RESET)       - Install everything on new system"
	@echo "  $(CYAN)make backup$(RESET)        - Backup everything from current system"
	@echo "  $(CYAN)make first-time$(RESET)    - First time? Creates package lists + installs"
	@echo ""
	@echo "Individual Components:"
	@echo "  $(CYAN)make install-packages$(RESET)  - Install packages only"
	@echo "  $(CYAN)make install-gnome$(RESET)     - Setup GNOME only"
	@echo "  $(CYAN)make install-pycharm$(RESET)   - Install PyCharm only"
	@echo "  $(CYAN)make setup-shell$(RESET)       - Setup shell (zsh, pyenv) only"
	@echo "  $(CYAN)make link$(RESET)              - Link configs only"
	@echo "  $(CYAN)make unlink$(RESET)            - Unlink configs"
	@echo ""
	@echo "Backup Commands:"
	@echo "  $(CYAN)make backup-packages$(RESET)   - Backup package lists only"
	@echo "  $(CYAN)make backup-gnome$(RESET)      - Backup GNOME settings only"
	@echo "  $(CYAN)make backup-configs$(RESET)    - Backup configs only"
	@echo "  $(CYAN)make backup-fonts$(RESET)      - Backup fonts only"
	@echo ""
	@echo "Git Operations:"
	@echo "  $(CYAN)make sync$(RESET)              - Pull, backup, commit, push"
	@echo "  $(CYAN)make commit$(RESET)            - Quick commit with timestamp"
	@echo "  $(CYAN)make push$(RESET)              - Push to remote"
	@echo "  $(CYAN)make pull$(RESET)              - Pull from remote"
	@echo "  $(CYAN)make status$(RESET)            - Show git status"
	@echo ""
	@echo "Utilities:"
	@echo "  $(CYAN)make setup$(RESET)             - Create package lists from examples"
	@echo "  $(CYAN)make clean$(RESET)             - Remove temporary files"
	@echo "  $(CYAN)make check$(RESET)             - Check for sensitive files"
	@echo ""

# ============================================================================
# Main Commands
# ============================================================================

install:  ## Install everything (packages, shell, gnome, configs, pycharm)
	@echo "🚀 Starting full installation..."
	@echo "This will install packages, setup shell, GNOME, and link configs."
	@echo ""
	@./install.sh

backup:  ## Backup everything
	@echo "💾 Running full backup..."
	@./scripts/backup.sh

first-time:  ## First time setup: create package lists + install
	@echo "╔════════════════════════════════════════╗"
	@echo "║      First Time Setup & Install       ║"
	@echo "╚════════════════════════════════════════╝"
	@echo ""
	@echo "📦 Creating package lists from examples..."
	@$(MAKE) --no-print-directory setup
	@echo ""
	@echo "✅ Package lists created!"
	@echo ""
	@echo "📝 You can edit them before installing:"
	@echo "   - packages/pacman.txt"
	@echo "   - packages/aur.txt"
	@echo "   - packages/flatpak.txt (optional)"
	@echo ""
	@read -p "Press Enter to start installation (or Ctrl+C to cancel)..." dummy
	@echo ""
	@$(MAKE) --no-print-directory install

setup:  ## Create package lists from examples
	@test -f packages/pacman.txt || (cp packages/pacman.txt.example packages/pacman.txt && echo "✓ Created packages/pacman.txt")
	@test -f packages/aur.txt || (cp packages/aur.txt.example packages/aur.txt && echo "✓ Created packages/aur.txt")
	@test -f packages/flatpak.txt || (cp packages/flatpak.txt.example packages/flatpak.txt && echo "✓ Created packages/flatpak.txt")
	@test -f packages/snap.txt || (cp packages/snap.txt.example packages/snap.txt && echo "✓ Created packages/snap.txt")
	@test -f packages/pip.txt || (cp packages/pip.txt.example packages/pip.txt && echo "✓ Created packages/pip.txt")
	@test -f packages/npm.txt || (cp packages/npm.txt.example packages/npm.txt && echo "✓ Created packages/npm.txt")

# ============================================================================
# Individual Component Installation
# ============================================================================

install-packages:  ## Install packages only
	@./scripts/install-packages.sh

install-gnome:  ## Setup GNOME only
	@./scripts/setup-gnome.sh

install-pycharm:  ## Install PyCharm only
	@./scripts/install-pycharm.sh

setup-shell:  ## Setup shell (zsh, pyenv, Oh My Zsh)
	@./scripts/setup-shell.sh

link:  ## Link configuration files
	@./scripts/link-configs.sh link

unlink:  ## Unlink configuration files
	@./scripts/link-configs.sh unlink

# ============================================================================
# Backup Commands
# ============================================================================

backup-packages:  ## Backup only package lists
	@./scripts/backup.sh --packages

backup-gnome:  ## Backup only GNOME settings
	@./scripts/backup.sh --gnome

backup-configs:  ## Backup only application configs
	@./scripts/backup.sh --configs

backup-fonts:  ## Backup fonts only
	@./scripts/backup-fonts-only.sh

verify:  ## Verify backup completeness
	@./scripts/verify-backup.sh

# ============================================================================
# Git Operations
# ============================================================================

status:  ## Show git status
	@git status

commit:  ## Quick commit with timestamp
	@git add .
	@git commit -m "Update dotfiles - $$(date +%Y-%m-%d_%H:%M:%S)"
	@echo "✅ Changes committed. Run 'make push' to push to remote."

push:  ## Push changes to remote
	@git push

pull:  ## Pull latest changes from remote
	@git pull

sync: pull backup commit push  ## Full sync: pull, backup, commit, push
	@echo "✅ Dotfiles synced successfully!"

setup-git:  ## Configure git remote URL
	@read -p "Enter your Git remote URL: " remote_url; \
	git remote add origin $$remote_url 2>/dev/null || git remote set-url origin $$remote_url
	@echo "✅ Git remote configured"

# ============================================================================
# Utilities
# ============================================================================

clean:  ## Remove temporary and cache files
	@echo "🧹 Cleaning temporary files..."
	@find . -type f -name "*.pyc" -delete
	@find . -type f -name "*.swp" -delete
	@find . -type f -name "*.swo" -delete
	@find . -type f -name "*~" -delete
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Cleaned temporary files"

check:  ## Check for sensitive files
	@echo "🔍 Checking for potentially sensitive files..."
	@find . -type f \( -name "*.key" -o -name "*.pem" -o -name "*.token" -o -name "*secret*" \) ! -path "./.git/*" || true
	@echo "✅ Check complete"

test:  ## Test scripts syntax
	@echo "🧪 Testing script syntax..."
	@bash -n install.sh && echo "✓ install.sh"
	@bash -n scripts/install-packages.sh && echo "✓ install-packages.sh"
	@bash -n scripts/setup-shell.sh && echo "✓ setup-shell.sh"
	@bash -n scripts/setup-gnome.sh && echo "✓ setup-gnome.sh"
	@bash -n scripts/install-pycharm.sh && echo "✓ install-pycharm.sh"
	@echo "✅ All scripts OK"

