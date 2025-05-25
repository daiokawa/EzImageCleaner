# EzImageCleaner

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-10.15+-blue.svg)](https://www.apple.com/macos/)
[![Release](https://img.shields.io/github/v/release/daiokawa/EzImageCleaner?include_prereleases)](https://github.com/daiokawa/EzImageCleaner/releases)
[![Downloads](https://img.shields.io/github/downloads/daiokawa/EzImageCleaner/total)](https://github.com/daiokawa/EzImageCleaner/releases)

<p align="center">
  <img src="Resources/Icons/AppIcon.png" width="128" height="128" alt="EzImageCleaner Icon">
</p>

<p align="center">
  <strong>Clean up large images on your Mac with ease!</strong><br>
  A powerful dual-mode (GUI & Terminal) image management tool for macOS
</p>

## ✨ Features

<table>
<tr>
<td width="50%">

### 🖥️ GUI Mode
- Visual image browser with preview
- Slider for size threshold (100KB-10MB)
- Checkbox folder selection
- Real-time statistics
- Keyboard shortcuts (Y/N/U)
- Progress tracking

</td>
<td width="50%">

### ⌨️ Terminal Mode  
- Lightning-fast keyboard navigation
- Minimal resource usage
- Batch processing capabilities
- Color-coded interface
- Single-key commands
- Cache system for speed

</td>
</tr>
</table>

## 🎯 Key Features

- 🔍 **Smart Search**: Automatically finds folders containing large images
- 🖼️ **Preview Integration**: Uses native macOS Preview app
- 🗑️ **Safe Deletion**: Moves files to Trash (recoverable)
- ↩️ **Undo Support**: Restore the last deleted image
- 📊 **Statistics**: Tracks deleted files and freed space
- 🎨 **Modern UI**: Beautiful SwiftUI interface with dark mode support

## 📥 Installation

### Option 1: Download Release (Recommended)

1. Download the latest DMG from [Releases](https://github.com/daiokawa/EzImageCleaner/releases)
2. Open the DMG file
3. Drag EzImageCleaner to your Applications folder
4. Launch from Applications or Spotlight

### Option 2: Homebrew (Coming Soon)

```bash
brew tap daiokawa/tap
brew install --cask ezimagecleaner
```

### Option 3: Build from Source

Requirements:
- Xcode 14.0+
- macOS 12.0+

```bash
git clone https://github.com/daiokawa/EzImageCleaner.git
cd EzImageCleaner
xcodebuild -scheme EzImageCleaner build
```

## 🚀 Usage

### GUI Mode

1. Launch EzImageCleaner from Applications
2. Select folders to scan using checkboxes
3. Adjust the minimum file size slider
4. Click "Start Scanning"
5. Review images one by one:
   - **Y** or **Delete button**: Move to trash
   - **N** or **Keep button**: Skip to next
   - **⌘Z** or **Undo button**: Restore last deleted

### Terminal Mode

1. Click "Terminal Mode" in the app, or run directly:
   ```bash
   /Applications/EzImageCleaner.app/Contents/Resources/Scripts/ezimagecleaner.sh
   ```
2. Navigate folders with number keys
3. Review images:
   - **Y**: Delete
   - **N**: Keep  
   - **R**: Redisplay
   - **U**: Undo
   - **Q**: Quit

## ⚙️ Configuration

### GUI Settings
Access via Settings button in the app:
- Minimum file size threshold
- Custom folder paths
- Scan preferences

### Terminal Configuration
Edit `~/.ezimagecleaner/config`:
```bash
MIN_SIZE=300k          # Minimum file size
CACHE_DURATION=3600    # Cache duration in seconds
PREVIEW_DELAY=0.5      # Preview display delay
PAGE_SIZE=10           # Folders per page
```

## 🖼️ Supported Formats

- JPG/JPEG
- PNG
- GIF
- BMP
- TIFF
- WebP
- HEIC
- AVIF

## 🛡️ Privacy & Security

- **No network access**: Completely offline
- **No analytics**: Your data stays private
- **Open source**: Inspect the code yourself
- **Sandboxed**: Limited system access

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📋 Development

### Project Structure
```
EzImageCleaner/
├── Source/
│   ├── Scripts/      # Terminal mode scripts
│   └── SwiftUI/      # GUI application
├── Resources/        # Icons and assets
├── Documentation/    # User guides
└── Installer/        # Build scripts
```

### Building

```bash
# Debug build
xcodebuild -configuration Debug

# Release build
xcodebuild -configuration Release

# Create DMG
./Installer/create_dmg.sh
```

## 🐛 Troubleshooting

### App won't open
- Right-click and select "Open" the first time
- Check System Preferences > Security & Privacy

### Terminal mode issues
- Ensure Terminal has Full Disk Access in System Preferences
- Try running with explicit bash: `bash /path/to/script.sh`

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Koichi Okawa**
- GitHub: [@daiokawa](https://github.com/daiokawa)
- Twitter: [@daiokawa](https://x.com/daiokawa)

## 🙏 Acknowledgments

- Thanks to the macOS community for feedback and suggestions
- Inspired by the need to manage ever-growing screenshot folders
- Built with SwiftUI and love ❤️

## 📊 Stats

![GitHub Stars](https://img.shields.io/github/stars/daiokawa/EzImageCleaner?style=social)
![GitHub Forks](https://img.shields.io/github/forks/daiokawa/EzImageCleaner?style=social)
![GitHub Watchers](https://img.shields.io/github/watchers/daiokawa/EzImageCleaner?style=social)

---

<p align="center">Made with ❤️ for the macOS community</p>