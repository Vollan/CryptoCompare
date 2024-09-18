//
//  ListCryptoViewAdapter.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import SwiftUI
import Combine

class CryptoListViewAdapter: ObservableObject {
        
    private var cancellableSet = Set<AnyCancellable>()
    private let service: CryptoMarketServicing
    var coordinator: CoordinatorViewModel
    
    @Published var viewModels: [CurrencyViewModel] = []
    @Published var isMultipleSelectionVisible = false
    private var markets: [Market]
    private var currentCurrency: Currency
        
    init(coordinator: CoordinatorViewModel, markets: [Market], service: CryptoMarketServicing = CryptoMarketService()) {
        self.coordinator = coordinator
        self.markets = markets
        self.service = service
        self.currentCurrency = .init(rawValue: AppResource.currency) ?? .USD
        
        setupCurrencySubscription()
        generateViewModels()
    }
        
    private func setupCurrencySubscription() {
        UserDefaults.standard.publisher(for: \.currency)
            .receive(on: DispatchQueue.main)
            .sinkTask { [weak self] value in
                guard let self = self else { return }
                let currency: Currency = .init(rawValue: value) ?? .USD
                self.currentCurrency = .init(rawValue: value) ?? .USD
                await self.updateMarketData(for: currency.rawValue)
            }
            .store(in: &cancellableSet)
    }
        
    @MainActor private func updateMarketData(for currency: String) async {
        do {
            let newMarkets = try await service.getMarkets()
            self.markets = newMarkets
            generateViewModels()
        } catch {
            handleDataFetchError()
        }
    }
    
    private func handleDataFetchError() {
        #warning("Implement error handling")
    }
        
    private func generateViewModels() {
        viewModels = markets.map { createCurrencyViewModel(from: $0) }
        DispatchQueue.main.async {
            self.updateSelectionVisibility()
        }
    }
    
    private func createCurrencyViewModel(from market: Market) -> CurrencyViewModel {
        CurrencyViewModel(
            id: market.id,
            name: market.name,
            image: market.image,
            currency: currentCurrency.displayableValue,
            value: market.currentPrice.rateAdjustment(currency: currentCurrency),
            positiveRise: market.priceChange24h > 0,
            isCheckedAction: {
                DispatchQueue.main.async {
                    self.updateSelectionVisibility()
                }
            }
        )
    }
        
    @MainActor func showDetail(for id: String) {
        guard let market = markets.first(where: { $0.id == id }) else {
            showErrorMessage("Market not found")
            return
        }
        coordinator.push(.cryptoDetailView(symbol: market.symbol, id: market.id, name: market.name))
    }
    
    @MainActor func compareSelections() {
        let selectedIds = viewModels.filter({ $0.isChecked }).map(\.id)
        let selectedMarkets = markets.filter({ selectedIds.contains($0.id) })
        coordinator.push(.cryptoCompareView(selectedMarkets))
    }
        
    @MainActor private func updateSelectionVisibility() {
        DispatchQueue.main.async {
            self.isMultipleSelectionVisible = self.viewModels.filter { $0.isChecked }.count > 1
        }
    }
    
    private func showErrorMessage(_ message: String) {
        #warning("Implement UI error display")
    }
}
