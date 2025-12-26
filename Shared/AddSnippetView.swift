//
//  AddSnippetView.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import SwiftUI
internal import CoreData

struct AddSnippetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var content = ""
    @State private var source = ""
    @State private var category = ""
    @State private var tagsInput = ""
    @State private var notes = ""
    @State private var isFavorite = false
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case content
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .content)
                }
                
                Section("Details") {
                    TextField("Source (optional)", text: $source)
                    
                    TextField("Category (optional)", text: $category)
                    
                    TextField("Tags (comma-separated)", text: $tagsInput)
#if os(iOS)
    if #available(iOS 16.0, *) {
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
    } else {
        .autocapitalization(.none)
        .disableAutocorrection(true)
    }
#endif
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
                
                Section {
                    Toggle("Mark as Favorite", isOn: $isFavorite)
                }
            }
            .navigationTitle("New Snippet")
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
                        saveSnippet()
                    }
                    .disabled(content.isEmpty)
                }
            }
            .onAppear {
                focusedField = .content
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveSnippet() {
        let tags = tagsInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let snippet = TextSnippet.create(
            content: content,
            source: source.isEmpty ? nil : source,
            category: category.isEmpty ? nil : category,
            tags: tags,
            isFavorite: isFavorite,
            in: viewContext
        )
        
        if !notes.isEmpty {
            snippet.notes = notes
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving snippet: \(error)")
        }
    }
}

#Preview {
    AddSnippetView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
