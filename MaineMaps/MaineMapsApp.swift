//
//  MaineMapsApp.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/28/23.
//

import ArcGIS
import SwiftUI

@main
struct MaineMapsApp: App {
    @Environment(\.scenePhase) var scenePhase
    let persistentController = PersistenceController.shared
    let mapsViewModel = MapsViewModel()
    
    init() {
        ArcGISEnvironment.apiKey = APIKey(<#Your API Key#>)
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            MapsListView()
                .environmentObject(mapsViewModel)
                .environment(\.managedObjectContext, persistentController.container.viewContext)
                .onChange(of: scenePhase) { oldValue, newValue in
                    if newValue == .background {
                        persistentController.save()
                    }
                }
        }
    }
}
