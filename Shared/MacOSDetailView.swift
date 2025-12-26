//
//  MacOSDetailView.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import SwiftUI
internal import CoreData
#if canImport(AppKit)
import AppKit
#endif

struct MacOSDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var snippet: TextSnippet
    
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with actions
                headerSection
                
                Divider()
                
                // Content
                contentSection
                
                // Metadata
                metadataSection
                
                // Tags
                if !snippet.tagNames.isEmpty {
                    tagsSection
                }
                
                // Notes
                if let notes = snippet.notes, !notes.isEmpty {
                    notesSection(notes)
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
#if canImport(AppKit)
        .background(Color(NSColor.textBackgroundColor))
#else
        .background(Color(.systemBackground))
#endif
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
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Snippet Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let timestamp = snippet.timestamp {
                    Text("Created \(timestamp.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: toggleFavorite) {
                    Image(systemName: snippet.isFavorite ? "star.fill" : "star")
                        .foregroundColor(snippet.isFavorite ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
                .help(snippet.isFavorite ? "Unfavorite" : "Favorite")
                
                Button(action: copyToClipboard) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
                .help("Copy to Clipboard")
                
                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.plain)
                .help("Edit")
                
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete")
            }
            .font(.title3)
        }
    }
    
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
#if canImport(AppKit)
                .background(Color(NSColor.controlBackgroundColor))
#else
                .background(Color(.secondarySystemBackground))
#endif
                .cornerRadius(8)
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 0) {
                if let source = snippet.source, !source.isEmpty {
                    metadataRow(label: "Source", value: source, icon: "doc.text")
                    Divider().padding(.leading, 32)
                }
                
                if let category = snippet.category, !category.isEmpty {
                    metadataRow(label: "Category", value: category, icon: "folder")
                    Divider().padding(.leading, 32)
                }
                
                if let lastModified = snippet.lastModified {
                    metadataRow(
                        label: "Last Modified",
                        value: lastModified.formatted(date: .abbreviated, time: .shortened),
                        icon: "arrow.clockwise"
                    )
                }
            }
#if canImport(AppKit)
            .background(Color(NSColor.controlBackgroundColor))
#else
            .background(Color(.secondarySystemBackground))
#endif
            .cornerRadius(8)
        }
    }
    
    private func metadataRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .font(.subheadline)
        .padding(.vertical, 8)
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
    
    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(notes)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
#if canImport(AppKit)
                .background(Color(NSColor.controlBackgroundColor))
#else
                .background(Color(.secondarySystemBackground))
#endif
                .cornerRadius(8)
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
    
    private func copyToClipboard() {
        #if canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(snippet.content ?? "", forType: .string)
        #else
        // AppKit is not available on this platform. Consider adding a platform-specific implementation (e.g., UIPasteboard on iOS).
        #endif
    }
    
    private func deleteSnippet() {
        viewContext.delete(snippet)
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting snippet: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let snippet = TextSnippet.create(
        content: "This is a detailed preview of a snippet for macOS with comprehensive content.",
        source: "Preview App",
        category: "Testing",
        tags: ["preview", "test", "macos"],
        isFavorite: true,
        in: context
    )
    snippet.notes = "These are some notes about this snippet."
    
    return MacOSDetailView(snippet: snippet)
        .environment(\.managedObjectContext, context)
        .frame(width: 600, height: 700)
}
