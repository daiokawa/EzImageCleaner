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
            // Header with bear icon
            HStack {
                if let iconImage = NSImage(named: "AppIcon") ?? 
                   NSImage(contentsOfFile: "/Users/KoichiOkawa/Desktop/EzImageCleaner/bear_icon.png") {
                    Image(nsImage: iconImage)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                } else {
                    Text("🐻")
                        .font(.system(size: 50))
                }
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
