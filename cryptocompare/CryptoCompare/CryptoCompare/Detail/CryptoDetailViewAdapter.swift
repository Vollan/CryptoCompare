//
//  CryptoDetailViewAdapter.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import Foundation

struct CryptoPricePoint: Identifiable {
    let id = UUID()
    let time: Date
    let price: Double
}

struct DetailViewModel: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let currency: String
}

struct DetailsModel {
    let currentPrice: String
    let low24h: String
    let high24h: String
    
}

import Combine

class CryptoDetailViewAdapter: ObservableObject {
    
    private var cancellableSet = Set<AnyCancellable>()
    @Published var pricePoints: [CryptoPricePoint] = []
    @Published var sparklinePrices: [Double] = []
    @Published var detailModels: [DetailViewModel] = []
    
    var coordinator: CoordinatorViewModel
    var receivedWebSocketResponse = false
    
    private let symbol: String
    private let id: String
    private var coinDetail: CoinDetail?
    private let service: CryptoMarketServicing
    private var currentCurrency: Currency = .init(rawValue: AppResource.currency) ?? .USD
    private var timer: Timer?
    var daysRange: ClosedRange<Date>

    init(coordinator: CoordinatorViewModel, service: CryptoMarketServicing = CryptoMarketService(), symbol: String, id: String) {
        self.coordinator = coordinator
        self.service = service
        self.symbol = symbol
        self.id = id
        let currentDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        self.daysRange = startDate...currentDate
        subscribe()
    }
    
    private func subscribe() {
        UserDefaults.standard.publisher(for: \.currency)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.currentCurrency = .init(rawValue: value) ?? .USD
                guard let coinDetail = self?.coinDetail else { return }
                self?.updateCryptoDetails([coinDetail])
            }
            .store(in: &cancellableSet)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 7.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.activateBackupDetails() }
        }
    }
    
    @MainActor func activateBackupDetails() async {
        do {
            let data = try await service.getDetails(id: id)
            updateCryptoDetails(data)
            generatePricePoints()
        } catch {
            #warning("Handle error message")
        }
    }
    
    @MainActor private func generateDetailViewModel(model: DetailsModel) {
        self.detailModels = [
            .init(
                title: "current_price_label".localized(),
                value: model.currentPrice,
                currency: currentCurrency.displayableValue
            ),
            .init(
                title: "highest_24h_label".localized(),
                value: model.high24h,
                currency: currentCurrency.displayableValue
            ),
            .init(
                title: "lowest_24h_label".localized(),
                value: model.low24h,
                currency: currentCurrency.displayableValue
            )
        ]
    }
    
    private func updateCryptoDetails(_ data: [CoinDetail]) {
        guard let cryptoDetails = data.first(where: { $0.id == id }) else { return }
        self.coinDetail = cryptoDetails
        let sparklines = cryptoDetails.sparkline_in_7d?.price ?? []
        sparklinePrices = sparklines.map { $0 * (currentCurrency == .SEK ? AppResource.sekRate : 1) }
        DispatchQueue.main.async {
            self.generateDetailViewModel(
                model: .init(
                    currentPrice: cryptoDetails.currentPrice.rateAdjustment(currency: self.currentCurrency),
                    low24h: (cryptoDetails.low24h ?? 0).rateAdjustment(currency: self.currentCurrency),
                    high24h: (cryptoDetails.high24h ?? 0).rateAdjustment(currency: self.currentCurrency)
                )
            )
        }
    }
    
    private func generatePricePoints() {
        guard let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return }
        let interval = Date().timeIntervalSince(startDate) / Double(max(sparklinePrices.count - 1, 1))
        
        pricePoints = sparklinePrices.enumerated().map { index, price in
            let date = startDate.addingTimeInterval(interval * Double(index))
            return CryptoPricePoint(time: date, price: price)
        }
    }
    
    @MainActor func close() {
        coordinator.pop()
    }
}
