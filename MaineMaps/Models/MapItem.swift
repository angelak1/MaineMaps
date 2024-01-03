//
//  MapItem.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/28/23.
//

import Foundation
import ArcGIS

@Observable class MapItem: Identifiable {
    var id: PortalItem.ID.RawValue
    var map: Map?
    var portalItem: PortalItem
    var preplannedMapArea: PreplannedMapArea?
    var buttonStatus: ButtonStatus
    
    init(id: PortalItem.ID, portalItem: PortalItem, map: Map? = nil, preplannedMapArea: PreplannedMapArea? = nil, buttonStatus: ButtonStatus = .none) {
        self.id = id.rawValue
        self.portalItem = portalItem
        self.map = map
        self.preplannedMapArea = preplannedMapArea
        self.buttonStatus = buttonStatus
    }
}

extension MapItem {
    func buildImageUrl() -> URL {
        guard let url = self.portalItem.thumbnail?.url else {
            return URL(string: "https://placehold.co/140x100?text=Image+Not+Available")!
        }
        
        return url
    }

// MARK: - SwiftUI helper

    /// Online map of Maine used for previews and tests
    static func example() -> MapItem {
        return MapItem(id: PortalItem.mainMap().id!, portalItem: PortalItem.mainMap())
    }
}
