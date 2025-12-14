# Migration Checklist

Use this checklist when migrating to a new machine.

## Before Migrating (On Old Machine)

- [ ] Update all packages: `sudo apt update && sudo apt upgrade`
- [ ] Run full backup: `./scripts/backup.sh`
- [ ] Export browser bookmarks and extensions manually
- [ ] Backup SSH keys: `cp -r ~/.ssh ~/ssh-backup`
- [ ] Backup GPG keys: `gpg --export-secret-keys > ~/gpg-backup.asc`
- [ ] List all running services: `systemctl list-units --type=service --state=running > ~/services.txt`
- [ ] Document custom kernel modules or drivers
- [ ] Export GNOME Tweaks settings
- [ ] Screenshot your desktop layout for reference
- [ ] Review git status: `git status`
- [ ] Commit all changes: `git add . && git commit -m "Final backup before migration"`
- [ ] Push to remote: `git push`
- [ ] Verify remote repository is accessible
- [ ] Export Firefox/Chrome profiles if needed
- [ ] List installed fonts: `fc-list > ~/fonts.txt`
- [ ] Document any custom systemd services
- [ ] Backup Docker containers/images if applicable
- [ ] Export Thunderbird/email client data
- [ ] Backup local databases (MySQL, PostgreSQL, etc.)
- [ ] Document network configurations
- [ ] List cron jobs: `crontab -l > ~/crontab-backup.txt`

## On New Machine (Initial Setup)

- [ ] Install base operating system
- [ ] Update system: `sudo apt update && sudo apt upgrade`
- [ ] Install git: `sudo apt install git`
- [ ] Install curl/wget if needed
- [ ] Configure network/WiFi
- [ ] Set up user account with same username (if possible)
- [ ] Install graphics drivers if needed
- [ ] Install firmware updates

## Clone and Install Dotfiles

- [ ] Clone dotfiles: `git clone https://github.com/user/dotfiles_v3.git ~/dotfiles`
- [ ] Navigate to directory: `cd ~/dotfiles`
- [ ] Make scripts executable: `chmod +x install.sh scripts/*.sh`
- [ ] Review installation script: `cat install.sh`
- [ ] Run installation: `./install.sh`
- [ ] Resolve any conflicts or errors
- [ ] Verify symlinks: `ls -la ~ | grep "->"`

## Post-Installation

### Shell & Terminal
- [ ] Set default shell: `chsh -s $(which zsh)` or `chsh -s $(which bash)`
- [ ] Install Oh My Zsh if using: `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- [ ] Test shell configuration: `source ~/.zshrc` or `source ~/.bashrc`
- [ ] Configure terminal emulator preferences

### Git & Development
- [ ] Verify git config: `git config --list`
- [ ] Import SSH keys: `cp ~/ssh-backup/* ~/.ssh/ && chmod 600 ~/.ssh/id_*`
- [ ] Test SSH: `ssh -T git@github.com`
- [ ] Import GPG keys: `gpg --import ~/gpg-backup.asc`
- [ ] Configure git signing: `git config --global commit.gpgsign true`
- [ ] Clone important repositories
- [ ] Set up development environments (Node, Python, Ruby, etc.)

### GNOME Desktop (if applicable)
- [ ] Verify GNOME settings applied: Check appearance, keybindings
- [ ] Install GNOME Extension Manager
- [ ] Manually install extensions from extensions.gnome.org
- [ ] Enable installed extensions
- [ ] Configure favorite apps in dock/dash
- [ ] Set up workspaces
- [ ] Configure displays/monitors
- [ ] Set wallpaper and lock screen

### Applications
- [ ] Verify VS Code settings synced
- [ ] Install VS Code extensions: `cat configs/vscode/extensions.txt`
- [ ] Configure browser (import bookmarks, install extensions)
- [ ] Set up email client
- [ ] Configure messaging apps (Slack, Discord, etc.)
- [ ] Install additional software not in package lists
- [ ] Restore browser profiles
- [ ] Configure cloud storage (Dropbox, Google Drive, etc.)

### System Configuration
- [ ] Set up printers
- [ ] Configure Bluetooth devices
- [ ] Set up VPN connections
- [ ] Configure firewall: `sudo ufw enable`
- [ ] Set up automatic updates
- [ ] Configure power settings
- [ ] Set up backup solution (Timeshift, Deja Dup, etc.)
- [ ] Enable automatic security updates

### Fonts & Themes
- [ ] Install custom fonts to `~/.local/share/fonts/`
- [ ] Update font cache: `fc-cache -f -v`
- [ ] Install icon themes
- [ ] Install GTK themes
- [ ] Configure Qt theme to match GTK

### Data Migration
- [ ] Transfer documents from old machine
- [ ] Restore Docker containers/images
- [ ] Import databases
- [ ] Transfer music/photos/videos
- [ ] Restore browser cache/sessions if needed
- [ ] Import password manager database

### Testing
- [ ] Test all key applications
- [ ] Verify all keybindings work
- [ ] Check network connectivity
- [ ] Test audio/video playback
- [ ] Verify webcam functionality
- [ ] Test printing
- [ ] Check all development tools work
- [ ] Verify cron jobs: `crontab -e`

### Security
- [ ] Enable firewall: `sudo ufw enable`
- [ ] Configure fail2ban if used
- [ ] Set up disk encryption (if not done during install)
- [ ] Review sudo permissions
- [ ] Set up automatic screen lock
- [ ] Configure privacy settings
- [ ] Review startup applications

### Final Steps
- [ ] Update dotfiles from new machine: `./scripts/backup.sh`
- [ ] Commit new machine-specific changes
- [ ] Document any manual steps you took
- [ ] Create system restore point
- [ ] Test restore from backup
- [ ] Delete sensitive backup files (SSH keys, GPG keys from temp locations)
- [ ] Securely wipe old machine (if decommissioning)

## Optional Enhancements
- [ ] Set up automatic dotfiles sync (cron job)
- [ ] Configure automatic backups
- [ ] Set up system monitoring
- [ ] Install additional security tools
- [ ] Configure system tweaks (swappiness, I/O scheduler, etc.)
- [ ] Set up development containers/VMs
- [ ] Configure game controllers/peripherals

## Troubleshooting Notes

Common issues and solutions:

### Packages won't install
- Check package names for your distribution
- Update package databases
- Check repository availability

### Stow conflicts
- Backup existing files: `mv ~/.bashrc ~/.bashrc.old`
- Or adopt files: `stow --adopt -t ~ packagename`

### GNOME extensions not working
- Check GNOME Shell version compatibility
- Restart GNOME: `Alt+F2`, type `r`, press Enter
- Check extension logs: `journalctl -f`

### Missing fonts
- Install manually to `~/.local/share/fonts/`
- Run `fc-cache -fv`

### Performance issues
- Check for resource-intensive startup applications
- Monitor system resources: `htop`
- Check for swap usage

## Notes
- Keep this checklist updated with your specific needs
- Document any issues and solutions for future reference
- Some applications may require manual configuration
- Test in a VM before migrating production machine

