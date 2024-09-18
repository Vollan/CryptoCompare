//
//  Double+extensions.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-18.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension String {
    func cleanDouble() -> String {
        (Double(self) ?? 0).removeZerosFromEnd()
    }
}


extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    func rateAdjustment(currency: Currency) -> String {
        (self * (currency == .SEK ? AppResource.sekRate : 1)).removeZerosFromEnd()
    }
}


