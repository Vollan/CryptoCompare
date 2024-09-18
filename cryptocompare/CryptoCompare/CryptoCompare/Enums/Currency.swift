//
//  Currency.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-18.
//

import Foundation

enum Currency: String {
    case USD = "USD"
    case SEK = "SEK"
    
    var displayableValue: String {
        switch self {
        case .USD:
            "USD "
        case .SEK:
            "SEK "
        }
    }
}
