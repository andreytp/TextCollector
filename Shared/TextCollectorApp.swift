import SwiftUI
import AppIntents
internal import CoreData

@main
struct TextCollectorApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// MARK: - App Intent Configuration
// This makes the app discoverable by Shortcuts
extension TextCollectorApp {
    static var appIntents: [any AppIntent.Type] {
        [AddSnippetIntent.self]
    }
}
