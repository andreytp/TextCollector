//
//  SnippetListView.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import SwiftUI
internal import CoreData

struct SnippetListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TextSnippet.timestamp, ascending: false)],
        animation: .default)
    private var snippets: FetchedResults<TextSnippet>
    
    @State private var searchText = ""
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if snippets.isEmpty {
                    emptyStateView
                } else {
                    snippetsList
                }
            }
            .navigationTitle("Text Collector")
            .searchable(text: $searchText, prompt: "Search snippets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Label("Add Snippet", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddSnippetView()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var snippetsList: some View {
        List {
            ForEach(filteredSnippets) { snippet in
                NavigationLink(destination: SnippetDetailView(snippet: snippet)) {
                    SnippetRowView(snippet: snippet)
                }
            }
            .onDelete(perform: deleteSnippets)
        }
#if os(iOS)
        .listStyle(.insetGrouped)
#else
        .listStyle(.inset)
#endif
        .refreshable {
            // Pull to refresh (context automatically refreshes)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("No Snippets Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add snippets using Shortcuts or tap + to create one manually")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddSheet = true }) {
                Label("Add Your First Snippet", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var filteredSnippets: [TextSnippet] {
        if searchText.isEmpty {
            return Array(snippets)
        } else {
            return snippets.filter { snippet in
                snippet.content?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    // MARK: - Actions
    
    private func deleteSnippets(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredSnippets[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting snippet: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    SnippetListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
