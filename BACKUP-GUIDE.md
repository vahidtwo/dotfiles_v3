# Backup Guide

This document lists all configurations that are backed up by the dotfiles system.

## Currently Backed Up ✅

### Shell Configurations
- ✅ **Bash**: `.bashrc`, `.bash_profile`
- ✅ **Zsh**: `.zshrc`, `.zshenv`, `.zprofile`, `.oh-my-zsh`
- ✅ **Oh-My-Posh**: `.oh-my-posh.conf.toml`, theme configurations

### Editors & IDEs

#### Text Editors
- ✅ **Vim**: `.vimrc`, `.vim/`, `.ideavimrc`
- ✅ **Neovim**: `~/.config/nvim/`
- ✅ **LunarVim**: `~/.config/lvim/`

#### IDE Configurations
- ✅ **VS Code**: 
  - Settings: `~/.config/Code/User/settings.json`
  - Keybindings: `~/.config/Code/User/keybindings.json`
  - Snippets: `~/.config/Code/User/snippets/`
  - Extensions list: exported to `vscode/extensions.txt`

- ✅ **Cursor**: 
  - Extensions list: exported to `cursor/extensions.txt`

- ✅ **JetBrains IDEs** (PyCharm, IntelliJ IDEA, etc.):
  - Full config: `~/.config/JetBrains/`
  - PyCharm settings: `~/pycharm-settings/`
  - Plugins list: exported to `jetbrains/pycharm-plugins.txt`
  - IdeaVim: `.ideavimrc`

### Version Control
- ✅ **Git**: `.gitconfig`, `.gitignore_global`

### Terminal Emulators
- ✅ **Alacritty**: `~/.config/alacritty/`
- ✅ **Kitty**: `~/.config/kitty/`
- ✅ **Terminator**: `~/.config/terminator/`

### System Tools
- ✅ **Tmux**: `.tmux.conf`
- ✅ **Htop**: `~/.config/htop/`
- ✅ **Btop**: `~/.config/btop/`
- ✅ **Ranger**: `~/.config/ranger/`
- ✅ **Atuin**: `~/.config/atuin/` (shell history sync)

### Desktop Environment (GNOME)
- ✅ **GNOME Settings**: All dconf settings
- ✅ **GTK Themes**: `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/`
- ✅ **GNOME Extensions**: List of installed and enabled extensions
- ✅ **Keybindings**: Window manager and media keys
- ✅ **Favorite Apps**: Dash favorites

### Package Managers
- ✅ **System Packages**:
  - APT (Debian/Ubuntu): `packages/apt.txt`
  - DNF (Fedora): `packages/dnf.txt`
  - Pacman (Arch): `packages/pacman.txt`, `packages/pacman-aur.txt`
- ✅ **Flatpak**: `packages/flatpak.txt`
- ✅ **Snap**: `packages/snap.txt`
- ✅ **pip**: `packages/pip.txt`
- ✅ **npm**: `packages/npm.txt`
- ✅ **Cargo**: `packages/cargo.txt`

### Fonts
- ✅ **Font List**: List of custom fonts in `~/.local/share/fonts/`

## Not Currently Backed Up ⚠️

### Databases
- ❌ **MySQL/MariaDB**: Database dumps
- ❌ **PostgreSQL**: Database dumps
- ❌ **MongoDB**: Database dumps
- ❌ **Redis**: Database dumps

### Web Servers
- ❌ **Nginx**: Configuration files
- ❌ **Apache**: Configuration files

### Containerization
- ❌ **Docker**: Docker configurations, compose files
- ❌ **Podman**: Podman configurations

### Cloud CLIs
- ❌ **AWS CLI**: `~/.aws/config` (excluding credentials)
- ❌ **Google Cloud**: `~/.config/gcloud/`
- ❌ **Azure CLI**: `~/.azure/`

### Other Applications
- ❌ **Thunderbird**: Email client settings
- ❌ **Firefox**: Browser profile
- ❌ **Chrome/Chromium**: Browser profile
- ❌ **Obsidian**: Note-taking app settings
- ❌ **Timeshift**: Backup configurations

