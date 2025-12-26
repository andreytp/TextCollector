//
//  MacOSSidebarRow.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import SwiftUI
internal import CoreData

struct MacOSSidebarRow: View {
    @ObservedObject var snippet: TextSnippet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Content preview
            Text(snippet.content ?? "")
                .font(.body)
                .lineLimit(2)
            
            // Metadata row
            HStack(spacing: 8) {
                // Timestamp
                if let timestamp = snippet.timestamp {
                    Text(timestamp.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Category
                if let category = snippet.category, !category.isEmpty {
                    Text("• \(category)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Favorite star
                if snippet.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
            }
            
            // Tags (if any)
            if !snippet.tagNames.isEmpty {
                HStack(spacing: 4) {
                    ForEach(snippet.tagNames.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    if snippet.tagNames.count > 3 {
                        Text("+\(snippet.tagNames.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let snippet = TextSnippet.create(
        content: "This is a sample snippet for the macOS sidebar",
        category: "Notes",
        tags: ["swift", "macos", "sidebar"],
        isFavorite: true,
        in: context
    )
    
    return List {
        MacOSSidebarRow(snippet: snippet)
    }
    .listStyle(.sidebar)
}
