//
//  CryptoComparisonViewAdapter.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-18.
//

import SwiftUI

class CryptoComparisonViewAdapter: ObservableObject {
    
    @Published var cryptoDataViewModel: CryptoCurrencyModel?
    var coordinator: CoordinatorViewModel
    private let markets: [Market]
    
    init(coordinator: CoordinatorViewModel, markets: [Market]) {
        self.coordinator = coordinator
        self.markets = markets
        generateCryptoDataViewModel()
    }
    
    private func generateCryptoDataViewModel() {
        cryptoDataViewModel = .init(
            title: "compare_crypto_price_changes".localized(),
            information: markets.map { market in
                    .init(
                        name: market.name,
                        priceChangePercentage24h: market.priceChange24h,
                        formattedChange: String(format: "%.2f", market.priceChange24h) + "%"
                    )
            }
        )
    }
    
    @MainActor func close() {
        coordinator.pop()
    }
}
