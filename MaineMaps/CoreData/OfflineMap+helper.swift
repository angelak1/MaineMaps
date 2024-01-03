//
//  OfflineMap+helper.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import Foundation
import CoreData
import ArcGIS

/// OfflineMap is the core data model for the map that is used when offline
extension OfflineMap {
    /// Wrapper for optional title string
    var title: String {
        get { title_ ?? ""  }
        set { title_ = newValue }
    }
    
    /// Wrapper for optional snippet string
    var snippet: String {
        get { snippet_ ?? "" }
        set { snippet_ = newValue }
    }

    /// Initializes an offlineMap
    /// - Parameter id: the unique idenitifier of the offline map
    /// - Parameter title: the title that is displayed for the offline map
    /// - Parameter snippet: the snippet containing details about the offline map
    /// - Parameter context: the object space to manipulate and track changes to managed objects
    convenience init(id: String, title: String, snippet: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = id
        self.title = title
        self.snippet = snippet
    }
    
    /// Deletes an offlineMap from Core Data
    static func delete(map: OfflineMap) {
        guard let context = map.managedObjectContext else { return }
        context.delete(map)
    }
    
    /// Fetches offlineMaps from Core Data
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<OfflineMap> {
        let request = OfflineMap.fetchRequest()
        request.sortDescriptors = []
        request.predicate = predicate
        return request
    }

    
    //MARK: - Preview helpers
    
    /// Bangor map example used for previews and tests
    static var example1: OfflineMap {
        let context = PersistenceController.preview.container.viewContext
        let map = OfflineMap(id: "e26115e1fb1343c39fbd2970fd9d3792", title: "Bangor", snippet: "Bangor is a city in the U.S. state of Maine, and the county seat of Penobscot County. The city proper has a population of 33,039, making it the state's 3rd largest settlement.", context: context)
        return map
    }

    /// Greater Portland map example used for previews and tests
    static var example2: OfflineMap {
        let context = PersistenceController.preview.container.viewContext
        let map = OfflineMap(id: "5dbbd50464b546a1ae4e39236f5fafa0", title: "Greater Portland", snippet: "The Greater Portland metropolitan area is home to over half a million people, more than one-third of Maine's total population, making it the most populous metro in northern New England.", context: context)
        return map
    }
    
}
