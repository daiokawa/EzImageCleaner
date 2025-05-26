#!/usr/bin/swift

import SwiftUI
import AppKit

struct EzImageCleanerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}

struct ContentView: View {
    @State private var selectedFolders: Set<String> = []
    @State private var minSizeKB: Double = 300
    @State private var isScanning = false
    @State private var statusMessage = "Ready to clean images"
    
    let commonFolders = [
        ("Downloads", NSHomeDirectory() + "/Downloads"),
        ("Desktop", NSHomeDirectory() + "/Desktop"),
        ("Documents", NSHomeDirectory() + "/Documents"),
        ("Pictures", NSHomeDirectory() + "/Pictures"),
        ("Screenshots", NSHomeDirectory() + "/Pictures/Screenshots")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("🐻")
                    .font(.system(size: 60))
                VStack(alignment: .leading) {
                    Text("EzImageCleaner")
                        .font(.largeTitle)
                        .bold()
                    Text("Clean up large images easily")
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            
            // Folder Selection
            GroupBox(label: Text("Select Folders to Scan").font(.headline)) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(commonFolders, id: \.0) { folder in
                        Toggle(folder.0, isOn: Binding(
                            get: { selectedFolders.contains(folder.1) },
                            set: { isOn in
                                if isOn {
                                    selectedFolders.insert(folder.1)
                                } else {
                                    selectedFolders.remove(folder.1)
                                }
                            }
                        ))
                    }
                }
                .padding()
            }
            
            // Size Slider
            GroupBox(label: Text("Minimum File Size").font(.headline)) {
                VStack {
                    Slider(value: $minSizeKB, in: 100...10000, step: 100)
                    Text("\(Int(minSizeKB)) KB - \(String(format: "%.1f", minSizeKB/1024)) MB")
                        .font(.system(.body, design: .monospaced))
                }
                .padding()
            }
            
            // Status
            Text(statusMessage)
                .foregroundColor(.secondary)
                .padding()
            
            // Buttons
            HStack {
                Button("Terminal Mode") {
                    launchTerminalMode()
                }
                
                Spacer()
                
                Button("Start Scanning") {
                    if selectedFolders.isEmpty {
                        statusMessage = "Please select at least one folder"
                    } else {
                        statusMessage = "GUI scanning coming soon! Try Terminal Mode for now."
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedFolders.isEmpty || isScanning)
            }
            .padding()
        }
        .padding()
    }
    
    func launchTerminalMode() {
        let script = """
        tell application "Terminal"
            activate
            do script "echo '🐻 EzImageCleaner - Terminal Mode' && echo '' && echo 'This will scan for large images...' && echo '' && cd ~/Desktop/EzImageCleaner && ./Source/Scripts/ezimagecleaner_v2.sh"
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(nil)
    }
}

// Run the app
EzImageCleanerApp.main()
