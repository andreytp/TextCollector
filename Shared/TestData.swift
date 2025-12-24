import Foundation
internal import CoreData

/// Helper to create sample data for testing and previews
struct TestData {
    
    /// Create sample snippets for testing
    static func createSampleSnippets(in context: NSManagedObjectContext) {
        let samples = [
            (content: "The only way to do great work is to love what you do.", source: "Steve Jobs", category: "Inspiration", tags: ["motivation", "work"]),
            (content: "In the middle of difficulty lies opportunity.", source: "Albert Einstein", category: "Philosophy", tags: ["opportunity", "wisdom"]),
            (content: "Success is not final, failure is not fatal: it is the courage to continue that counts.", source: "Winston Churchill", category: "Motivation", tags: ["success", "courage"]),
            (content: "import SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n        Text(\"Hello, World!\")\n    }\n}", source: "Xcode", category: "Code", tags: ["swift", "swiftui"]),
            (content: "Life is what happens when you're busy making other plans.", source: "John Lennon", category: "Life", tags: ["life", "wisdom"])
        ]
        
        for (index, sample) in samples.enumerated() {
            let snippet = TextSnippet.create(
                content: sample.content,
                source: sample.source,
                category: sample.category,
                tags: sample.tags,
                isFavorite: index % 2 == 0,
                in: context
            )
            
            // Add notes to some snippets
            if index == 0 {
                snippet.notes = "Great quote to remember when feeling unmotivated"
            } else if index == 3 {
                snippet.notes = "Basic SwiftUI template - useful for quick reference"
            }
        }
        
        // Save context
        try? context.save()
    }
    
    /// Clear all data (useful for testing)
    static func clearAllData(in context: NSManagedObjectContext) {
        // Delete all snippets
        let snippetFetch: NSFetchRequest<NSFetchRequestResult> = TextSnippet.fetchRequest()
        let snippetDelete = NSBatchDeleteRequest(fetchRequest: snippetFetch)
        try? context.execute(snippetDelete)
        
        // Delete all tags
        let tagFetch: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        let tagDelete = NSBatchDeleteRequest(fetchRequest: tagFetch)
        try? context.execute(tagDelete)
        
        try? context.save()
    }
}
