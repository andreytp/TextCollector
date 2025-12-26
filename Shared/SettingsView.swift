//
//  SettingsView.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import SwiftUI
internal import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("defaultCategory") private var defaultCategory = ""
    @AppStorage("autoCapitalize") private var autoCapitalize = true
    
    var body: some View {
        TabView {
            generalSettings
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            dataSettings
                .tabItem {
                    Label("Data", systemImage: "internaldrive")
                }
            
            aboutSettings
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 350)
    }
    
    // MARK: - General Settings
    
    private var generalSettings: some View {
        Form {
            Section {
                TextField("Default Category", text: $defaultCategory)
                    .help("The default category for new snippets")
                
                Toggle("Auto-capitalize", isOn: $autoCapitalize)
                    .help("Automatically capitalize the first letter")
            } header: {
                Text("Defaults")
                    .font(.headline)
            }
            
            Section {
                Text("Use Shortcuts to quickly add text from anywhere")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Right-click selected text → Services → Add to Text Collector")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Quick Add")
                    .font(.headline)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    // MARK: - Data Settings
    
    private var dataSettings: some View {
        Form {
            Section {
                HStack {
                    Text("Total Snippets:")
                    Spacer()
                    Text("\(getTotalCount())")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Favorites:")
                    Spacer()
                    Text("\(getFavoriteCount())")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Storage:")
                    Spacer()
                    Text("Local")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Statistics")
                    .font(.headline)
            }
            
            Section {
                Button("Export All Snippets...") {
                    // Export functionality
                }
                
                Button("Import Snippets...") {
                    // Import functionality
                }
            } header: {
                Text("Import/Export")
                    .font(.headline)
            }
            
            Section {
                Button("Clear All Data", role: .destructive) {
                    // Clear data with confirmation
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    // MARK: - About Settings
    
    private var aboutSettings: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("Text Collector")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.horizontal, 60)
            
            Text("Collect and organize text snippets from anywhere")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("© 2024 Text Collector")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func getTotalCount() -> Int {
        let fetchRequest: NSFetchRequest<TextSnippet> = TextSnippet.fetchRequest()
        return (try? viewContext.count(for: fetchRequest)) ?? 0
    }
    
    private func getFavoriteCount() -> Int {
        let fetchRequest: NSFetchRequest<TextSnippet> = TextSnippet.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
        return (try? viewContext.count(for: fetchRequest)) ?? 0
    }
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
