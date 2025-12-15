# GNOME Extensions Setup

This directory contains configuration for GNOME Shell extensions.

## Files

- **installed.txt**: List of all extensions that should be installed
- **enabled.txt**: List of extensions that should be enabled
- **\*.dconf**: Individual extension settings (restored automatically)

## Installation Methods

### Method 1: Automatic Installation (Recommended)

Run the installation helper script:

```bash
./scripts/install-gnome-extensions.sh
```

This will:
1. Install `gext` (GNOME Extensions CLI tool)
2. Automatically download and install all extensions
3. Enable the extensions
4. Restore their settings

### Method 2: Extension Manager (GUI)

Install Extension Manager:

```bash
# Via Flatpak (recommended)
flatpak install flathub com.mattjakeman.ExtensionManager

# Or via package manager
sudo pacman -S extension-manager  # Arch
sudo dnf install gnome-extensions-app  # Fedora
sudo apt install gnome-shell-extension-manager  # Ubuntu/Debian
```

Then open Extension Manager and search for each extension listed in `installed.txt`.

### Method 3: Manual Installation

Visit https://extensions.gnome.org and search for each extension by its UUID.

## Extension List

Current extensions tracked in this configuration:

- **appindicatorsupport@rgcjonas.gmail.com** - AppIndicator Support
- **PersianCalendar@oxygenws.com** - Persian Calendar
- **ding@rastersoft.com** - Desktop Icons NG
- **wsmatrix@martin.zurowietz.de** - WS Matrix (workspace grid)
- **network-stats@gnome.noroadsleft.xyz** - Network Stats
- **clipboard-indicator@tudmotu.com** - Clipboard Indicator
- **dash-to-panel@jderose9.github.com** - Dash to Panel
- **GPaste@gnome-shell-extensions.gnome.org** - GPaste
- **dash-to-dock@micxgx.gmail.com** - Dash to Dock
- Plus various built-in GNOME extensions

## Troubleshooting

### Extensions not enabling

1. Make sure the extension is compatible with your GNOME version
2. Log out and log back in
3. Or restart GNOME Shell: `Alt+F2`, type `r`, press Enter (X11 only)
4. Check extension status: `gnome-extensions list`

### Extension installation fails

1. Check your GNOME Shell version: `gnome-shell --version`
2. Visit the extension page on extensions.gnome.org
3. Ensure it supports your GNOME version
4. Try installing via Extension Manager GUI instead

### Settings not applying

1. Make sure the extension is installed and enabled
2. Run: `./scripts/setup-gnome.sh` to restore settings
3. Some settings require a GNOME Shell restart

## Commands

```bash
# List installed extensions
gnome-extensions list

# List enabled extensions
gnome-extensions list --enabled

# Enable an extension
gnome-extensions enable EXTENSION_UUID

# Disable an extension
gnome-extensions disable EXTENSION_UUID

# Show extension info
gnome-extensions info EXTENSION_UUID

# Install all extensions automatically
./scripts/install-gnome-extensions.sh

# Restore GNOME settings and enable extensions
./scripts/setup-gnome.sh
```

## Backup

To backup your current extensions:

```bash
# List installed extensions
gnome-extensions list > gnome/extensions/installed.txt

# List enabled extensions  
gnome-extensions list --enabled > gnome/extensions/enabled.txt

# Backup extension settings
./scripts/backup.sh
```

