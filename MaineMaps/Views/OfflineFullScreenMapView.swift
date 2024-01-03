//
//  OfflineFullScreenMapView.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import ArcGIS
import SwiftUI

struct OfflineFullScreenMapView: View {
    @State var map: Map?
    var body: some View {
        if let map {
            MapView(map: map)
        } else {
            Text("Sorry, this map was not previously downloaded \u{2639}")
        }
    }
}
