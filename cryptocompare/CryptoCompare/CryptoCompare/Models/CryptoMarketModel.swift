//
//  CryptoMarketModel.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import Foundation

struct Market: Decodable {
    var id: String
    var symbol: String
    var name: String
    var currentPrice: Double
    var image: String
    var priceChange24h: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case currentPrice = "current_price"
        case priceChange24h = "price_change_percentage_24h"
        case image
    }
}
