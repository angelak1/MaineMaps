//
//  DownloadButtonView.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import Foundation
import SwiftUI

struct DownloadButtonView: View {
    @EnvironmentObject var mapsViewModel: MapsViewModel
    @State private var displayAlert = false
    @State var mapItem: MapItem
    
    var body: some View {
        if mapItem.buttonStatus != .none {
            Button(action: {
                if mapItem.buttonStatus == .download {
                    mapsViewModel.downloadMapArea(mapItem: mapItem)
                } else if mapItem.buttonStatus == .delete {
                    displayAlert = true
                }
            }) {
                if mapItem.buttonStatus == .loading {
                    ProgressView()
                        .scaledToFit()
                        .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                        .frame(width: 30, height: 30)
                        .background(Color.lightGray)
                        .clipShape(Circle())
                } else {
                    Image(mapItem.buttonStatus.rawValue)
                        .resizable()
                        .scaledToFit()
                        .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                        .frame(width: 30, height: 30)
                        .background(Color.lightGray)
                        .clipShape(Circle())
                        .alert("Are you sure you want to delete this map?", isPresented: $displayAlert, actions: {
                            Button("No", role: .cancel) {}
                            Button("Yes", role: .destructive) {
                                mapItem.map = nil
                                mapItem.buttonStatus = .download
                                mapsViewModel.deleteOfflineMap(mapItem: mapItem)
                            }
                        })
                }
            }
        }
    }
}

#Preview {
    DownloadButtonView(mapItem: MapItem.example()).environmentObject(MapsViewModel())
}
