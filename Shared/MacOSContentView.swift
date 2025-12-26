import SwiftUI
import CoreData

struct MacOSContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TextSnippet.timestamp, ascending: false)],
        animation: .default)
    private var snippets: FetchedResults<TextSnippet>
    
    @State private var selectedSnippet: TextSnippet?
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var filterOption: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
    }
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            if let snippet = selectedSnippet {
                MacOSDetailView(snippet: snippet)
            } else {
                emptyDetailView
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search snippets")
        .sheet(isPresented: $showingAddSheet) {
            AddSnippetView()
        }
    }
    
    // MARK: - Sidebar
    
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            // Filter picker
            Picker("Filter", selection: $filterOption) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            // Snippets list
            if filteredSnippets.isEmpty {
                emptyStateView
            } else {
                snippetsList
            }
        }
        .navigationTitle("Text Collector")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Snippet", systemImage: "plus")
                }
            }
        }
    }
    
    private var snippetsList: some View {
        List(selection: $selectedSnippet) {
            ForEach(filteredSnippets) { snippet in
                MacOSSidebarRow(snippet: snippet)
                    .tag(snippet)
            }
            .onDelete(perform: deleteSnippets)
        }
        .listStyle(.sidebar)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Snippets")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add snippets using Shortcuts\nor click + to create one")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddSheet = true }) {
                Label("Add Snippet", systemImage: "plus.circle.fill")
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var emptyDetailView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sidebar.left")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Select a Snippet")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Choose a snippet from the sidebar to view its details")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    // MARK: - Computed Properties
    
    private var filteredSnippets: [TextSnippet] {
        var result = Array(snippets)
        
        // Apply filter
        switch filterOption {
        case .all:
            break
        case .favorites:
            result = result.filter { $0.isFavorite }
        case .recent:
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            result = result.filter { ($0.timestamp ?? Date()) >= sevenDaysAgo }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter { snippet in
                snippet.content?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        return result
    }
    
    // MARK: - Actions
    
    private func deleteSnippets(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredSnippets[$0] }.forEach { snippet in
                viewContext.delete(snippet)
                if selectedSnippet == snippet {
                    selectedSnippet = nil
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting snippet: \(error)")
            }
        }
    }
}

#Preview {
    MacOSContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .frame(width: 900, height: 600)
}