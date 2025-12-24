//
//  Persistence.swift
//  TextCollector
//
//  Created by   andriik0 on 12/23/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // Use NSPersistentContainer for now (local only)
    // Switch to NSPersistentCloudKitContainer when Apple Developer account is active
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // TODO: Switch to NSPersistentCloudKitContainer when enrolled in Apple Developer Program
        container = NSPersistentContainer(name: "TextCollector")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure for App Group sharing (works without paid account)
            if let description = container.persistentStoreDescriptions.first {
                // Use App Group for data sharing with Shortcuts extension
                let appGroupID = "group.com.yourname.textcollector.shared"
                if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
                    let storeURL = containerURL.appendingPathComponent("TextCollector.sqlite")
                    description.url = storeURL
                }
                
                // These settings are compatible with both local and CloudKit storage
                description.setOption(true as NSNumber,
                                    forKey: NSPersistentHistoryTrackingKey)
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Handle error appropriately in production
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        // Automatically merge changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // Preview helper
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for previews
        for i in 0..<5 {
            let snippet = TextSnippet(context: viewContext)
            snippet.id = UUID()
            snippet.content = "Sample snippet \(i + 1)"
            snippet.timestamp = Date()
            snippet.isFavorite = i % 2 == 0
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}

// MARK: - Migration Guide to iCloud
/*
 When ready to enable iCloud sync (requires Apple Developer Program):
 
 1. Change NSPersistentContainer to NSPersistentCloudKitContainer
 2. Add CloudKit configuration:
    description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
        containerIdentifier: "iCloud.$(CFBundleIdentifier)"
    )
 3. Enable iCloud capability in Xcode
 4. That's it! Existing data will automatically sync
 */

