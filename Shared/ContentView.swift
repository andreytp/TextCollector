import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "doc.text")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Text Collector")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your snippets will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Text Collector")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
