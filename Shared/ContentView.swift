
import SwiftUI
internal import CoreData

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        SnippetListView()
        #elseif os(macOS)
        MacOSContentView()
        #endif
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
