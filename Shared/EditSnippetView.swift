//
//  EditSnippetView.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import SwiftUI
internal import CoreData

struct EditSnippetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var snippet: TextSnippet
    
    @State private var content = ""
    @State private var source = ""
    @State private var category = ""
    @State private var tagsInput = ""
    @State private var notes = ""
    @State private var isFavorite = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                
                Section("Details") {
                    TextField("Source (optional)", text: $source)
                    
                    TextField("Category (optional)", text: $category)
                    
                    TextField("Tags (comma-separated)", text: $tagsInput)
                        .noTextInputAutocapitalization()
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
                
                Section {
                    Toggle("Mark as Favorite", isOn: $isFavorite)
                }
            }
            .navigationTitle("Edit Snippet")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(content.isEmpty)
                }
            }
            .onAppear {
                loadSnippetData()
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadSnippetData() {
        content = snippet.content ?? ""
        source = snippet.source ?? ""
        category = snippet.category ?? ""
        tagsInput = snippet.tagNames.joined(separator: ", ")
        notes = snippet.notes ?? ""
        isFavorite = snippet.isFavorite
    }
    
    private func saveChanges() {
        snippet.content = content
        snippet.source = source.isEmpty ? nil : source
        snippet.category = category.isEmpty ? nil : category
        snippet.notes = notes.isEmpty ? nil : notes
        snippet.isFavorite = isFavorite
        snippet.lastModified = Date()
        
        // Update tags
        let newTags = tagsInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Remove all existing tags
        if let existingTags = snippet.tags as? Set<Tag> {
            existingTags.forEach { snippet.removeFromTags($0) }
        }
        
        // Add new tags
        for tagName in newTags {
            let tag = Tag.findOrCreate(name: tagName, in: viewContext)
            snippet.addToTags(tag)
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}

private extension View {
    @ViewBuilder
    func noTextInputAutocapitalization() -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            self.textInputAutocapitalization(.never)
        } else {
            self.autocapitalization(.none)
        }
        #else
        self
        #endif
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let snippet = TextSnippet.create(
        content: "Sample content to edit",
        source: "Test",
        category: "Preview",
        tags: ["test", "preview"],
        in: context
    )
    
    return EditSnippetView(snippet: snippet)
        .environment(\.managedObjectContext, context)
}

