# Makefile for Dotfiles Management

.PHONY: help backup install link unlink packages gnome clean status

help:  ## Show this help message
	@echo "Dotfiles V3 - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

backup:  ## Backup current system configuration
	@echo "Running full backup..."
	./scripts/backup.sh

verify:  ## Verify backup completeness
	@./scripts/verify-backup.sh

backup-packages:  ## Backup only package lists
	./scripts/backup.sh --packages

backup-gnome:  ## Backup only GNOME settings
	./scripts/backup.sh --gnome

backup-configs:  ## Backup only application configs
	./scripts/backup.sh --configs

backup-fonts:  ## Backup fonts only (simple direct copy)
	./scripts/backup-fonts-only.sh

backup-fonts-manual:  ## Backup fonts manually (if script fails)
	@echo "Backing up fonts manually..."
	@mkdir -p fonts/files
	@cd ~/.local/share/fonts && find . -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp --parents {} $(PWD)/fonts/files/ \; 2>/dev/null || true
	@find ~/.local/share/fonts -type f \( -name "*.ttf" -o -name "*.otf" \) > fonts/font-list.txt 2>/dev/null
	@echo "✅ Fonts backed up to fonts/files/"
	@echo "Font count: $$(find fonts/files/ -type f | wc -l)"
	@echo "Total size: $$(du -sh fonts/files/ | cut -f1)"

install:  ## Full installation on new system
	./install.sh

install-packages:  ## Install only packages
	./scripts/install-packages.sh

install-gnome:  ## Setup only GNOME settings
	./scripts/setup-gnome.sh

link:  ## Link configuration files
	./scripts/link-configs.sh link

unlink:  ## Unlink configuration files
	./scripts/link-configs.sh unlink

status:  ## Show git status
	@git status

commit:  ## Quick commit with auto message
	@git add .
	@git commit -m "Update dotfiles - $$(date +%Y-%m-%d_%H:%M:%S)"
	@echo "Changes committed. Run 'make push' to push to remote."

push:  ## Push changes to remote
	@git push

pull:  ## Pull latest changes from remote
	@git pull

sync: pull backup commit push  ## Full sync: pull, backup, commit, push
	@echo "Dotfiles synced successfully!"

clean:  ## Remove temporary and cache files
	@find . -type f -name "*.pyc" -delete
	@find . -type f -name "*.swp" -delete
	@find . -type f -name "*.swo" -delete
	@find . -type f -name "*~" -delete
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@echo "Cleaned temporary files"

test:  ## Test backup scripts (dry run)
	@echo "This will perform a dry run of backup operations..."
	@echo "Checking for required commands..."
	@command -v git >/dev/null 2>&1 || { echo "git is required but not installed"; exit 1; }
	@command -v stow >/dev/null 2>&1 || { echo "stow is required but not installed"; exit 1; }
	@echo "All checks passed!"

setup-git:  ## Configure git for this repository
	@read -p "Enter your Git remote URL: " remote_url; \
	git remote add origin $$remote_url || git remote set-url origin $$remote_url
	@echo "Git remote configured"

check:  ## Check for sensitive files
	@echo "Checking for potentially sensitive files..."
	@find . -type f \( -name "*.key" -o -name "*.pem" -o -name "*.token" -o -name "*secret*" \) ! -path "./.git/*"
	@echo "Check complete. Review any files listed above."

.DEFAULT_GOAL := help

