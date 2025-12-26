//
//  SnippetDetailView.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import SwiftUI
internal import CoreData

struct SnippetDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var snippet: TextSnippet
    
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Content
                contentSection
                
                // Metadata
                metadataSection
                
                // Tags
                if !snippet.tagNames.isEmpty {
                    tagsSection
                }
                
                // Notes
                notesSection
            }
            .padding()
        }
        .navigationTitle("Snippet")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: toggleFavorite) {
                        Label(
                            snippet.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: snippet.isFavorite ? "star.slash" : "star"
                        )
                    }
                    
                    Button(action: { isEditing = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    ShareLink(item: snippet.content ?? "") {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditSnippetView(snippet: snippet)
        }
        .alert("Delete Snippet", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: deleteSnippet)
        } message: {
            Text("Are you sure you want to delete this snippet? This action cannot be undone.")
        }
    }
    
    // MARK: - Subviews
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Content")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(snippet.content ?? "")
                .font(.body)
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            #if os(iOS)
                .background(Color(.secondarySystemBackground))
            #endif
                .cornerRadius(12)
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                if let source = snippet.source, !source.isEmpty {
                    metadataRow(label: "Source", value: source, icon: "doc.text")
                }
                
                if let category = snippet.category, !category.isEmpty {
                    metadataRow(label: "Category", value: category, icon: "folder")
                }
                
                metadataRow(
                    label: "Created",
                    value: snippet.timestamp?.formatted(date: .long, time: .shortened) ?? "",
                    icon: "clock"
                )
                
                metadataRow(
                    label: "Modified",
                    value: snippet.lastModified?.formatted(date: .long, time: .shortened) ?? "",
                    icon: "arrow.clockwise"
                )
            }
            .padding()
            #if os(iOS)
            .background(Color(.secondarySystemBackground))
            #endif
            .cornerRadius(12)
        }
    }
    
    private func metadataRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
        }
        .font(.subheadline)
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(.secondary)
            
            FlowLayout(spacing: 8) {
                ForEach(snippet.tagNames, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let notes = snippet.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                #if os(iOS)
                    .background(Color(.secondarySystemBackground))
                #endif
                    .cornerRadius(12)
            } else {
                Text("No notes")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleFavorite() {
        withAnimation {
            snippet.isFavorite.toggle()
            snippet.lastModified = Date()
            
            do {
                try viewContext.save()
            } catch {
                print("Error toggling favorite: \(error)")
            }
        }
    }
    
    private func deleteSnippet() {
        viewContext.delete(snippet)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error deleting snippet: \(error)")
        }
    }
}

// MARK: - Flow Layout Helper
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > width && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
                size.width = max(size.width, currentX - spacing)
            }
            
            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let snippet = TextSnippet.create(
        content: "This is a detailed preview of a snippet with lots of content to demonstrate the detail view.",
        source: "Preview App",
        category: "Testing",
        tags: ["preview", "test", "ios"],
        isFavorite: true,
        in: context
    )
    snippet.notes = "These are some notes about this snippet for testing purposes."
    
    return NavigationStack {
        SnippetDetailView(snippet: snippet)
    }
    .environment(\.managedObjectContext, context)
}
