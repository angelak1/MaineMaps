//
//  MockAPIService.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/30/23.
//

import ArcGIS
import Foundation

/// Mock API Implementation used for previews and tests
struct MockAPIService: APIServiceProtocol {
    func getMainMap(portalItem: PortalItem, completion: @escaping (Result<MapItem, APIError>) -> Void) async {
        completion(.success(MapItem.example()))
    }
    
    func getOfflineMaps(offlineMapTask: OfflineMapTask, completion: @escaping (Result<[MapItem], APIError>) -> Void) async {
        completion(.success([]))
    }
    
    func downloadOfflineMap(mapItem: MapItem, preplannedMapArea: PreplannedMapArea, offlineMapTask: OfflineMapTask, completion: @escaping(Result<Map, APIError>) -> Void) async {
        var mapResult: Map
        // Check to see if the app area is already saved in the cache folder, if so we display it.
        do {
            let filePathURL = URL.applicationSupportDirectory.appending(path: (mapItem.id))
            if let offlineMap = checkForExistingMap(filePathURL: filePathURL) {
                completion(.success(offlineMap))
                return
            }
            
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
        return checkForExistingMap(filePathURL: filePathURL)
    }
    
    private func checkForExistingMap(filePathURL: URL) -> Map? {
        let fileManager = FileManager.default
        var hasVTPKFile = false
        do {
            if fileManager.fileExists(atPath: filePathURL.relativePath) {
                for folder in try fileManager.contentsOfDirectory(atPath: filePathURL.relativePath) {
                    if folder.hasPrefix("p13") {
                        let folderURL = filePathURL.appending(path: folder)
                        for file in try fileManager.contentsOfDirectory(atPath: folderURL.relativePath) {
                            if file.hasSuffix("vtpk") {
                                let vtpkFileURL = folderURL.appending(path: file)
                                hasVTPKFile = true
                                // Instantiates a vector tiled layer with the path to the vtpk file.
                                let localVectorTiledLayer = ArcGISVectorTiledLayer(url: vtpkFileURL)
                                // Creates a map using the tiled layer as a basemap.
                                let mapResult = Map(basemap: Basemap(baseLayer: localVectorTiledLayer))
                                return mapResult
                            }
                        }
                    }
                }
                
                // if the folder was created but the vtpk file wasn't created we want to delete it and download the map
                if hasVTPKFile == false {
                    // delete the existing folder if there is one so that we don't run into errors trying to save the new map to the folder
                    try FileManager.default.removeItem(at: filePathURL)
                }
            }
        }
        catch {
            print(error)
        }
        
        return nil
    }
}
