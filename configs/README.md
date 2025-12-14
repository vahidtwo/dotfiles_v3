# Application Configurations

This directory contains application configuration files managed by GNU Stow.

## Structure

Each subdirectory represents a "package" that can be independently stowed:

```
configs/
├── bash/
│   ├── .bashrc
│   └── .bash_profile
├── zsh/
│   ├── .zshrc
│   └── .zshenv
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── vim/
│   └── .vimrc
├── nvim/
│   └── .config/
│       └── nvim/
├── vscode/
│   ├── .config/Code/User/settings.json
│   └── extensions.txt
└── ...
```

## Usage with GNU Stow

### Link All Configs
```bash
./scripts/link-configs.sh
```

### Link Specific Package
```bash
cd configs
stow -t ~ git    # Link git configs
stow -t ~ zsh    # Link zsh configs
```

### Unlink Package
```bash
cd configs
stow -D -t ~ git  # Unlink git configs
```

### Handle Conflicts
If you have existing dotfiles that conflict:

```bash
# Option 1: Adopt existing files (merge into repo)
stow --adopt -t ~ git

# Option 2: Backup and remove existing files manually
mv ~/.gitconfig ~/.gitconfig.backup
stow -t ~ git
```

## Adding New Configs

1. Create a new directory in `configs/` with your app name:
   ```bash
   mkdir -p configs/myapp
   ```

2. Structure it to mirror your home directory:
   ```bash
   configs/myapp/
   └── .config/
       └── myapp/
           └── config.conf
   ```

3. Stow it:
   ```bash
   cd configs && stow -t ~ myapp
   ```

## Common Configurations

### Shell
- **bash**: Bash shell configuration
- **zsh**: Zsh shell configuration

### Editors
- **vim**: Vim editor
- **nvim**: Neovim
- **lvim**: LunarVim
- **vscode**: Visual Studio Code
- **cursor**: Cursor AI editor
- **jetbrains**: JetBrains IDEs (PyCharm, IntelliJ IDEA, etc.)

### Version Control
- **git**: Git configuration

### Shell & Prompt
- **bash**: Bash shell configuration
- **zsh**: Zsh shell configuration
- **oh-my-posh**: Oh My Posh prompt theme engine

### Terminal Emulators
- **alacritty**: Alacritty terminal
- **kitty**: Kitty terminal
- **terminator**: Terminator terminal

### Tools
- **tmux**: Terminal multiplexer
- **htop**: Process viewer
- **btop**: Modern process viewer
- **ranger**: File manager
- **atuin**: Shell history sync

### Desktop
- **gtk-3.0**: GTK 3 themes
- **gtk-4.0**: GTK 4 themes

## Best Practices

1. **Don't commit sensitive data**: Use `.gitignore` for API keys, tokens, etc.
2. **Use separate packages**: Keep configs modular for flexibility
3. **Test before committing**: Always test your configs on a fresh system
4. **Document dependencies**: Note required packages in comments
5. **Version control**: Commit changes regularly with meaningful messages

## Troubleshooting

### Stow Complains About Conflicts
```bash
# See what conflicts exist
stow -n -v -t ~ packagename

# Backup existing files
mv ~/.conflicting-file ~/.conflicting-file.backup

# Then stow
stow -t ~ packagename
```

### Broken Symlinks
```bash
# Find broken symlinks
find ~ -xtype l

# Remove broken symlinks in home
find ~ -maxdepth 1 -xtype l -delete
```

### Restow Everything
```bash
# Restow all packages
cd configs
for dir in */; do
    stow -R -t ~ "${dir%/}"
done
```

