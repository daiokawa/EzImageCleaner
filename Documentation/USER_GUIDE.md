# EzImageCleaner User Guide

## Table of Contents
1. [Getting Started](#getting-started)
2. [GUI Mode](#gui-mode)
3. [Terminal Mode](#terminal-mode)
4. [Tips & Tricks](#tips--tricks)
5. [FAQ](#faq)

## Getting Started

### First Launch
When you first launch EzImageCleaner, macOS may show a security warning. This is normal for apps downloaded from the internet.

1. Right-click on the app
2. Select "Open" from the context menu
3. Click "Open" in the dialog that appears

### Choosing a Mode
EzImageCleaner offers two modes:
- **GUI Mode**: Best for casual users who prefer visual interfaces
- **Terminal Mode**: Best for power users who want maximum speed

## GUI Mode

### Basic Workflow
1. **Select Folders**: Check the boxes next to folders you want to scan
2. **Set Size Threshold**: Use the slider to set minimum file size (default: 300KB)
3. **Start Scanning**: Click the "Start Scanning" button
4. **Review Images**: For each image:
   - Press **Y** to delete (moves to Trash)
   - Press **N** to keep and move to next
   - Press **⌘Z** to undo last deletion

### Keyboard Shortcuts
- `Y` - Delete current image
- `N` - Keep current image
- `⌘Z` - Undo last deletion
- `⌘,` - Open preferences
- `⌘Q` - Quit application

### Custom Folders
To add folders not in the default list:
1. Click "Settings"
2. Click "Add Folder"
3. Navigate to and select your folder
4. Click "Add"

## Terminal Mode

### Launching Terminal Mode
You can launch Terminal Mode in two ways:
1. Click "Terminal Mode" button in the GUI
2. Run directly: `/Applications/EzImageCleaner.app/Contents/Resources/Scripts/ezimagecleaner.sh`

### Navigation
- **Number keys**: Select folder by number
- **N**: Next page of folders
- **P**: Previous page
- **C**: Enter custom path
- **Q**: Quit

### Image Review
- **Y**: Delete image (move to Trash)
- **N**: Keep image and continue
- **R**: Redisplay current image
- **U**: Undo last deletion
- **S**: Skip current folder
- **Q**: Return to folder selection

### Configuration
Create `~/.ezimagecleaner/config` to customize:
```bash
MIN_SIZE=500k        # Minimum file size
CACHE_DURATION=7200  # Cache for 2 hours
PREVIEW_DELAY=0.3    # Faster preview
PAGE_SIZE=20         # More folders per page
```

## Tips & Tricks

### Speed Tips
1. **Use Terminal Mode** for folders with many images
2. **Increase minimum size** to focus on larger files
3. **Use keyboard shortcuts** instead of clicking buttons

### Safety Tips
1. **Images go to Trash** - you can recover them
2. **Use Undo** if you delete by mistake
3. **Review carefully** - some large images may be important

### Organization Tips
1. **Start with Downloads** - often has the most clutter
2. **Check Screenshots** folder regularly
3. **Set up regular cleaning** schedule

## FAQ

**Q: Are deleted images permanently removed?**
A: No, they're moved to Trash. You can restore them from there.

**Q: Can I preview images before deciding?**
A: Yes, each image is displayed in Preview before you decide.

**Q: Does it work with external drives?**
A: Yes, use "Custom Path" option to select folders on external drives.

**Q: Can I cancel during scanning?**
A: Yes, press Q in Terminal Mode or close the window in GUI Mode.

**Q: How do I restore a deleted image?**
A: Use Undo (U key) immediately, or find it in Trash later.

**Q: Why doesn't it find all my images?**
A: Check the size threshold - it only shows images above the minimum size.

**Q: Is it safe to use?**
A: Yes, it's open source, works offline, and only moves files to Trash.

## Need Help?

- Check our [GitHub Issues](https://github.com/koichiokawa/EzImageCleaner/issues)
- Tweet [@daiokawa](https://x.com/daiokawa)
- Read the source code - it's open source!