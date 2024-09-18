//
//  CurrencyViewModel.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import Foundation

class CurrencyViewModel: Hashable, Identifiable, ObservableObject {
    static func == (lhs: CurrencyViewModel, rhs: CurrencyViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let name: String
    let image: String
    let currency: String
    let value: String
    let positiveRise: Bool
    var isCheckedAction: () -> Void
    
    @Published var isChecked = false {
        didSet {
            isCheckedAction()
        }
    }
    
    init(id: String, name: String, image: String, isChecked: Bool = false, currency: String, value: String, positiveRise: Bool, isCheckedAction: @escaping () -> Void) {
        self.id = id
        self.name = name
        self.image = image
        self.isChecked = isChecked
        self.currency = currency
        self.value = value
        self.positiveRise = positiveRise
        self.isCheckedAction = isCheckedAction
    }
}
