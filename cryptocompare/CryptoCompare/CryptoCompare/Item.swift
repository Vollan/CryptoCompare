//
//  Item.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
