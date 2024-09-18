//
//  UserDefaults+extensions.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-18.
//

import Foundation

extension UserDefaults {
    @objc dynamic var currency: String {
        string(forKey: "Currency") ?? "USD"
    }
}
