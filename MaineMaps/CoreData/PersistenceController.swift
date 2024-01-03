//
//  PersistenceController.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: "MaineMaps")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error  as NSError? {
                fatalError("Error loading container: \(error), \(error.userInfo)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("error saving context: \(error)")
        }
    }
    
    //MARK: - SwiftUI preview helper
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        let map1 = OfflineMap(id: "e26115e1fb1343c39fbd2970fd9d3792", title: "Bangor", snippet: "Bangor is a city in the U.S. state of Maine, and the county seat of Penobscot County. The city proper has a population of 33,039, making it the state's 3rd largest settlement.", context: context)
        let map2 = OfflineMap(id: "5dbbd50464b546a1ae4e39236f5fafa0", title: "Greater Portland", snippet: "The Greater Portland metropolitan area is home to over half a million people, more than one-third of Maine's total population, making it the most populous metro in northern New England.", context: context)
        
        return controller
    }()
    
    //MARK: - Test helper
    
    static var empty: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        return controller
    }()
}
