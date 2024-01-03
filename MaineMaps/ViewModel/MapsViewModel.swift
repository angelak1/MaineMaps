//
//  MapsViewModel.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import ArcGIS
import CoreData
import Foundation
import SwiftUI

final class MapsViewModel: ObservableObject {
    /// The main web map
    @Published var mainMap: MapItem?
    /// The offline map areas
    @Published var mapAreas: [MapItem] = []
    @ObservedObject var networkManager = NetworkManager.shared
    
    private let portalItem = PortalItem.mainMap()
    private let service: APIServiceProtocol
    private var offlineMapsLoading: Bool = false
    private var mainMapLoading: Bool = false
    private var offlineMapTask: OfflineMapTask?
    
    init(service: APIServiceProtocol = APIService.shared) {
        self.service = service
        if networkManager.isOnline {
            self.offlineMapTask = OfflineMapTask(portalItem: portalItem)
        }

        fetchMainMap()
        fetchMapAreas()
    }
    
    func reloadOnline() {
        if offlineMapTask == nil {
            self.offlineMapTask = OfflineMapTask(portalItem: portalItem)
        }
        
        if mainMap == nil {
            self.fetchMainMap()
        }
        
        if mapAreas.isEmpty {
            self.fetchMapAreas()
        }
    }
    
    /// Calls the APIService func `getMainMap(portalItem:completion:)` on a background thread,
    /// awaits the response, then sets the MapsViewModel mainMap property with the mapItem that is returned, if successful
    func fetchMainMap() {
        guard !self.mainMapLoading, networkManager.isOnline else {
            return
        }
        
        self.mainMapLoading = true
        
        Task(priority: .background) {
            await service.getMainMap(portalItem: portalItem) { [unowned self] result in
                DispatchQueue.main.async {
                    self.mainMapLoading = false
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let map):
                        self.mainMap = map
                    }
                }
            }
        }
    }
    
    /// Calls the APIService func `getOfflineMaps(offlineMapTask:completion:)` on a background thread,
    /// awaits the response, then adds the maps to the core data persistence controller and sets the MapsViewModel
    /// mapAreas property with the mapItems that are returned, if successful
    func fetchMapAreas() {
        guard !self.offlineMapsLoading, networkManager.isOnline,
              let offlineMapTask = self.offlineMapTask else {
            return
        }
        
        self.offlineMapsLoading = true
        Task(priority: .background) {
            await service.getOfflineMaps(offlineMapTask: offlineMapTask) { [unowned self] result in
                DispatchQueue.main.async {
                    self.offlineMapsLoading = false
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                        return
                    case .success(let maps):
                        for map in maps {
                            let _ = OfflineMap(id: map.id, title: map.portalItem.title, snippet: map.portalItem.snippet, context: PersistenceController.shared.container.viewContext)
                        }
                        
                        PersistenceController.shared.save()
                        self.mapAreas = maps
                    }
                }
            }
        }
    }
    
    /// Calls the APIService func `downloadOfflineMap(mapItem:preplannedMapArea:offlineMapTask:completion:)`
    /// on a background thread, awaits the response, then sets the mapItem's map property to the downloaded map, if successful
    /// - Parameter mapItem: the mapItem for which the map is being downloaded
    func downloadMapArea(mapItem: MapItem) {
        guard mapItem.buttonStatus != .loading,
              networkManager.isOnline,
              let preplannedMapArea = mapItem.preplannedMapArea,
              let offlineMapTask = self.offlineMapTask else {
            return
        }
        
        mapItem.buttonStatus = .loading
        Task(priority: .background) {
            await service.downloadOfflineMap(mapItem: mapItem, preplannedMapArea: preplannedMapArea, offlineMapTask: offlineMapTask) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        mapItem.buttonStatus = .download
                        print(error.description)
                    case .success(let map):
                        mapItem.buttonStatus = .delete
                        mapItem.map = map
                    }
                }
            }
        }
    }
    
    /// Calls the APIService func `removeDownloadedOfflineMap(mapItem:completion:)`
    /// which removes the map from the application support directory, if successful
    /// - Parameter mapItem: the mapItem for which the map is being deleted
    func deleteOfflineMap(mapItem: MapItem) {
        guard mapItem.buttonStatus != .loading else {
            return
        }
        
        service.removeDownloadedOfflineMap(mapItem: mapItem) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let url):
                print("Map area was removed from \(url)")
            }
        }
    }
    
    /// Calls the APIService func `checkForExistingMap(id:)` on a background thread,
    /// awaits the response, and returns the map, if available
    func getExistingMapIfAvailable(id: String?) -> Map? {
        guard let id else {
            return nil
        }
        
        Task {
            return await service.checkForExistingMap(id: id)
        }
        
        return nil
    }
    
    
    //MARK: - preview helpers
    
    static func errorState() -> MapsViewModel {
        let fetcher = MapsViewModel(service: MockAPIService())
        return fetcher
    }

    static func successState() -> MapsViewModel {
        let fetcher = MapsViewModel(service: MockAPIService())
        fetcher.mainMap = MapItem.example()
        fetcher.mapAreas = []
        return fetcher
    }
}

extension PortalItem  {
    static func mainMap() -> PortalItem {
        PortalItem(portal: .arcGISOnline(connection: .anonymous), id: PortalItem.ID("3bc3179f17da44a0ac0bfdac4ad15664")!)
    }
}