### System Configurations
- ❌ **Systemd Services**: Custom user services in `~/.config/systemd/user/`
- ❌ **Cron Jobs**: User crontabs
- ❌ **SSH Config**: `~/.ssh/config` (be careful with keys!)

## How to Backup

### Full Backup
```bash
./scripts/backup.sh
```

### Selective Backup
```bash
# Only backup package lists
./scripts/backup.sh --packages

# Only backup GNOME settings
./scripts/backup.sh --gnome

# Only backup application configs
./scripts/backup.sh --configs
```

## Restoring on a New Machine

### Quick Start
```bash
# Clone your dotfiles
git clone https://github.com/yourusername/dotfiles_v3.git
cd dotfiles_v3

# Run the installer
./install.sh
```

### Step by Step
```bash
# 1. Install packages
./scripts/install-packages.sh

# 2. Link configurations
./scripts/link-configs.sh

# 3. Setup GNOME (if applicable)
./scripts/setup-gnome.sh
```

## Adding New Backups

To add a new configuration to backup:

1. Edit `scripts/backup.sh`
2. Add your config path to the `configs` array in `backup_configs()` function:
   ```bash
   "source/path:destination/path"
   ```

Example:
```bash
".config/myapp:myapp/.config/myapp"
```

3. Test the backup:
   ```bash
   ./scripts/backup.sh --configs
   ```

4. Add the app to `.gitignore` if it contains sensitive data

## Security Considerations

### ⚠️ NEVER COMMIT:
- SSH private keys
- GPG private keys
- API tokens/keys
- Passwords
- Database credentials
- Browser cookies/sessions
- Email account data

### Safe to Commit:
- ✅ Configuration files (after removing secrets)
- ✅ Theme preferences
- ✅ Keybindings
- ✅ Editor settings
- ✅ Package lists
- ✅ GNOME settings

### Use `.gitignore`
The `configs/.gitignore` file is configured to exclude sensitive data. Review it regularly.

### Environment Variables
For sensitive configuration, use environment variables:
```bash
# In .zshrc or .bashrc
export API_KEY="your-key-here"  # DON'T commit this

# Instead, create a .env.example:
export API_KEY="your-api-key"  # This is safe to commit

# And a .env (not committed):
export API_KEY="actual-secret-key"
```

## Verification Checklist

Before pushing to remote:
- [ ] No passwords in configs
- [ ] No API keys in configs
- [ ] No SSH/GPG private keys
- [ ] Sensitive files are in `.gitignore`
- [ ] Test restore on a VM or fresh install
- [ ] All important configs are backed up

## Automation

### Automatic Backup (Optional)

Create a cron job to backup regularly:
```bash
# Edit crontab
crontab -e

# Add this line to backup daily at 2 AM
0 2 * * * cd ~/dotfiles_v3 && ./scripts/backup.sh && git add . && git commit -m "Auto backup $(date)" && git push
```

### Git Hooks

Create a pre-commit hook to check for sensitive data:
```bash
# .git/hooks/pre-commit
#!/bin/bash
# Check for potential secrets
if git diff --cached | grep -E "(password|api[_-]?key|secret|token)" -i; then
    echo "WARNING: Potential secret detected!"
    exit 1
fi
```

## Troubleshooting

### Backup is too large
- Exclude large files/directories (add to `.gitignore`)
- Use Git LFS for large binary files
- Consider separate repositories for large configs

### Conflicts on restore
- Use `stow --adopt` to merge existing configs
- Backup existing configs first: `mv ~/.config/app ~/.config/app.backup`

### Missing dependencies
- Update package lists: `./scripts/backup.sh --packages`
- Document manual installation steps in `MANUAL-SETUP.md`

## Related Documentation
- [README.md](../README.md) - Main documentation
- [configs/README.md](../configs/README.md) - Config structure
- [QUICK-REFERENCE.txt](../QUICK-REFERENCE.txt) - Command reference

