import Foundation
internal import CoreData

// MARK: - TextSnippet Convenience Extensions
extension TextSnippet {
    
    /// Computed property to get tags as an array of strings
    var tagNames: [String] {
        let tagSet = tags as? Set<Tag> ?? []
        return tagSet.compactMap { $0.name }.sorted()
    }
    
    /// Safe unwrapped properties
    var safeId: UUID {
        id ?? UUID()
    }
    
    var safeContent: String {
        content ?? ""
    }
    
    var safeTimestamp: Date {
        timestamp ?? Date()
    }
    
    var safeLastModified: Date {
        lastModified ?? Date()
    }
    
    /// Convenience initializer for creating new snippets
    static func create(
        content: String,
        source: String? = nil,
        category: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        in context: NSManagedObjectContext
    ) -> TextSnippet {
        let snippet = TextSnippet(context: context)
        
        // ALWAYS set these required values
        snippet.id = UUID()
        snippet.content = content
        snippet.timestamp = Date()
        snippet.lastModified = Date()
        snippet.isFavorite = isFavorite
        
        // Set optional values
        snippet.source = source
        snippet.category = category
        
        // Add tags
        for tagName in tags {
            let tag = Tag.findOrCreate(name: tagName, in: context)
            snippet.addToTags(tag)
        }
        
        return snippet
    }
    
    /// Update snippet content and timestamp
    func update(content: String) {
        self.content = content
        self.lastModified = Date()
    }
    
    /// Add a tag by name
    func addTag(name: String, in context: NSManagedObjectContext) {
        let tag = Tag.findOrCreate(name: name, in: context)
        addToTags(tag)
        lastModified = Date()
    }
    
    /// Remove a tag by name
    func removeTag(name: String) {
        let tagSet = tags as? Set<Tag> ?? []
        if let tag = tagSet.first(where: { $0.name == name }) {
            removeFromTags(tag)
            lastModified = Date()
        }
    }
}

// MARK: - Tag Convenience Extensions
extension Tag {
    
    /// Safe unwrapped name
    var safeName: String {
        name ?? ""
    }
    
    /// Find existing tag or create new one
    static func findOrCreate(name: String, in context: NSManagedObjectContext) -> Tag {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        
        if let existingTag = try? context.fetch(fetchRequest).first {
            return existingTag
        }
        
        // Create new tag - ALWAYS set required values
        let newTag = Tag(context: context)
        newTag.id = UUID()
        newTag.name = name
        return newTag
    }
    
    /// Get all unique tags sorted alphabetically
    static func fetchAll(in context: NSManagedObjectContext) -> [Tag] {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        
        return (try? context.fetch(fetchRequest)) ?? []
    }
}

// MARK: - Fetch Request Helpers
extension TextSnippet {
    
    /// Fetch all snippets sorted by date (newest first)
    static func fetchAllSnippets(in context: NSManagedObjectContext) -> [TextSnippet] {
        let fetchRequest: NSFetchRequest<TextSnippet> = TextSnippet.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TextSnippet.timestamp, ascending: false)]
        
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    /// Fetch favorites only
    static func fetchFavorites(in context: NSManagedObjectContext) -> [TextSnippet] {
        let fetchRequest: NSFetchRequest<TextSnippet> = TextSnippet.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TextSnippet.timestamp, ascending: false)]
        
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    /// Search snippets by content
    static func search(_ query: String, in context: NSManagedObjectContext) -> [TextSnippet] {
        guard !query.isEmpty else {
            return fetchAllSnippets(in: context)
        }
        
        let fetchRequest: NSFetchRequest<TextSnippet> = TextSnippet.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "content CONTAINS[cd] %@", query)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TextSnippet.timestamp, ascending: false)]
        
        return (try? context.fetch(fetchRequest)) ?? []
    }
}
