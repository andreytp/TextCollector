//
//  AddSnippetIntent.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import AppIntents
internal import CoreData

/// App Intent for adding text snippets via Shortcuts
struct AddSnippetIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Text Snippet"
    static var description = IntentDescription("Save selected text to Text Collector")
    
    // MARK: - Parameters
    
    @Parameter(title: "Text", description: "The text content to save")
    var text: String
    
    @Parameter(title: "Source", description: "Where the text came from (optional)")
    var source: String?
    
    @Parameter(title: "Category", description: "Category to organize the snippet (optional)")
    var category: String?
    
    @Parameter(title: "Tags", description: "Tags to add (comma-separated)")
    var tags: String?
    
    @Parameter(title: "Mark as Favorite", default: false)
    var isFavorite: Bool
    
    // MARK: - Perform
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Get the persistent container
        let context = PersistenceController.shared.container.viewContext
        
        // Parse tags from comma-separated string
        let tagArray = parseTags(from: tags)
        
        // Create the snippet
        let snippet = TextSnippet.create(
            content: text,
            source: source,
            category: category,
            tags: tagArray,
            isFavorite: isFavorite,
            in: context
        )
        
        // Save to Core Data
        do {
            try context.save()
            
            // Return success message
            let message = "Snippet saved successfully!"
            return .result(dialog: IntentDialog(stringLiteral: message))
            
        } catch {
            // Return error message
            let errorMessage = "Failed to save snippet: \(error.localizedDescription)"
            return .result(dialog: IntentDialog(stringLiteral: errorMessage))
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseTags(from tagsString: String?) -> [String] {
        guard let tagsString = tagsString, !tagsString.isEmpty else {
            return []
        }
        
        return tagsString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
