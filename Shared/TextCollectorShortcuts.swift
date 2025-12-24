//
//  TextCollectorShortcuts.swift
//  TextCollector
//
//  Created by   andriik0 on 12/24/25.
//


import AppIntents

/// Provides suggested shortcuts for the Shortcuts app
struct TextCollectorShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddSnippetIntent(),
            phrases: [
                "Add to \(.applicationName)",
                "Save text to \(.applicationName)",
                "Collect text in \(.applicationName)"
            ],
            shortTitle: "Add Snippet",
            systemImageName: "doc.text"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor = .blue
}