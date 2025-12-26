import SwiftUI
import AppIntents
internal import CoreData

@main
struct TextCollectorApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        // Main window scene
        #if os(macOS)
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 900, height: 600)
        #else
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        #endif
        
        // Settings window (macOS only)
        #if os(macOS)
        Settings {
            SettingsView()
        }
        
        // Commands (macOS only)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Snippet") {
                    // This will be handled by the view
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        #endif
    }
}

// MARK: - App Intent Configuration
extension TextCollectorApp {
    static var appIntents: [any AppIntent.Type] {
        [AddSnippetIntent.self]
    }
}
