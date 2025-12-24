import Foundation
internal import CoreData

/// Centralized manager for snippet operations
class SnippetManager {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Create
    
    /// Add a new snippet
    func addSnippet(
        content: String,
        source: String? = nil,
        category: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false
    ) throws -> TextSnippet {
        let snippet = TextSnippet.create(
            content: content,
            source: source,
            category: category,
            tags: tags,
            isFavorite: isFavorite,
            in: context
        )
        
        try save()
        return snippet
    }
    
    // MARK: - Update
    
    /// Update snippet content
    func updateContent(snippet: TextSnippet, content: String) throws {
        snippet.update(content: content)
        try save()
    }
    
    /// Toggle favorite status
    func toggleFavorite(snippet: TextSnippet) throws {
        snippet.isFavorite.toggle()
        snippet.lastModified = Date()
        try save()
    }
    
    /// Update category
    func updateCategory(snippet: TextSnippet, category: String?) throws {
        snippet.category = category
        snippet.lastModified = Date()
        try save()
    }
    
    /// Update notes
    func updateNotes(snippet: TextSnippet, notes: String?) throws {
        snippet.notes = notes
        snippet.lastModified = Date()
        try save()
    }
    
    /// Add tag to snippet
    func addTag(to snippet: TextSnippet, tagName: String) throws {
        snippet.addTag(name: tagName, in: context)
        try save()
    }
    
    /// Remove tag from snippet
    func removeTag(from snippet: TextSnippet, tagName: String) throws {
        snippet.removeTag(name: tagName)
        try save()
    }
    
    // MARK: - Delete
    
    /// Delete a snippet
    func deleteSnippet(_ snippet: TextSnippet) throws {
        context.delete(snippet)
        try save()
    }
    
    /// Delete multiple snippets
    func deleteSnippets(_ snippets: [TextSnippet]) throws {
        snippets.forEach { context.delete($0) }
        try save()
    }
    
    // MARK: - Fetch
    
    /// Get all snippets
    func fetchAllSnippets() -> [TextSnippet] {
        return TextSnippet.fetchAllSnippets(in: context)
    }
    
    /// Get favorite snippets
    func fetchFavorites() -> [TextSnippet] {
        return TextSnippet.fetchFavorites(in: context)
    }
    
    /// Search snippets
    func searchSnippets(query: String) -> [TextSnippet] {
        return TextSnippet.search(query, in: context)
    }
    
    /// Get all tags
    func fetchAllTags() -> [Tag] {
        return Tag.fetchAll(in: context)
    }
    
    // MARK: - Statistics
    
    /// Get total snippet count
    func getTotalCount() -> Int {
        let fetchRequest: NSFetchRequest<TextSnippet> = TextSnippet.fetchRequest()
        return (try? context.count(for: fetchRequest)) ?? 0
    }
    
    /// Get favorite count
    func getFavoriteCount() -> Int {
        let fetchRequest: NSFetchRequest<TextSnippet> = TextSnippet.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
        return (try? context.count(for: fetchRequest)) ?? 0
    }
    
    // MARK: - Private Helpers
    
    private func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
