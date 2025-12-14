# Quick Start Guide

This guide will help you get started with your dotfiles repository.

## For First Time Setup (Current Machine)

### 1. Initialize the Repository

The repository is already set up. Now you need to backup your current system:

```bash
cd ~/dotfiles  # Or wherever you cloned this repo
```

### 2. Make Scripts Executable

```bash
chmod +x install.sh
chmod +x scripts/*.sh
```

### 3. Backup Your Current System

```bash
./scripts/backup.sh
```

This will:
- Export all installed packages (apt, flatpak, snap, pip, npm, etc.)
- Backup GNOME extensions and settings (if using GNOME)
- Copy your configuration files to the `configs/` directory

### 4. Review What Was Backed Up

```bash
git status
```

Look through the files to make sure nothing sensitive was included (passwords, API keys, etc.).

### 5. Commit Your Dotfiles

```bash
git add .
git commit -m "Initial backup from $(hostname) - $(date +%Y-%m-%d)"
```

### 6. Push to GitHub (Recommended)

Create a repository on GitHub, then:

```bash
git remote add origin https://github.com/yourusername/dotfiles_v3.git
git branch -M main
git push -u origin main
```

## For New Machine Setup

### 1. Clone Your Dotfiles

```bash
git clone https://github.com/yourusername/dotfiles_v3.git ~/dotfiles
cd ~/dotfiles
```

### 2. Make Scripts Executable

```bash
chmod +x install.sh
chmod +x scripts/*.sh
```

### 3. Run Installation

```bash
./install.sh
```

This will:
- Install all your packages
- Restore GNOME settings
- Create symlinks for all configuration files

### 4. Restart

```bash
# Log out and log back in, or reboot
sudo reboot
```

## Selective Operations

### Only Backup Packages
```bash
./scripts/backup.sh --packages
```

### Only Backup GNOME Settings
```bash
./scripts/backup.sh --gnome
```

### Only Backup Configs
```bash
./scripts/backup.sh --configs
```

### Only Install Packages
```bash
./scripts/install-packages.sh
```

### Only Setup GNOME
```bash
./scripts/setup-gnome.sh
```

### Only Link Configs
```bash
./scripts/link-configs.sh
```

## Common Workflows

### Adding a New Config File

1. Create the structure in `configs/`:
   ```bash
   mkdir -p configs/myapp/.config/myapp
   cp ~/.config/myapp/config.yml configs/myapp/.config/myapp/
   ```

2. Commit and push:
   ```bash
   git add configs/myapp
   git commit -m "Add myapp configuration"
   git push
   ```

3. Link it:
   ```bash
   cd configs && stow -t ~ myapp
   ```

### Updating Dotfiles on Another Machine

```bash
cd ~/dotfiles
git pull
./install.sh
```

### Keeping Dotfiles in Sync

On your main machine, regularly run:
```bash
cd ~/dotfiles
./scripts/backup.sh
git add .
git commit -m "Update configs - $(date +%Y-%m-%d)"
git push
```

## Tips

1. **Start Small**: Don't try to backup everything at once. Start with your most important configs.

2. **Test on VM**: Before relying on this for a real migration, test it in a virtual machine.

3. **Private Dotfiles**: Keep sensitive configs in a separate private repository.

4. **Documentation**: Add comments to your config files explaining customizations.

5. **Regular Backups**: Set up a cron job or reminder to run `backup.sh` weekly.

## Troubleshooting

### Scripts Won't Run
```bash
chmod +x install.sh scripts/*.sh
```

### Stow Conflicts
```bash
# Backup existing files
./scripts/link-configs.sh  # It will prompt you

# Or manually
mv ~/.bashrc ~/.bashrc.backup
```

### Missing Packages
Some packages might not be available on different distros. The scripts will skip them and warn you.

### GNOME Extensions Not Installing
Extensions must be installed manually from extensions.gnome.org. The script will restore their settings after installation.

## Next Steps

- [ ] Run initial backup on current machine
- [ ] Review and commit changes
- [ ] Test installation in a VM or fresh system
- [ ] Set up automatic backups
- [ ] Document any manual steps needed
- [ ] Share your dotfiles with the community!

## Resources

- [GNU Stow Documentation](https://www.gnu.org/software/stow/manual/stow.html)
- [Dotfiles Community](https://dotfiles.github.io/)
- [GNOME Extensions](https://extensions.gnome.org/)
- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)

