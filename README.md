# Dotfiles V3

> Automated Linux dotfiles system with one-command setup

Designed for **Arch Linux** + **GNOME** + **Python development**. Works on Debian/Fedora too.

---

## Quick Start

### On New System

```bash
git clone <your-repo> ~/dotfiles_v3
cd ~/dotfiles_v3
make install
```

**That's it!** One command installs everything. Then log out and log back in.

### First Time (No Backups Yet)

```bash
git clone <your-repo> ~/dotfiles_v3
cd ~/dotfiles_v3
make first-time    # Creates package lists + installs
```

---

## What `make install` Does

Automatically:
- ✅ Installs packages (pacman, AUR, flatpak, snap, pip, npm)
- ✅ Sets up Zsh as default shell + Oh My Zsh + plugins
- ✅ Installs and configures pyenv
- ✅ Restores GNOME settings
- ✅ Links all configs (vim, nvim, git, kitty, zsh, etc.)
- ✅ Installs PyCharm (optional)

**After install:** Log out and log back in!

---

## Make Commands

### Main Commands
```bash
make               # Show help
make install       # Install everything (recommended)
make backup        # Backup everything
make first-time    # First time? Run this!
```

### Individual Components
```bash
make install-packages  # Packages only
make install-gnome     # GNOME only  
make install-pycharm   # PyCharm only
make setup-shell       # Shell setup only
make link              # Link configs only
make unlink            # Unlink configs
```

### Backups
```bash
make backup            # Full backup
make backup-packages   # Packages only
make backup-gnome      # GNOME only
make backup-configs    # Configs only
make backup-fonts      # Fonts only
```

### Git Operations
```bash
make sync              # Pull, backup, commit, push
make commit            # Quick commit
make push              # Push to remote
make pull              # Pull changes
make status            # Git status
```

### Utilities
```bash
make setup             # Create package lists from examples
make clean             # Remove temp files
make check             # Check for sensitive files
```

---

## Package Management

Package lists in `packages/`:
- `pacman.txt` - Arch Linux packages
- `aur.txt` - AUR packages (requires yay)
- `flatpak.txt` - Flatpak apps
- `snap.txt` - Snap packages
- `pip.txt` - Python packages
- `npm.txt` - NPM global packages

Use `make setup` to create from examples, or `make backup-packages` to backup current system.

---

## Configuration Files

All configs in `configs/` are symlinked automatically:
- **Neovim** - `configs/nvim/`
- **Vim** - `configs/vim/`
- **Zsh** - `configs/zsh/`
- **Git** - `configs/git/`
- **Kitty** - `configs/kitty/`
- **VS Code** - `configs/vscode/`
- **PyCharm** - `configs/jetbrains/pycharm-settings/`
- **GTK** - `configs/gtk-3.0/`, `configs/gtk-4.0/`
- **btop** - `configs/btop/`

Uses GNU Stow for symlink management.

---

## Migration Workflow

### Old System
```bash
cd ~/dotfiles_v3
make backup        # Backup everything
make commit        # Commit changes
make push          # Push to git
```

### New System
```bash
git clone <repo> ~/dotfiles_v3
cd ~/dotfiles_v3
make install       # Install everything
# Log out and log back in
```

---

## Directory Structure

```
dotfiles_v3/
├── Makefile           # Your main interface (use this!)
├── install.sh         # Main installer (called by make)
├── configs/           # App configs (auto-symlinked)
├── packages/          # Package lists
├── gnome/             # GNOME settings & extensions
├── fonts/             # Custom fonts
└── scripts/           # Helper scripts (use make commands instead)
```

---

## Requirements

- Git
- Internet connection  
- Sudo access

Everything else is installed automatically.

---

## Troubleshooting

### Package installation fails
Some packages may not exist - that's OK. Install manually later.

### Zsh not default after install
Log out and log back in (required for shell change).

### GNOME extensions not working
Install Extension Manager: `flatpak install flathub com.mattjakeman.ExtensionManager`  
Then install extensions via GUI.

### Pyenv not working
Restart terminal: `source ~/.zshrc`

### Need to edit package lists?
```bash
vim packages/pacman.txt
vim packages/aur.txt
# Then run: make install-packages
```

---

## Tips

- **First time?** Run `make first-time`
- **Migrating?** Run `make backup` on old system, `make install` on new
- **Update configs?** Just edit files and `make backup`
- **Sync multiple machines?** Use `make sync` regularly
- **Don't want prompts?** `make install` handles everything
- **Want control?** Use individual commands like `make install-packages`

---

## Features

### Shell & Tools
- Zsh with Oh My Zsh
- Zsh plugins (autosuggestions, syntax highlighting)
- Pyenv for Python version management
- Starship prompt (optional)

### GNOME Desktop
- All settings backed up/restored
- Extension Manager installed
- Keybindings preserved
- Favorite apps restored

### Development
- PyCharm (Community or Professional)
- VS Code + extensions
- All editor configs (vim, nvim)
- Git configuration

### Package Managers
- Pacman (Arch)
- AUR (via yay)
- Flatpak
- Snap
- pip (Python)
- npm (Node.js)

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT - See [LICENSE](LICENSE)

---

## Quick Reference

```bash
# First time
make first-time

# Regular install
make install

# Backup
make backup

# Show all commands
make help
```

**Remember:** Log out and log back in after installation!

