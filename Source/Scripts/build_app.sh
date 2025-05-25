#!/bin/bash
# Build script for EzImageCleaner GUI App

echo "Building EzImageCleaner GUI App..."

# Create Xcode project structure
mkdir -p EzImageCleanerApp.xcodeproj
cat > EzImageCleanerApp.xcodeproj/project.pbxproj << 'EOF'
// This is a simplified project file
// In practice, you would use Xcode to generate this
{
    archiveVersion = 1;
    classes = {};
    objectVersion = 56;
    rootObject = "PROJECT_ID";
}
EOF

# For now, let's create a simple launcher that shows both modes
cat > run_gui_demo.swift << 'EOF'
#!/usr/bin/swift
import Cocoa
import SwiftUI

// Simplified demo view
struct DemoView: View {
    @State private var selectedMode = 0
    @State private var minSize = 300.0
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with bear icon placeholder
            HStack {
                Text("🐻")
                    .font(.system(size: 50))
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
            
            // Mode selector
            Picker("Mode", selection: $selectedMode) {
                Text("GUI Mode").tag(0)
                Text("Terminal Mode").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Size selector
            VStack(alignment: .leading) {
                Text("Minimum Size: \(Int(minSize)) KB")
                    .font(.headline)
                Slider(value: $minSize, in: 100...5000, step: 100)
            }
            .padding()
            
            // Mode-specific content
            if selectedMode == 0 {
                VStack {
                    Text("GUI Mode Preview")
                        .font(.title2)
                    Text("• Visual image browser")
                    Text("• Click to select folders")
                    Text("• Keyboard shortcuts (Y/N)")
                    Text("• Progress tracking")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            } else {
                VStack {
                    Text("Terminal Mode")
                        .font(.title2)
                    Text("• Fast keyboard navigation")
                    Text("• Minimal resource usage")
                    Text("• Batch processing")
                    Text("• Original experience")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            
            // Action button
            Button(action: {
                showAlert = true
            }) {
                Text(selectedMode == 0 ? "Start GUI Mode" : "Launch Terminal")
                    .frame(width: 200)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .frame(width: 600, height: 500)
        .alert("Demo Mode", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text("This is a demo. The full app would \(selectedMode == 0 ? "show the image browser" : "launch the terminal script").")
        }
    }
}

// App delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = DemoView()
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.title = "EzImageCleaner"
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
EOF

chmod +x run_gui_demo.swift

echo "Build complete!"
echo ""
echo "To run the GUI demo:"
echo "  ./run_gui_demo.swift"
echo ""
echo "To run the terminal version:"
echo "  ./ezimagecleaner_v2.sh"
echo ""
echo "Note: For a full macOS app, you would need to:"
echo "1. Open Xcode"
echo "2. Create a new SwiftUI macOS app"
echo "3. Copy the Swift files into the project"
echo "4. Add the app icon"
echo "5. Build and run"