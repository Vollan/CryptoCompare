//
//  Publisher+extensions.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-18.
//

import Combine

extension Publisher where Failure == Never {
    func sinkTask(receiveValue: @escaping (Output) async -> Void) -> AnyCancellable {
        sink { value in
            Task {
                await receiveValue(value)
            }
        }
    }
}
