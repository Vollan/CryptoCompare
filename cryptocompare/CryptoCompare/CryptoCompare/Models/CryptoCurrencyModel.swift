//
//  CryptoCurrencyModel.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-18.
//

import Foundation

struct CryptoCurrencyModel {
    
    let title: String
    let information: [Information]
    
    struct Information: Identifiable {
        let id = UUID()
        let name: String
        let priceChangePercentage24h: Double
        let formattedChange: String
    }
}
