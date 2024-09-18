//
//  SplashView.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import SwiftUI
struct Rate: Decodable {
    let rates: Rates
    
    struct Rates: Decodable {
        let SEK: Double
    }
}

final class ViewAdapterFactory {
    
    let coordinator: CoordinatorViewModel
    
    init(coordinator: CoordinatorViewModel) {
        self.coordinator = coordinator
        getConversion()
    }
    
    func getConversion() {
        guard let url = URL(string: "https://open.er-api.com/v6/latest/USD") else { return }
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url) else { return }
            let rates = try? JSONDecoder().decode(Rate.self, from: data)
            AppResource.sekRate = rates?.rates.SEK ?? 10
        }
    }
    
    func splashViewAdapter() -> SplashScreenViewAdapter {
        .init(coordinator: coordinator)
    }
    
    func listCryptoViewAdapter(markets: [Market]) -> CryptoListViewAdapter {
        .init(coordinator: coordinator, markets: markets)
    }
    
    @MainActor func cryptoDetailViewAdapter(symbol: String, id: String) -> CryptoDetailViewAdapter {
        .init(coordinator: coordinator, symbol: symbol, id: id)
    }
    
    func cryptoCompareViewAdapter(markets: [Market]) -> CryptoComparisonViewAdapter {
        .init(coordinator: coordinator, markets: markets)
    }
}

class SplashScreenViewAdapter: ObservableObject {
    
    var coordinator: CoordinatorViewModel
    private let service: CryptoMarketServicing
    
    init(coordinator: CoordinatorViewModel, service: CryptoMarketServicing = CryptoMarketService()) {
        self.coordinator = coordinator
        self.service = service
    }
    
    @MainActor func fetchData() async {
        do {
            let markets = try await service.getMarkets()
            coordinator.push(.cryptoListView(markets))
        } catch {
            #warning("handle error")
        }
    }
}

struct SplashView: View {
    
    @StateObject var viewAdapter: SplashScreenViewAdapter
    private var viewAdapterFactory: ViewAdapterFactory
    @State var showInformation: Bool = false
    init(viewAdapterFactory: ViewAdapterFactory) {
        self.viewAdapterFactory = viewAdapterFactory
        self._viewAdapter = .init(wrappedValue: viewAdapterFactory.splashViewAdapter())
    }
    
    let currencies = ["USD", "SEK"]
    @State private var currentCurrency = AppResource.currency
    
    var body: some View {
        NavigationStack(path: $viewAdapter.coordinator.path) {
            Text("")
                .foregroundStyle(Color.white)
                .task {
                    await viewAdapter.fetchData()
                }
                .navigationDestination(for: NavigationItem.self) { item in
                    Group {
                        switch item {
                        case .cryptoListView(let markets):
                            CryptoListView(viewAdapter: viewAdapterFactory.listCryptoViewAdapter(markets: markets))
                                .navigationBarBackButtonHidden()
                        case .cryptoDetailView(let symbol, let id, let name):
                            CryptoDetailView(viewAdapter: viewAdapterFactory.cryptoDetailViewAdapter(symbol: symbol, id: id))
                                .navigationTitle(name)
                        case .cryptoCompareView(let markets):
                            CryptoComparisonView(viewAdapter: viewAdapterFactory.cryptoCompareViewAdapter(markets: markets))
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                ForEach(currencies, id: \.self) { currency in
                                    Button(action: {
                                        AppResource.currency = currency
                                        currentCurrency = currency
                                    }) {
                                        Text(currency)
                                    }
                                }
                            } label: {
                                Text(currentCurrency)
                                    .font(.headline)
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                showInformation = true
                            }) {
                                Image(systemName: "info.circle")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
        }
        .sheet(isPresented: $showInformation, content: {
            BuyCryptoGuideView()
        })
    }
}
