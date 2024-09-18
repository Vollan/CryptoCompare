//
//  AppResource.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-18.
//

import SwiftUI

struct AppResource {
    
    @AppStorage(wrappedValue: "USD", "Currency")
    static var currency: String
    
    @AppStorage(wrappedValue: 1, "ExchangeRate")
    static var sekRate: Double
}
