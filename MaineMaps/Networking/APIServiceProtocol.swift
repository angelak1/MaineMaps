//
//  APIServiceProtocol.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import ArcGIS
import Foundation

protocol APIServiceProtocol {
    /// Get the main web map item
    /// - Parameter portalItem: The portal item for the web map
    /// - Returns: A result type with the associated value of a MapItem if successful or an APIError if failture
    func getMainMap(portalItem: PortalItem, completion: @escaping (Result<MapItem, APIError>) -> Void) async
    
    /// Get the offline map areas
    /// #  Note: #
    /// this function does not return the Map property of the MapItem
    /// and instead returns the ids which can be used to get the Maps as needed
    /// - Parameter offlineMapTask: the map task used to get the offline map areas
    /// - Returns: A result type with an associated value of the list of map items corresponding to the offline map areas if successful
    /// or an APIError if failure
    func getOfflineMaps(offlineMapTask: OfflineMapTask, completion: @escaping (Result<[MapItem], APIError>) -> Void) async
    
    /// Downloads the offline map and saves it to the application support directory
    /// - Parameter mapItem: the map item for which the map is being downloaded
    /// - Returns: A result type witth an associated value of the map that is displayable offline if successful
    /// or an APIError if failure
    func downloadOfflineMap(mapItem: MapItem, preplannedMapArea: PreplannedMapArea, offlineMapTask: OfflineMapTask, completion: @escaping(Result<Map, APIError>) -> Void) async
    
    /// Removes a previously downloaded map from the application support directory
    /// - Parameter mapItem: the map item for which the downloaded map is being removed
    /// - Returns: A result type with an associated value of the url from which the map was removed if successful
    /// or an APIError if failure
    func removeDownloadedOfflineMap(mapItem: MapItem, completion: @escaping(Result<URL, APIError>) -> Void)
    
    /// Checks to see if there is an existing downloaded map based on the map's id
    /// - Parameter id: the id of the map
    /// - Returns: An optional map, if there is an existing downloaded map
    func checkForExistingMap(id: String) async -> Map?
}
