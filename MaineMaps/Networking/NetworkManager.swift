//
//  NetworkManager.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/29/23.
//

import Foundation
import Network

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    @Published var isOnline: Bool = true
    private let monitor = NWPathMonitor()
    
    private init() {
        monitor.pathUpdateHandler = { [unowned self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.isOnline = true
                } else {
                    self.isOnline = false
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
