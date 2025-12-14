# Dotfiles V3 - Automated Linux Migration System

A comprehensive dotfiles repository for backing up and restoring your entire Linux desktop environment, including system packages, GNOME extensions, application configurations, and settings.

## Features

- 🔄 **Automated Backup & Restore**: One-command setup for new machines
- 📦 **Package Management**: Exports/imports all installed packages (apt/dnf/pacman, Flatpak, Snap, pip, npm, cargo)
- 🎨 **GNOME Desktop**: Saves extensions, themes, keybindings, and dconf settings
- ⚙️ **Application Configs**: Manages dotfiles using GNU Stow for symlink management
- 💻 **IDE Support**: Backs up PyCharm, VS Code, Cursor, and all JetBrains IDEs
- 🎯 **Editor Configs**: Vim, Neovim, LunarVim configurations
- 🎨 **Prompt Themes**: Oh-My-Posh configuration and themes
- 🔒 **Secure**: Excludes sensitive data with `.gitignore` patterns
- 🐧 **Multi-distro**: Works with Ubuntu, Fedora, Arch, and derivatives

## What's Backed Up

### Editors & IDEs ✅
- **Vim, Neovim, LunarVim** - Full configurations
- **VS Code & Cursor** - Settings, keybindings, snippets, extensions
- **JetBrains IDEs** - PyCharm, IntelliJ IDEA settings and plugins
- **IdeaVim** - Vim emulation settings for JetBrains IDEs

### Shell & Terminal ✅
- **Zsh & Bash** - Shell configurations
- **Oh-My-Posh** - Prompt theme engine configurations
- **Kitty, Alacritty, Terminator** - Terminal emulator configs
- **Tmux** - Terminal multiplexer settings

### Tools & Utilities ✅
- **Git** - Global git configuration
- **Htop, Btop** - System monitors
- **Ranger** - File manager
- **Atuin** - Shell history sync

### Desktop Environment ✅
- **GNOME** - All settings, extensions, keybindings
- **GTK** - Theme configurations

See [BACKUP-GUIDE.md](BACKUP-GUIDE.md) for complete details.

## Quick Start

### Initial Setup (Current Machine)

1. Clone this repository:
```bash
git clone https://github.com/vahidtwo/dotfiles_v3.git ~/dotfiles
cd ~/dotfiles
```

2. Backup your current system:
```bash
./scripts/backup.sh
```

3. Commit and push your configurations:
```bash
git add .
git commit -m "Initial backup from $(hostname)"
git push
```

### Restore on New Machine

1. Clone the repository:
```bash
git clone https://github.com/vahidtwo/dotfiles_v3.git ~/dotfiles
cd ~/dotfiles
```

2. Run the installation script:
```bash
./install.sh
```

The script will:
- Install all system packages and applications
- Restore GNOME extensions and settings
- Create symlinks for all configuration files
- Set up development environments

## Directory Structure

```
dotfiles_v3/
├── configs/          # Application configurations
│   ├── zsh/         # Zsh configuration
│   ├── bash/        # Bash configuration
│   ├── git/         # Git configuration
│   ├── vim/         # Vim configuration
│   ├── nvim/        # Neovim configuration
│   ├── lvim/        # LunarVim configuration
│   ├── vscode/      # VS Code settings
│   ├── cursor/      # Cursor AI editor
│   ├── jetbrains/   # PyCharm, IntelliJ IDEA, etc.
│   ├── oh-my-posh/  # Oh-My-Posh prompt themes
│   ├── kitty/       # Kitty terminal
│   ├── alacritty/   # Alacritty terminal
│   ├── htop/        # System monitor
│   ├── btop/        # Better system monitor
│   ├── atuin/       # Shell history sync
│   └── ...
├── gnome/           # GNOME desktop environment
│   ├── extensions/  # Extension list and settings
│   └── settings/    # Dconf dumps
├── packages/        # Package lists
│   ├── apt.txt      # APT packages
│   ├── flatpak.txt  # Flatpak applications
│   ├── snap.txt     # Snap packages
│   ├── pip.txt      # Python packages
│   ├── npm.txt      # Node.js packages
│   └── cargo.txt    # Rust packages
├── scripts/         # Installation and backup scripts
│   ├── backup.sh           # Backup current system
│   ├── install-packages.sh # Install all packages
│   ├── setup-gnome.sh      # Restore GNOME settings
│   ├── link-configs.sh     # Symlink configurations
│   └── utils.sh            # Utility functions
├── install.sh       # Main installation script
├── BACKUP-GUIDE.md  # Detailed backup documentation
└── README.md        # This file
```

## Manual Usage

### Backup Individual Components

```bash
# Backup packages only
./scripts/backup.sh --packages

# Backup GNOME settings only
./scripts/backup.sh --gnome

# Backup configs only
./scripts/backup.sh --configs
```

### Restore Individual Components

```bash
# Install packages only
./scripts/install-packages.sh

# Restore GNOME settings only
./scripts/setup-gnome.sh

# Link configs only
stow -d configs -t ~ zsh git vim
```

## Customization

### Adding New Configs

1. Create a new directory in `configs/` with your app name
2. Structure it to mirror your home directory
3. Run backup script to save current configs
4. Use `stow` to create symlinks

### Excluding Sensitive Data

Edit `.gitignore` to exclude:
- SSH keys
- GPG keys
- Tokens and passwords
- Private configuration files

## Requirements

- Git
- GNU Stow
- Python 3
- Bash/Zsh

## Troubleshooting

**Stow conflicts**: Remove existing dotfiles or use `stow --adopt` to merge

**Permission errors**: Some operations require sudo access

**Missing packages**: Script will skip unavailable packages on different distros

## License

MIT License - Feel free to use and modify

## Credits

Inspired by the dotfiles community and best practices from various Linux users.

