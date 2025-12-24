//
//  SnippetRowView.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import SwiftUI
internal import CoreData

struct SnippetRowView: View {
    @ObservedObject var snippet: TextSnippet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Content preview
            Text(snippet.content ?? "")
                .font(.body)
                .lineLimit(3)
            
            // Metadata row
            HStack(spacing: 12) {
                // Timestamp
                Text(snippet.timestamp?.formatted(date: .abbreviated, time: .shortened) ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Category badge
                if let category = snippet.category, !category.isEmpty {
                    categoryBadge(category)
                }
                
                Spacer()
                
                // Favorite indicator
                if snippet.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            // Tags
            if !snippet.tagNames.isEmpty {
                tagsList
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Subviews
    
    private func categoryBadge(_ category: String) -> some View {
        Text(category)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.15))
            .foregroundColor(.blue)
            .cornerRadius(8)
    }
    
    private var tagsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(snippet.tagNames, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.primary)
                        .cornerRadius(6)
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let snippet = TextSnippet.create(
        content: "This is a sample snippet with some interesting content that might span multiple lines.",
        source: "Preview",
        category: "Notes",
        tags: ["swift", "ios", "development"],
        isFavorite: true,
        in: context
    )
    
    return List {
        SnippetRowView(snippet: snippet)
    }
    .listStyle(.insetGrouped)
}
