//
//  MapsListItemView.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import Foundation
import SwiftUI

struct MapListItemView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var mapItem: MapItem
    private let imageHeight = 100.0
    private let imageWidth = 140.0
    
    var body: some View {
        if mapItem.portalItem.loadStatus != .loaded {
            ProgressView()
        } else {
            let url = mapItem.buildImageUrl()
            HStack(spacing: 8) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFill()
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped()
                    } else if phase.error != nil {
                        Rectangle()
                            .frame(width: imageWidth, height: imageHeight)
                            .foregroundStyle(.linearGradient(.init(colors: [.white, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    } else {
                        ProgressView()
                            .frame(width: imageWidth, height: imageHeight)
                    }
                }

                VStack(alignment: .leading) {
                    Text(mapItem.portalItem.title).font(.regular18).foregroundStyle(colorScheme == .dark ? .white : .black)
                    Text(mapItem.portalItem.snippet).font(.bold10).lineLimit(3).foregroundStyle(.gray).multilineTextAlignment(.leading)
                }
                
                DownloadButtonView(mapItem: mapItem)
            }
        }
    }
}

#Preview {
    MapListItemView(mapItem: MapItem.example())
}
