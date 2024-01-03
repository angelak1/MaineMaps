//
//  MapsListView.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/28/23.
//

import ArcGIS
import CoreData
import SwiftUI

struct MapsListView: View {
    @EnvironmentObject var mapsViewModel: MapsViewModel
    @FetchRequest(fetchRequest: OfflineMap.fetch(), animation: .bouncy)
    var offlineMaps: FetchedResults<OfflineMap>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let mainMap = mapsViewModel.mainMap {
                    Section("Web Map") {
                        Divider()
                        NavigationLink {
                            FullScreenMapView(mapItem: mainMap)
                        } label: {
                            MapListItemView(mapItem: mainMap)
                        }
                        Divider()
                    }.isVisible(mapsViewModel.networkManager.isOnline)
                }
        
                
                Section("Map Areas") {
                    ForEach(offlineMaps) { offlineMap in
                        Divider()
                        NavigationLink {
                            OfflineFullScreenMapView(map: mapsViewModel.getExistingMapIfAvailable(id: offlineMap.id))
                        } label: {
                            OfflineMapListItemView(mapItem: offlineMap)
                        }
                    }
                    Divider()
                }.isVisible(!mapsViewModel.networkManager.isOnline && !offlineMaps.isEmpty)
            
                Text("It looks like it's your first time here, and we can't detect an internet connect. \u{2639} \n\n Please connect to the internet and then restart the app")
                    .isVisible(!mapsViewModel.networkManager.isOnline && offlineMaps.isEmpty)
                    
                Section("Map Areas") {
                    ForEach(mapsViewModel.mapAreas) { map in
                        Divider()
                        NavigationLink {
                            FullScreenMapView(mapItem: map)
                        } label: {
                            MapListItemView(mapItem: map)
                        }
                    }
                    Divider()
                }.isVisible(mapsViewModel.networkManager.isOnline)
            }.navigationTitle("Explore Maine")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MapsListView().environmentObject(MapsViewModel(service: MockAPIService()))
}
