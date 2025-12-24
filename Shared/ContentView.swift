
import SwiftUI
internal import CoreData

struct ContentView: View {
    var body: some View {
        SnippetListView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
