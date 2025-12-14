# Contributing & Customization Guide

This guide helps you customize the dotfiles system for your needs.

## Customizing for Your Distribution

### Adding Support for New Package Managers

Edit `scripts/utils.sh` to add detection for your package manager:

```bash
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v your-pm &> /dev/null; then
        echo "your-pm"
    fi
}
```

Then add backup/restore logic in the respective scripts.

## Customizing Backup Behavior

### Excluding Specific Configs

Edit `.gitignore` to exclude files you don't want to backup:

```
configs/app/.config/app/cache/
configs/app/.config/app/*.log
```

### Adding Custom Backup Items

Edit `scripts/backup.sh` in the `backup_configs()` function:

```bash
local configs=(
    # Add your custom configs here
    ".config/myapp:myapp/.config/myapp"
)
```

## Security Best Practices

### Handling Sensitive Data

1. **Never commit secrets directly**
   
   Create a separate private repository:
   ```bash
   # In your dotfiles repo
   git submodule add git@github.com:user/dotfiles-private.git private
   ```

2. **Use environment variables**
   
   In your configs, reference env vars:
   ```bash
   export API_KEY="${MY_API_KEY}"
   ```

3. **Use git-crypt for encryption**
   
   ```bash
   cd ~/dotfiles
   git-crypt init
   git-crypt add-gpg-user YOUR_GPG_KEY
   
   # Add to .gitattributes
   echo "private/** filter=git-crypt diff=git-crypt" >> .gitattributes
   ```

4. **Template sensitive files**
   
   Create `.example` files:
   ```bash
   cp .env .env.example
   # Remove sensitive values from .env.example
   # Add .env to .gitignore
   ```

## Advanced Features

### Auto-sync with Cron

Add to crontab (`crontab -e`):

```bash
# Backup dotfiles daily at 6 PM
0 18 * * * cd ~/dotfiles && ./scripts/backup.sh && git add . && git commit -m "Auto-backup $(date +\%Y-\%m-\%d)" && git push
```

### Pre-commit Hooks

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Check for sensitive data before commit

if git diff --cached --name-only | grep -q "secret\|key\|token"; then
    echo "Warning: Possible sensitive file detected!"
    echo "Review your changes carefully."
fi
```

### Multiple Machine Profiles

Create branches for different machines:

```bash
# On work laptop
git checkout -b work-laptop
./scripts/backup.sh
git commit -m "Work laptop config"

# On home desktop
git checkout -b home-desktop
./scripts/backup.sh
git commit -m "Home desktop config"

# Merge common changes
git checkout main
git merge work-laptop
```

## Adding New Scripts

### Creating a Custom Script

1. Create the script in `scripts/`:
   ```bash
   touch scripts/my-script.sh
   chmod +x scripts/my-script.sh
   ```

2. Use the template:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "$SCRIPT_DIR/utils.sh"
   
   main() {
       log_info "Running custom script..."
       # Your code here
   }
   
   main "$@"
   ```

3. Add to Makefile:
   ```makefile
   my-task:  ## Run my custom task
       ./scripts/my-script.sh
   ```

## Testing

### Test in Docker

Create a Dockerfile:

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y git stow

COPY . /root/dotfiles
WORKDIR /root/dotfiles

CMD ["./install.sh"]
```

Build and test:
```bash
docker build -t dotfiles-test .
docker run -it dotfiles-test
```

### Test in VM

Use Vagrant:

```ruby
# Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  config.vm.provision "shell", inline: <<-SHELL
    git clone https://github.com/user/dotfiles.git /home/vagrant/dotfiles
    cd /home/vagrant/dotfiles
    ./install.sh
  SHELL
end
```

## Performance Optimization

### Speeding Up Package Installation

Use parallel installation where supported:

```bash
# APT
sudo apt install -y $(cat packages/apt.txt)

# Flatpak
parallel -j4 flatpak install -y flathub {} < packages/flatpak.txt
```

### Reducing Backup Time

Only backup changed files:

```bash
# In backup.sh
if [ "$source_path" -nt "$dest_path" ]; then
    backup_item "$source_path" "$dest_path"
fi
```

## Troubleshooting

### Debug Mode

Run scripts with debug output:

```bash
bash -x ./install.sh
```

### Log All Operations

Redirect output to log file:

```bash
./install.sh 2>&1 | tee install.log
```

## Contributing

If you want to improve these scripts:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Resources

- [Dotfiles GitHub Topic](https://github.com/topics/dotfiles)
- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [Managing Dotfiles with Git](https://www.atlassian.com/git/tutorials/dotfiles)

