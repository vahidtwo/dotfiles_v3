#!/usr/bin/env bash
# Quick verification script to check if everything was backed up

cd "$(dirname "$0")/.."

echo "======================================"
echo "  DOTFILES BACKUP VERIFICATION"
echo "======================================"
echo ""

check_exists() {
    if [ -e "$1" ]; then
        echo "✅ $2"
        return 0
    else
        echo "❌ MISSING: $2"
        echo "   Location: $1"
        return 1
    fi
}

check_not_empty() {
    if [ -e "$1" ] && [ -n "$(ls -A "$1" 2>/dev/null)" ]; then
        echo "✅ $2"
        return 0
    else
        echo "❌ EMPTY or MISSING: $2"
        echo "   Location: $1"
        return 1
    fi
}

TOTAL=0
PASSED=0

echo "📦 PACKAGES"
echo "─────────────────────────────────────"
check_exists "packages/pacman.txt" "System packages (pacman)"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_exists "packages/flatpak.txt" "Flatpak packages"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_exists "packages/pip.txt" "Python packages"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
echo ""

echo "🎨 GNOME DESKTOP"
echo "─────────────────────────────────────"
check_exists "gnome/extensions/installed.txt" "GNOME extensions list"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_exists "gnome/settings/gnome-settings.dconf" "GNOME settings"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
echo ""

echo "🐚 SHELL CONFIGS"
echo "─────────────────────────────────────"
check_exists "configs/zsh/.zshrc" "Zsh configuration"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_not_empty "configs/oh-my-posh" "Oh-My-Posh configuration"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
echo ""

echo "📝 EDITORS & IDEs"
echo "─────────────────────────────────────"
check_exists "configs/vim/.vimrc" "Vim configuration"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_not_empty "configs/nvim" "Neovim configuration"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_not_empty "configs/jetbrains" "JetBrains/PyCharm configs"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_exists "configs/vscode/extensions.txt" "VS Code extensions"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
echo ""

echo "🖥️  TERMINAL"
echo "─────────────────────────────────────"
check_not_empty "configs/kitty" "Kitty terminal config"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
echo ""

echo "🔧 TOOLS"
echo "─────────────────────────────────────"
check_exists "configs/git/.gitconfig" "Git configuration"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_not_empty "configs/btop" "Btop configuration"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_not_empty "configs/atuin" "Atuin configuration"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
echo ""

echo "🎨 GTK THEMES"
echo "─────────────────────────────────────"
check_not_empty "configs/gtk-3.0" "GTK-3.0 settings"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
check_not_empty "configs/gtk-4.0" "GTK-4.0 settings"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))
echo ""

echo "🔤 FONTS (CRITICAL!)"
echo "─────────────────────────────────────"
check_exists "fonts/font-list.txt" "Font list file"; ((TOTAL++)); [ $? -eq 0 ] && ((PASSED++))

# Check if actual font files exist
if [ -d "fonts/files" ] && [ -n "$(find fonts/files -name '*.ttf' -o -name '*.otf' 2>/dev/null)" ]; then
    FONT_COUNT=$(find fonts/files -name '*.ttf' -o -name '*.otf' | wc -l)
    FONT_SIZE=$(du -sh fonts/files 2>/dev/null | cut -f1)
    echo "✅ Font files backed up: $FONT_COUNT fonts (~$FONT_SIZE)"
    ((TOTAL++))
    ((PASSED++))
else
    echo "❌ CRITICAL: Font files NOT backed up!"
    echo "   Expected: fonts/files/ directory with .ttf/.otf files"
    echo "   Action: Run './scripts/backup.sh' to backup fonts"
    ((TOTAL++))
fi
echo ""

echo "======================================"
echo "  SUMMARY"
echo "======================================"
echo "Passed: $PASSED / $TOTAL"
echo ""

if [ $PASSED -eq $TOTAL ]; then
    echo "✅ ALL CHECKS PASSED!"
    echo "Your dotfiles are fully backed up and ready to push."
    echo ""
    echo "Next steps:"
    echo "  git add ."
    echo "  git commit -m 'Complete backup with fonts'"
    echo "  git push"
    exit 0
else
    echo "⚠️  SOME ITEMS MISSING!"
    echo "Run './scripts/backup.sh' to complete the backup."
    exit 1
fi

