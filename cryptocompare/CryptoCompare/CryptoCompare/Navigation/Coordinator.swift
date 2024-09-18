//
//  Coordinator.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import SwiftUI

enum NavigationItem: Hashable {
    case cryptoListView([Market])
    case cryptoDetailView(symbol: String, id: String, name: String)
    case cryptoCompareView([Market])

    func hash(into hasher: inout Hasher) {
        switch self {
        case .cryptoListView:
            hasher.combine("cryptoListView")
        case .cryptoDetailView:
            hasher.combine("cryptoDetailView")
        case .cryptoCompareView:
            hasher.combine("cryptoCompareView")
        }
    }

    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        switch (lhs, rhs) {
        case (.cryptoListView, .cryptoListView),
             (.cryptoDetailView, .cryptoDetailView),
            (.cryptoCompareView, .cryptoCompareView):
            return true
        default:
            return false
        }
    }
}

@MainActor class CoordinatorViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func push(_ item: NavigationItem) {
        path.append(item)
    }
}
