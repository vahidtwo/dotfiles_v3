# GNOME Configuration

This directory contains GNOME desktop environment settings and extensions.

## Structure

```
gnome/
├── extensions/
│   ├── installed.txt         # List of installed extensions
│   ├── enabled.txt           # List of enabled extensions
│   └── *.dconf              # Per-extension settings
└── settings/
    ├── gnome-settings.dconf  # Main GNOME settings
    ├── gtk-settings.dconf    # GTK settings
    ├── keybindings-wm.dconf  # Window manager keybindings
    ├── keybindings-media.dconf # Media keybindings
    └── favorite-apps.txt     # Favorite applications in dash
```

## Backup

To backup your current GNOME settings:
```bash
./scripts/backup.sh --gnome
```

## Restore

To restore GNOME settings on a new machine:
```bash
./scripts/setup-gnome.sh
```

Or during full installation:
```bash
./install.sh
```

## Manual Operations

### Export Settings
```bash
# Export all GNOME settings
dconf dump /org/gnome/ > gnome/settings/gnome-settings.dconf

# Export specific extension settings
dconf dump /org/gnome/shell/extensions/extension-name/ > gnome/extensions/extension-name.dconf
```

### Import Settings
```bash
# Import GNOME settings
dconf load /org/gnome/ < gnome/settings/gnome-settings.dconf

# Import extension settings
dconf load /org/gnome/shell/extensions/extension-name/ < gnome/extensions/extension-name.dconf
```

### List Extensions
```bash
# List installed extensions
gnome-extensions list

# List enabled extensions
gnome-extensions list --enabled
```

## Installing Extensions

Extensions need to be installed from [extensions.gnome.org](https://extensions.gnome.org) or using a tool like:

1. **GNOME Extension Manager** (Recommended)
   ```bash
   flatpak install flathub com.mattjakeman.ExtensionManager
   ```

2. **Browser Integration**
   - Install browser extension for Chrome/Firefox
   - Install native connector: `sudo apt install chrome-gnome-shell`

3. **Manual Installation**
   - Download extension zip from extensions.gnome.org
   - Extract to `~/.local/share/gnome-shell/extensions/`
   - Enable with `gnome-extensions enable extension@uuid`

## Popular Extensions

Consider installing these popular extensions:
- Dash to Dock / Dash to Panel
- AppIndicator Support
- Clipboard Indicator
- Vitals (System Monitor)
- User Themes
- Blur My Shell
- GSConnect (KDE Connect)

## Notes

- Extensions are version-specific to GNOME Shell
- Some extensions may need to be updated after GNOME upgrades
- Settings are automatically restored after extensions are installed

