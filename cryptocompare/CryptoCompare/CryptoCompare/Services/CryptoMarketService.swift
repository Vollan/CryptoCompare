//
//  CryptoMarketService.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import Foundation
import CryptoCore

protocol CryptoMarketServicing {
    func getMarkets() async throws -> [Market]
    func getDetails(id: String) async throws -> [CoinDetail]
}

class CryptoMarketService: HTTPClient, CryptoMarketServicing {
    
    func getMarkets() async throws -> [Market] {
        try await sendRequest(endpoint: ListEndpoint.getMarkets, responseModel: [Market].self, session: URLSession.shared).get()
    }
    
    func getDetails(id: String) async throws -> [CoinDetail] {
        try await sendRequest(endpoint: ListEndpoint.getDetails(market: id), responseModel: [CoinDetail].self, session: URLSession.shared).get()
    }
}
