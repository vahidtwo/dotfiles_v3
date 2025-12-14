# Font Backup & Restoration Guide

## Current Status

Your fonts are now backed up in two ways:

### 1. Font List (Always backed up)
- **Location**: `fonts/font-list.txt`
- **Contains**: List of all font file paths
- **Size**: Very small (a few KB)

### 2. Font Files (Backed up if space allows)
- **Location**: `fonts/files/`
- **Contains**: Actual `.ttf`, `.otf`, `.woff`, `.woff2` font files
- **Size**: ~32MB in your case
- **Note**: These ARE now being backed up by the updated script

## Restoring Fonts on a New Machine

### Automatic Restoration
```bash
cd ~/dotfiles_v3
./scripts/restore-fonts.sh
```

This script will:
1. Copy all fonts from `fonts/files/` to `~/.local/share/fonts/`
2. Rebuild the font cache
3. Make fonts available system-wide

### Manual Restoration

If you prefer manual installation:

```bash
# Copy fonts
mkdir -p ~/.local/share/fonts
cp -r ~/dotfiles_v3/fonts/files/* ~/.local/share/fonts/

# Update font cache
fc-cache -f -v ~/.local/share/fonts
```

## Your Backed Up Fonts

Based on your system, you have these font families:
- **Hack** (programming font)
- **Roboto** (multiple weights)
- **Material Symbols** (icon font)
- **Vazir/Vazirmatn** (Persian/Farsi fonts)

## If Fonts Were Not Backed Up

If for space reasons you didn't backup the actual font files, you can:

### 1. Download Common Fonts

#### Hack Font (Monospace for coding)
```bash
cd ~/dotfiles_v3/fonts/files
wget https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
unzip Hack-v3.003-ttf.zip
```

#### Roboto (Google's sans-serif)
```bash
cd ~/dotfiles_v3/fonts/files
wget https://github.com/google/roboto/releases/download/v2.138/roboto-unhinted.zip
unzip roboto-unhinted.zip
```

#### Vazirmatn (Persian font)
```bash
cd ~/dotfiles_v3/fonts/files
wget https://github.com/rastikerdar/vazirmatn/releases/download/v33.003/vazirmatn-v33.003.zip
unzip vazirmatn-v33.003.zip
```

### 2. Install Using Package Manager

Many fonts are available in repositories:

```bash
# Arch Linux
sudo pacman -S ttf-hack ttf-roboto

# Ubuntu/Debian
sudo apt install fonts-hack fonts-roboto

# Fedora
sudo dnf install google-roboto-fonts hack-fonts
```

## Verifying Fonts Are Installed

```bash
# List all installed fonts
fc-list

# Search for specific font
fc-list | grep -i "Hack"
fc-list | grep -i "Roboto"
fc-list | grep -i "Vazir"

# Count total fonts
fc-list | wc -l
```

## Fonts Directory Structure

```
fonts/
├── font-list.txt          # List of all fonts (always present)
├── files/                 # Actual font files (if backed up)
│   ├── Hack-Bold.ttf
│   ├── Roboto-Regular.ttf
│   ├── Vazirmatn-Medium.ttf
│   └── ...
└── README.md              # This file
```

## Git LFS (Large File Storage)

If your font collection is very large (>100MB), consider using Git LFS:

```bash
# Install Git LFS
git lfs install

# Track font files
git lfs track "fonts/files/*.ttf"
git lfs track "fonts/files/*.otf"

# Add .gitattributes
git add .gitattributes
git commit -m "Track fonts with Git LFS"
```

## Troubleshooting

### Fonts don't appear after restoration
```bash
# Rebuild font cache
fc-cache -fv

# Restart applications or log out/in
```

### Permission errors
```bash
# Fix permissions
chmod -R 644 ~/.local/share/fonts/*
fc-cache -fv
```

### Font rendering issues
```bash
# Install font rendering packages
# Arch
sudo pacman -S freetype2 fontconfig

# Ubuntu/Debian
sudo apt install fontconfig
```

## Related Files

- `../scripts/backup.sh` - Backs up fonts automatically
- `../scripts/restore-fonts.sh` - Restores fonts on new system
- `font-list.txt` - Reference list of your fonts

