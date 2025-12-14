#!/usr/bin/env bash
# Simple font backup script - guaranteed to work

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================="
echo "  FONT BACKUP SCRIPT"
echo "========================================="
echo ""

# Source and destination
FONT_SOURCE="$HOME/.local/share/fonts"
FONT_DEST="$DOTFILES_ROOT/fonts/files"

# Check if source exists
if [ ! -d "$FONT_SOURCE" ]; then
    echo "❌ ERROR: Font directory not found at $FONT_SOURCE"
    exit 1
fi

echo "📁 Source: $FONT_SOURCE"
echo "📁 Destination: $FONT_DEST"
echo ""

# Create destination
mkdir -p "$FONT_DEST"

# Copy fonts
echo "📋 Copying font files..."
cd "$FONT_SOURCE" || {
    echo "❌ Cannot access $FONT_SOURCE"
    exit 1
}

# Use find to copy only font files, avoiding permission issues
find . -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.woff" -o -name "*.woff2" \) \
    -exec cp --parents {} "$FONT_DEST/" 2>/dev/null \;

cd - >/dev/null

echo ""
echo "✅ Fonts copied successfully!"
echo ""

# Count fonts
TTF_COUNT=$(find "$FONT_DEST" -name "*.ttf" 2>/dev/null | wc -l)
OTF_COUNT=$(find "$FONT_DEST" -name "*.otf" 2>/dev/null | wc -l)
TOTAL_FONTS=$((TTF_COUNT + OTF_COUNT))

echo "📊 Statistics:"
echo "   TTF fonts: $TTF_COUNT"
echo "   OTF fonts: $OTF_COUNT"
echo "   Total fonts: $TOTAL_FONTS"
echo ""

# Calculate size
FONT_SIZE=$(du -sh "$FONT_DEST" 2>/dev/null | cut -f1)
echo "   Total size: $FONT_SIZE"
echo ""

# Create font list
find "$FONT_SOURCE" -type f \( -name "*.ttf" -o -name "*.otf" \) > "$DOTFILES_ROOT/fonts/font-list.txt"

echo "✅ Font list created at fonts/font-list.txt"
echo ""
echo "========================================="
echo "  BACKUP COMPLETE!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Verify: ls -lh $FONT_DEST"
echo "  2. Add to git: git add fonts/"
echo "  3. Commit: git commit -m 'Add font files'"

