//
//  CryptoCompareApp.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import SwiftUI
import SwiftData

@main
struct CryptoCompareApp: App {
    
    @StateObject private var coordinator = CoordinatorViewModel()

    var body: some Scene {
        WindowGroup {
            SplashView(viewAdapterFactory: ViewAdapterFactory(coordinator: coordinator))
        }
    }
}
