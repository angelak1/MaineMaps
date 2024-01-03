//
//  FullScreenMapView.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import ArcGIS
import SwiftUI

struct FullScreenMapView: View {
    @State var mapItem: MapItem
    var body: some View {
        if let map = mapItem.map {
            MapView(map: map)
                .navigationBarTitleDisplayMode(.inline)
        } else if mapItem.buttonStatus == .loading {
            ProgressView("\(mapItem.portalItem.title) map is downloading")
        } else if mapItem.buttonStatus == .download {
            Text("You must download the \(mapItem.portalItem.title) map before it can be viewed. Tap button below to download").multilineTextAlignment(.center)
            DownloadButtonView(mapItem: mapItem)
        } else {
            Text("Error loading map")
        }
    }
}

#Preview {
    FullScreenMapView(mapItem: MapItem.example())
}
