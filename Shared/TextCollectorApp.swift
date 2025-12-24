//
//  TextCollectorApp.swift
//  TextCollector
//
//  Created by   andriik0 on 12/23/25.
//

import SwiftUI
import CoreData

@main
struct TextCollectorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
