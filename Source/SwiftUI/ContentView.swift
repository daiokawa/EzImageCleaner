import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var imageManager = ImageManager()
    @State private var selectedMode = 0
    @State private var minSizeKB: Double = 300
    @State private var isProcessing = false
    @State private var showingSettings = false
    @State private var showingTerminal = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
            
            // Mode Selector
            Picker("Mode", selection: $selectedMode) {
                Text("GUI Mode").tag(0)
                Text("Terminal Mode").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedMode == 0 {
                // GUI Mode
                GUIModeView(imageManager: imageManager, 
                          minSizeKB: $minSizeKB,
                          isProcessing: $isProcessing,
                          showingSettings: $showingSettings)
            } else {
                // Terminal Mode
                TerminalModeView(minSizeKB: minSizeKB)
            }
            
            // Statistics Bar
            StatisticsBar(imageManager: imageManager)
        }
        .frame(minWidth: 800, minHeight: 600)
        .sheet(isPresented: $showingSettings) {
            SettingsView(minSizeKB: $minSizeKB)
        }
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "photo.stack")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("EzImageCleaner")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Clean up large images easily")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct GUIModeView: View {
    @ObservedObject var imageManager: ImageManager
    @Binding var minSizeKB: Double
    @Binding var isProcessing: Bool
    @Binding var showingSettings: Bool
    @State private var currentImageIndex = 0
    @State private var selectedFolders: Set<String> = []
    
    let defaultFolders = [
        ("Pictures", NSString("~/Pictures").expandingTildeInPath),
        ("Downloads", NSString("~/Downloads").expandingTildeInPath),
        ("Desktop", NSString("~/Desktop").expandingTildeInPath),
        ("Documents", NSString("~/Documents").expandingTildeInPath)
    ]
    
    var body: some View {
        VStack {
            // Settings Section
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Minimum Size:")
                    Text("\(Int(minSizeKB)) KB")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Slider(value: $minSizeKB, in: 100...10000, step: 100)
                        .frame(width: 300)
                    
                    Button("Settings") {
                        showingSettings = true
                    }
                }
                
                // Folder Selection
                VStack(alignment: .leading) {
                    Text("Search Folders:")
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                        ForEach(defaultFolders, id: \.1) { name, path in
                            FolderToggle(name: name, 
                                       path: path,
                                       isSelected: selectedFolders.contains(path)) {
                                if selectedFolders.contains(path) {
                                    selectedFolders.remove(path)
                                } else {
                                    selectedFolders.insert(path)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(NSColor.controlBackgroundColor)))
            .padding()
            
            // Action Buttons
            HStack(spacing: 20) {
                Button(action: startScanning) {
                    Label("Start Scanning", systemImage: "magnifyingglass")
                        .frame(width: 150)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing || selectedFolders.isEmpty)
                
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                    
                    Text("Found \(imageManager.images.count) images")
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Image Review Section
            if !imageManager.images.isEmpty && currentImageIndex < imageManager.images.count {
                ImageReviewView(
                    image: imageManager.images[currentImageIndex],
                    currentIndex: currentImageIndex,
                    totalCount: imageManager.images.count,
                    onDelete: {
                        deleteCurrentImage()
                    },
                    onKeep: {
                        keepCurrentImage()
                    },
                    onUndo: {
                        imageManager.undoLastDeletion()
                    }
                )
            } else if imageManager.images.isEmpty && !isProcessing {
                Spacer()
                Text("No images to review")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Spacer()
        }
    }
    
    private func startScanning() {
        isProcessing = true
        currentImageIndex = 0
        
        Task {
            await imageManager.scanFolders(
                Array(selectedFolders),
                minSize: Int(minSizeKB * 1024)
            )
            isProcessing = false
        }
    }
    
    private func deleteCurrentImage() {
        guard currentImageIndex < imageManager.images.count else { return }
        
        let image = imageManager.images[currentImageIndex]
        imageManager.deleteImage(at: currentImageIndex)
        
        if currentImageIndex >= imageManager.images.count && currentImageIndex > 0 {
            currentImageIndex -= 1
        }
    }
    
    private func keepCurrentImage() {
        imageManager.keepImage(at: currentImageIndex)
        if currentImageIndex < imageManager.images.count - 1 {
            currentImageIndex += 1
        }
    }
}

struct FolderToggle: View {
    let name: String
    let path: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .blue : .secondary)
                Text(name)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ImageReviewView: View {
    let image: ImageFile
    let currentIndex: Int
    let totalCount: Int
    let onDelete: () -> Void
    let onKeep: () -> Void
    let onUndo: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Progress
            HStack {
                Text("Image \(currentIndex + 1) of \(totalCount)")
                    .font(.headline)
                
                Spacer()
                
                Text(image.url.lastPathComponent)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal)
            
            // Image Preview
            if let nsImage = NSImage(contentsOf: image.url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(10)
            }
            
            // Image Info
            HStack {
                Label(image.formattedSize, systemImage: "doc")
                Spacer()
                if let dimensions = image.dimensions {
                    Label(dimensions, systemImage: "aspectratio")
                }
                Spacer()
                Label(image.modifiedDate, systemImage: "calendar")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: 20) {
                Button(action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .frame(width: 100)
                }
                .controlSize(.large)
                .keyboardShortcut("y", modifiers: [])
                
                Button(action: onKeep) {
                    Label("Keep", systemImage: "checkmark")
                        .frame(width: 100)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .keyboardShortcut("n", modifiers: [])
                
                Button(action: onUndo) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .controlSize(.regular)
                .keyboardShortcut("z", modifiers: .command)
            }
            .padding()
        }
    }
}

struct TerminalModeView: View {
    let minSizeKB: Double
    @State private var terminalOutput = ""
    @State private var isRunning = false
    
    var body: some View {
        VStack {
            // Info
            VStack(alignment: .leading, spacing: 10) {
                Text("Terminal Mode")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("This mode runs the original terminal script with the current size threshold.")
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Current threshold:")
                    Text("\(Int(minSizeKB)) KB")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(NSColor.controlBackgroundColor)))
            .padding()
            
            // Terminal Output
            ScrollView {
                Text(terminalOutput)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color.black)
            .foregroundColor(.green)
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Control Buttons
            HStack {
                Button(action: runTerminalMode) {
                    Label("Run in Terminal", systemImage: "terminal")
                        .frame(width: 150)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .disabled(isRunning)
                
                if isRunning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                }
            }
            .padding()
        }
    }
    
    private func runTerminalMode() {
        isRunning = true
        terminalOutput = "Launching terminal mode with \(Int(minSizeKB))KB threshold...\n"
        
        // Create a temporary script with the current threshold
        let scriptPath = "/tmp/ezimagecleaner_gui_launch.sh"
        let script = """
        #!/bin/bash
        export MIN_SIZE="\(Int(minSizeKB))k"
        osascript -e 'tell app "Terminal" to do script "cd \(FileManager.default.currentDirectoryPath) && ./ezimagecleaner_v2.sh"'
        """
        
        do {
            try script.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            
            let task = Process()
            task.launchPath = "/bin/bash"
            task.arguments = [scriptPath]
            task.launch()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isRunning = false
                terminalOutput += "Terminal mode launched in new window.\n"
            }
        } catch {
            terminalOutput += "Error: \(error.localizedDescription)\n"
            isRunning = false
        }
    }
}

