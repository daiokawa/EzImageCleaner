import SwiftUI

@main
struct EzImageCleanerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, idealWidth: 1000, minHeight: 600, idealHeight: 700)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    // Add update check logic
                }
            }
        }
    }
}

// Custom window style for cleaner appearance
struct HiddenTitleBarWindowStyle: WindowStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(VisualEffectView())
    }
}

// Visual effect for window background
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .sidebar
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}