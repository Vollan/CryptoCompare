//
//  CryptoDetailModel.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import Foundation

struct CoinDetail: Decodable {
    let id: String
    let name: String
    let currentPrice: Double
    let image: String
    let high24h: Double?
    let low24h: Double?
    let sparkline_in_7d: SparklineData?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case currentPrice = "current_price"
        case image
        case high24h = "high_24h"
        case low24h = "low_24h"
        case sparkline_in_7d = "sparkline_in_7d"
    }
}

struct SparklineData: Decodable {
    let price: [Double]
}
