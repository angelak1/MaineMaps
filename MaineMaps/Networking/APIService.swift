//
//  APIService.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import ArcGIS
import Foundation

struct APIService: APIServiceProtocol {
    static let shared = APIService()

    func getMainMap(portalItem: PortalItem, completion: @escaping (Result<MapItem, APIError>) -> Void) async {
        for await status in portalItem.$loadStatus {
            if status == .loaded {
                completion(.success(MapItem(id: portalItem.id!, portalItem: portalItem, map: Map(item: portalItem))))
            } else if status == .failed {
                completion(.failure(APIError.unknown))
            }
        }
    }

    func getOfflineMaps(offlineMapTask: OfflineMapTask, completion: @escaping (Result<[MapItem], APIError>) -> Void) async {
        do {
            let maps = try await offlineMapTask.preplannedMapAreas.compactMap { MapItem(id: $0.portalItem.id!, portalItem: $0.portalItem, preplannedMapArea: $0, buttonStatus: .download) }
            completion(.success(maps))
        } catch {
            completion(.failure(APIError.other(error)))
        }
    }

    func downloadOfflineMap(mapItem: MapItem, preplannedMapArea: PreplannedMapArea, offlineMapTask: OfflineMapTask, completion: @escaping(Result<Map, APIError>) -> Void) async {
        var mapResult: Map
        // Check to see if the app area is already saved in the cache folder, if so we display it.
        let filePathURL = URL.applicationSupportDirectory.appending(path: (mapItem.id))
        if let offlineMap = await checkForExistingMap(filePathURL: filePathURL) {
            completion(.success(offlineMap))
            return
        }
        
        do {
            // If we didn't find a downloaded version of the map we create the map task so we can download it
            // Configures the parameters.
            let parameters = try await offlineMapTask.makeDefaultDownloadPreplannedOfflineMapParameters(preplannedMapArea: preplannedMapArea)
            parameters.continuesOnErrors = false
            parameters.includesBasemap = true
            // Makes the preplanned map job from the offline map task.
            let downloadPreplannedMapJob = offlineMapTask.makeDownloadPreplannedOfflineMapJob(parameters: parameters, downloadDirectory: filePathURL)
            // Starts the preplanned map job and gets its output.
            downloadPreplannedMapJob.start()
            let output = try await downloadPreplannedMapJob.output
            // Prints the errors if any.
            if output.hasErrors {
                output.layerErrors.forEach { layerError in
                    print("Error taking this layer offline: \(layerError.key.layer.name)")
                }
                output.tableErrors.forEach { tableError in
                    print("Error taking this table offline: \(tableError.key.featureTable.displayName)")
                }
                
                completion(.failure(APIError.unknown))
            } else {
                // Otherwise, displays the map.
                mapResult = output.offlineMap
                completion(.success(mapResult))
            }
        } catch {
            completion(.failure(APIError.other(error)))
        }
    }

    func removeDownloadedOfflineMap(mapItem: MapItem, completion: @escaping(Result<URL, APIError>) -> Void) {
        let fileManager = FileManager.default
        let filePathURL = URL.applicationSupportDirectory.appending(path: (mapItem.portalItem.id?.rawValue ?? Date.now.description))
        if fileManager.fileExists(atPath: filePathURL.relativePath) {
            do {
                try FileManager.default.removeItem(at: filePathURL)
                completion(.success(filePathURL))
            } catch {
                completion(.failure(APIError.other(error)))
            }
        } else {
            completion(.failure(APIError.unknown))
        }
    }
    
    func checkForExistingMap(id: String) async -> Map? {
        let filePathURL = URL.applicationSupportDirectory.appending(path: (id))
        return await checkForExistingMap(filePathURL: filePathURL)
    }
    
    /// Checks to see if there is an existing downloaded map based on the map's id
    /// - Parameter filePathURL: the URL where the existing map would be if it's been downloaded
    /// - Returns: An optional map, if there is an existing downloaded map
    private func checkForExistingMap(filePathURL: URL) async -> Map? {
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: filePathURL.relativePath) {
                let mapPackage = MobileMapPackage(fileURL: filePathURL)
                do {
                    try await mapPackage.load()
                    return mapPackage.maps.first
                } catch {
                    do {
                        try fileManager.removeItem(at: filePathURL)
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    return nil
                }
            }
            return nil
        }
    }
}
