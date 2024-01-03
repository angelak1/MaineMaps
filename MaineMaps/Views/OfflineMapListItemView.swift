//
//  OfflineMapListItemView.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import Foundation
import SwiftUI

struct OfflineMapListItemView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var mapItem: OfflineMap
    private let imageHeight = 100.0
    private let imageWidth = 140.0
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .frame(width: imageWidth, height: imageHeight)
                .foregroundStyle(.linearGradient(.init(colors: [.white, .gray]), startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(alignment: .leading) {
                Text(mapItem.title).font(.regular18).foregroundStyle(colorScheme == .dark ? .white : .black)
                Text(mapItem.snippet).font(.bold10).lineLimit(3).foregroundStyle(.gray).multilineTextAlignment(.leading)
            }
        }
    }
}


#Preview {
    OfflineMapListItemView(mapItem: OfflineMap.example1)
}