struct StatisticsBar: View {
    @ObservedObject var imageManager: ImageManager
    
    var body: some View {
        HStack {
            Label("\(imageManager.deletedCount) Deleted", systemImage: "trash")
                .foregroundColor(.red)
            
            Spacer()
            
            Label("\(imageManager.keptCount) Kept", systemImage: "checkmark.circle")
                .foregroundColor(.green)
            
            Spacer()
            
            Label("\(imageManager.formattedFreedSpace) Freed", systemImage: "externaldrive")
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SettingsView: View {
    @Binding var minSizeKB: Double
    @State private var customFolders: [String] = []
    @State private var newFolder = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Size Threshold
            VStack(alignment: .leading) {
                Text("Minimum File Size")
                    .font(.headline)
                
                HStack {
                    Slider(value: $minSizeKB, in: 100...10000, step: 100)
                    Text("\(Int(minSizeKB)) KB")
                        .frame(width: 80)
                }
            }
            
            Divider()
            
            // Custom Folders
            VStack(alignment: .leading) {
                Text("Custom Folders")
                    .font(.headline)
                
                List {
                    ForEach(customFolders, id: \.self) { folder in
                        Text(folder)
                    }
                    .onDelete { indices in
                        customFolders.remove(atOffsets: indices)
                    }
                }
                .frame(height: 150)
                
                HStack {
                    TextField("Add folder path", text: $newFolder)
                    Button("Add") {
                        if !newFolder.isEmpty {
                            customFolders.append(newFolder)
                            newFolder = ""
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Done") {
                    // Save settings
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}